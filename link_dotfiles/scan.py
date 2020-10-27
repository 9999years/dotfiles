"""Scanning home directories for untracked dotfiles.
"""

from dataclasses import dataclass
from pathlib import Path
from typing import Iterator, List, NewType

from .resolver import Resolver
from .schema import Dotfile

GlobPat = NewType("GlobPat", str)


@dataclass
class Scanner:
    """Scans home directories for untracked dotfiles.
    """

    home: Path
    ignore: List[GlobPat]

    def should_ignore(self, path: Path) -> bool:
        """Is a given path ignored by any of the patterns in ``self.ignore``?
        """
        return any(map(path.match, self.ignore))

    def find_dotfiles(self) -> Iterator[Path]:
        """Iterate over dotfiles in ``self.home``, excluding ignored ones.
        """
        for p in self.home.glob(".*"):
            if not self.should_ignore(p):
                yield p

        config = self.home / ".config"
        for p in config.iterdir():
            if not self.should_ignore(p):
                yield p


# Issues:
# - Copying files into .dotfiles is ok
# - figuring out how to update dotfiles.json is HARD
