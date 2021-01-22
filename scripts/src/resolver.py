"""Contains the Resolver class for resolving dotfiles into absolute paths.
"""

import os
from dataclasses import dataclass
from pathlib import Path

from .schema import (Dotfile, DotfilesJson, PrettyPath, ResolvedDotfile,
                     ResolvedDotfilesJson)


@dataclass
class Resolver:
    """Manages the context around resolving a set of dotfiles.
    """

    # The repository root; this is where the canonical dotfiles are stored, and
    # might be `~/.dotfiles`.
    repo_root: Path

    # The link root; this is where the dotfiles are linked from, and is usually
    # `~`.
    link_root: Path

    # Should links be relative?
    relative: bool = True

    def __call__(self, dotfile: Dotfile) -> ResolvedDotfile:
        """Resolve a dotfile from configuration.
        """
        installed = self.link_root / dotfile.installed
        repo = self.repo_root / dotfile.repo
        link_dest = repo

        if self.relative:
            prefix = os.path.commonpath([installed, link_dest])
            if prefix != os.sep:
                link_dest = Path(os.path.relpath(link_dest, installed.parent))

        return ResolvedDotfile(
            repo=PrettyPath.from_path(rel=dotfile.repo, abs=repo),
            installed=PrettyPath.from_path(rel=dotfile.installed, abs=installed),
            link_dest=link_dest,
            when=dotfile.when,
        )

    def resolve_all(self, dotfiles: DotfilesJson) -> ResolvedDotfilesJson:
        """Resolve all dotfiles in a ``DotfilesJson`` object.
        """
        return ResolvedDotfilesJson(
            dotfiles=[self(dotfile) for dotfile in dotfiles.dotfiles],
            ignored=dotfiles.ignored,
        )
