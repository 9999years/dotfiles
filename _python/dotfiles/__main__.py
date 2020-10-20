import argparse
import os
import subprocess
import sys
import tempfile
from os import path

from . import color as co
from . import schema
from .link import Linker


def _argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="links dotfiles")
    parser.add_argument(
        "-d",
        "--dotfiles",
        type=argparse.FileType("r"),
        help="The dotfiles.json file to load",
    )
    return parser


def _get_repo_root():
    try:
        proc = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=path.dirname(__file__),
            capture_output=True,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        print(
            co.RED
            + "Couldn't run `git` to determine repo root; pass --dotfiles explicitly."
            + co.RESET
        )
        sys.exit(1)

    if proc.returncode != 0:
        print(co.RED, "Couldn't get repo root from git; pass --dotfiles explicitly.")
        sys.exit(1)

    return proc.stdout.strip()


def main():
    args = _argparser().parse_args()

    repo_root = _get_repo_root()
    if args.dotfiles is None:
        dotfiles_path = open(path.join(repo_root, "dotfiles.json"))
    else:
        dotfiles_path = args.dotfiles

    dotfiles = schema.load_dotfiles(dotfiles_path)
    #  link_root = tempfile.mkdtemp()
    link_root = path.expanduser("~")
    linker = Linker(repo_root=repo_root, link_root=link_root)
    for dotfile in dotfiles:
        linker.link(dotfile)


if __name__ == "__main__":
    main()
