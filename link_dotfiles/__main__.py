"""Entry point for linking dotfiles.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from . import log
from .link import Linker
from .resolver import Resolver
from .scan import Scanner
from .schema import DotfilesJson, PrettyPath


def main() -> None:
    """Entry point.
    """
    args = Args.parse_args()

    if args.dotfiles is None:
        repo_root = _get_repo_root()
        dotfiles_fh = open(repo_root / "dotfiles.json")
    else:
        repo_root = args.dotfiles.parent.absolute()
        dotfiles_fh = args.dotfiles.open()

    dotfiles = DotfilesJson.load_from_file(dotfiles_fh)
    dotfiles_fh.close()

    link_root = Path.home() if args.link_root is None else args.link_root

    resolver = Resolver(
        repo_root=repo_root, link_root=link_root, relative=not args.absolute
    )
    resolved = resolver.resolve_all(dotfiles)

    if args.scan:
        log.warn("Scanning for dotfiles is an experimental feature.")
        scanner = Scanner(link_root, resolved.ignored, resolved.dotfiles)
        for p in scanner.find_dotfiles():
            # TODO: Fill in scanner processing.
            # Actions:
            # - ignore the path
            # - move it to dotfiles
            #
            # Should also note if it's a directory or file.
            log.info(str(PrettyPath.from_path(p).disp))

    else:
        linker = Linker(verbose=args.verbose,)
        linker.link_all(resolved.dotfiles)


@dataclass
class Args:
    """Command-line arguments; see ``_argparser``.
    """

    dotfiles: Optional[Path]
    link_root: Optional[Path]
    absolute: bool
    scan: bool
    verbose: bool

    @classmethod
    def parse_args(cls) -> Args:
        """Parse args from ``sys.argv``.
        """
        args = _argparser().parse_args()
        return cls(
            dotfiles=args.dotfiles,
            link_root=args.link_root,
            absolute=args.absolute,
            scan=args.scan,
            verbose=args.verbose,
        )


def _argparser() -> argparse.ArgumentParser:
    """Command-line argument parser.
    """
    parser = argparse.ArgumentParser(description="links dotfiles")
    parser.add_argument(
        "-d", "--dotfiles", type=Path, help="The dotfiles.json file to load",
    )
    parser.add_argument(
        "-l",
        "--link-root",
        type=Path,
        help="Where to create links from; defaults to your home directory",
    )
    parser.add_argument(
        "-a",
        "--absolute",
        action="store_true",
        help="Create absolute links, rather than relative ones",
    )
    parser.add_argument(
        "-s", "--scan", action="store_true", help="Scan for untracked dotfiles",
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Make output more verbose",
    )
    return parser


def _get_repo_root() -> Path:
    try:
        proc = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
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

    return Path(proc.stdout.strip()).absolute()


if __name__ == "__main__":
    main()
