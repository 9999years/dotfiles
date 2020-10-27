"""Entry point for linking dotfiles.
"""

import argparse
import subprocess
import sys
from os import path

from . import log, schema
from .schema import Path
from .link import Linker
from .resolver import Resolver


def _argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="links dotfiles")
    parser.add_argument(
        "-d",
        "--dotfiles",
        type=argparse.FileType("r"),
        help="The dotfiles.json file to load",
    )
    parser.add_argument(
        "-r", "--relative", action="store_true", help="Create relative links"
    )
    #  parser.add_argument(
    #  "-s", "--scan", action="store_true", help="Scan for untracked dotfiles",
    #  )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Make output more verbose",
    )
    return parser


def _get_repo_root() -> Path:
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

    return Path(proc.stdout.strip())


def main() -> None:
    """Entry point.
    """
    args = _argparser().parse_args()

    repo_root = _get_repo_root()
    if args.dotfiles is None:
        dotfiles_path = open(path.join(repo_root, "dotfiles.json"))
    else:
        dotfiles_path = args.dotfiles

    dotfiles = schema.DotfilesJson.load_from_file(dotfiles_path)
    link_root = Path(path.expanduser("~"))
    linker = Linker(
        resolver=Resolver(
            repo_root=repo_root, link_root=link_root, relative=args.relative
        ),
        verbose=args.verbose,
    )
    linker.link_all(dotfiles.dotfiles)


if __name__ == "__main__":
    main()
