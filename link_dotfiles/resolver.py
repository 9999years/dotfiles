"""Contains the Resolver class for resolving dotfiles into absolute paths.
"""

import os
from dataclasses import dataclass

from .schema import Dotfile, Path, PrettyPath, ResolvedDotfile


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
        installed = os.path.join(self.link_root, dotfile.installed)
        repo = os.path.join(self.repo_root, dotfile.repo)
        link_dest = repo
        if self.relative:
            prefix = os.path.commonpath([installed, link_dest])
            if prefix != os.sep:
                link_dest = os.path.relpath(link_dest, os.path.dirname(installed))
        return ResolvedDotfile(
            repo=PrettyPath.from_path(rel=dotfile.repo, abs=Path(repo),),
            installed=PrettyPath.from_path(rel=dotfile.installed, abs=Path(installed),),
            link_dest=Path(link_dest),
            when=dotfile.when,
        )
