"""Entry point for linking dotfiles.
"""

import argparse
import subprocess
import sys
from os import path

from . import schema
from . import log
from .link import Linker


def _argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="links dotfiles")
    parser.add_argument(
        "-d",
        "--dotfiles",
        type=argparse.FileType("r"),
        help="The dotfiles.json file to load",
    )
    #  parser.add_argument(
    #  "-s", "--scan", action="store_true", help="Scan for untracked dotfiles",
    #  )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Make output more verbose",
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
        log.fatal(
            "Couldn't run `git` to determine repo root; pass --dotfiles explicitly."
        )
        sys.exit(1)

    if proc.returncode != 0:
        log.fatal("Couldn't get repo root from git; pass --dotfiles explicitly.")
        sys.exit(1)

    return proc.stdout.strip()


def main():
    """Entry point.
    """
    args = _argparser().parse_args()

    repo_root = _get_repo_root()
    if args.dotfiles is None:
        dotfiles_path = open(path.join(repo_root, "dotfiles.json"))
    else:
        dotfiles_path = args.dotfiles

    dotfiles = schema.DotfilesJson.load_from_file(dotfiles_path)
    link_root = path.expanduser("~")
    linker = Linker(repo_root=repo_root, link_root=link_root, verbose=args.verbose)
    linker.link_all(dotfiles.dotfiles)


if __name__ == "__main__":
    main()
