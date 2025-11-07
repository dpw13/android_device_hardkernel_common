#!/usr/bin/env python3

# Parse parameters.txt and generate a combined image config for mk_combined_img.py

import argparse
import collections
import logging
import os
import re
import shutil
import subprocess
import sys

logger = logging.getLogger(__name__)

def get_kv(desc: str, sep: str) -> tuple[str, str]:
    parts = desc.split(sep)
    if len(parts) > 2:
        val = sep.join(parts[1:]).strip()
    else:
        val = parts[1].strip()
    return parts[0], val

def parse_params(path: str) -> dict[str, str]:
    result = dict()
    with open(path, "r", encoding="utf-8") as param:
        for line in param:
            k, v = get_kv(line, ":")
            result[k] = v

    return result

def parse_cmdline(desc: str) -> dict[str, str]:
    result = dict()
    parts = desc.split(" ")
    for part in parts:
        k, v = get_kv(part, "=")
        result[k] = v

    return result

Partition = collections.namedtuple("Partition", ["size", "start", "name"])

def parse_mtdargs(desc: str) -> tuple[str, list[Partition]]:
    dev, fmt = get_kv(desc, ":")

    parts = fmt.split(",")
    pattern = re.compile(r"(0x[0-9A-Fa-f]+|-)@(0x[0-9A-Fa-f]+)\(([a-z_:]+)\)")
    result = []

    for part in parts:
        if m := pattern.match(part):
            if m.group(1) == "-":
                size = 1024*1024*1024 // 512
            else:
                size = int(m.group(1), 0)
            name = m.group(3)
            if ":" in name:
                name = name.split(":")[0]
            result.append(Partition(size=size, start=int(m.group(2), 0), name=name))
        else:
            logger.warning("line does not match regex: %s", part)

    return (dev, result)

PART_TYPES = {
	"fat": 0x0700,
	"uboot": 0xa000,
	"misc": 0xa004,
	"boot": 0xa002,
	"recovery": 0xa003,
	"cache": 0xa007,
	"metadata": 0xa005,
}

def gen_sgdisk_args(parts: list[Partition]) -> list[str]:
    result: list[str] = []
    for i, part in enumerate(parts):
        part_num = i+1
        if part.size == 0:
            continue
        result.append(f"--new={part_num}:{part.start}:{part.start+part.size-1}")
        result.append(f"--change-name={part_num}:{part.name}")
        if part.name in PART_TYPES:
            result.append(f"--typecode={part_num}:{PART_TYPES[part.name]:04x}")

    return result

def _shell_cmd(comm_list: list[str]):
    subprocess.run(comm_list, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def shell_cmd(args, comm_list: list[str]):
    cmd_str = " ".join(comm_list)
    logger.debug(cmd_str)

    cmd_str = cmd_str.replace(args.target_out, "")
    if args.batch_dir:
        with open(os.path.join(args.target_out, args.batch_dir, "update.sh"), "+a", encoding="utf-8") as batch:
            batch.write(cmd_str + "\n")
    if not args.dryrun:
        _shell_cmd(comm_list)

def copy_partition(args, out_path: str, part: Partition) -> str:
    src_part_name = part.name
    if part.name.endswith("_a") or part.name.endswith("_b"):
        src_part_name = part.name[:-2]
    if src_part_name == "uboot":
        # Android puts the bootloader in a special place
        src_part_name = "bootloader"
    else:
        src_part_name = f"{src_part_name}.img"

    src_path = os.path.join(args.target_out, src_part_name)
    if os.path.exists(src_path):
        if args.batch_dir:
            batch_dst = os.path.join(args.target_out, args.batch_dir, src_part_name)
            try:
                os.remove(batch_dst)
            except:
                pass
            os.symlink(os.path.join("..", src_part_name), batch_dst)

        # Note that partition offsets and sizes are in 512B blocks
        dd_cmd = ["/usr/bin/dd", f"if={src_path}", f"of={out_path}", "conv=notrunc", "bs=2048", f"seek={part.start // 4}"]
        shell_cmd(args, dd_cmd)
        return src_part_name

    return ""

def generate(args):
    params = parse_params(os.path.join(args.target_out, "parameter.txt"))
    kargs = parse_cmdline(params["CMDLINE"])
    logger.debug(kargs)
    dev, parts = parse_mtdargs(kargs["mtdparts"])

    outpath = os.path.join(args.target_out, args.outfile)
    if os.path.exists(outpath):
        os.remove(outpath)

    # Add idbloader
    idbloader_part = Partition(start=64, size=(parts[0].start-65), name="idbloader")
    copy_partition(args, outpath, idbloader_part)

    logger.info(f"{dev}:")
    for i, part in enumerate(parts):
        src_info = copy_partition(args, outpath, part)
        logger.info(f"{i+1:2d}: {part.start:08x}-{part.start+part.size-1:08x} {part.name} {src_info}")

    # Pad file since super image is probably not as large as the space we allocate. We also need to save space for
    # the backup GPT
    size = parts[-1].start + parts[-1].size
    trunc_cmd = ["/usr/bin/truncate", outpath, f"--size={(size+36) * 512}"]
    shell_cmd(args, trunc_cmd)

    sgdisk_cmd = ["sgdisk", "--set-alignment=512"]
    sgdisk_cmd.extend(gen_sgdisk_args(parts))
    sgdisk_cmd.append(outpath)
    shell_cmd(args, sgdisk_cmd)

if __name__ == "__main__":
    parser = argparse.ArgumentParser("selfinstall.py")

    parser.add_argument("target_out")
    parser.add_argument("-o", "--outfile", default="selfinstall.img")
    parser.add_argument("-b", "--batch_dir")
    parser.add_argument("-d", "--dryrun", action="store_true")
    parser.add_argument("-v", action="store_true")

    args = parser.parse_args()

    level = logging.INFO
    if args.v:
        level = logging.DEBUG
    logging.basicConfig(level=level)

    if args.batch_dir:
        batch_dir = os.path.join(args.target_out, args.batch_dir)
        if os.path.exists(batch_dir):
            shutil.rmtree(batch_dir)
        os.mkdir(batch_dir)
        update = os.path.join(batch_dir, "update.sh")
        with open(update, "w", encoding="utf-8") as batch:
            batch.write("#/bin/sh\n\n")
        os.chmod(update, 0o755)

    generate(args)