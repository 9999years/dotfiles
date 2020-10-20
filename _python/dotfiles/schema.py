from __future__ import annotations

from dataclasses import dataclass
from typing import NewType, Optional, List, Union, Dict
import io
import json
from os import path

Path = NewType("Path", str)


@dataclass
class Dotfile:
    repo: Path
    installed: Path
    when: Optional[str] = None

    @classmethod
    def from_json(cls, obj: Union[str, Dict[str, str]]) -> Dotfile:
        if isinstance(obj, str):
            return cls(repo=Path(obj), installed=Path(obj))
        else:
            repo = obj["repo"]
            installed = Path(obj.get("installed", repo))
            return cls(repo=Path(repo), installed=installed)


@dataclass
class ResolvedDotfile:
    repo_rel: Path
    repo_abs: Path
    link_dest: Path
    installed_rel: Path
    installed_abs: Path
    when: Optional[str] = None


def load_dotfiles(fh: io.TextIOBase) -> List[Dotfile]:
    """
    Reads the file at the given filename, parses it as JSON, and returns the
    "dotfiles" entry, or None if no such entry is found.

    >>> ".bash_profile" in load_dotfiles("dotfiles.json")
    True
    """
    raw_dotfiles = json.load(fh)["dotfiles"]
    return [Dotfile.from_json(dotfile) for dotfile in raw_dotfiles]


@dataclass
class PrettyPath:
    """A Path with an alternate display form
    """

    path: Path
    display: str

    def __str__(self) -> str:
        return self.display

    @classmethod
    def from_path(cls, orig_path: Path) -> PrettyPath:
        """Create from a plain path.
        """
        home = path.expanduser("~")
        if orig_path.startswith(home):
            display = orig_path.replace(home, "~", 1)
        else:
            display = orig_path
        return cls(display=display, path=orig_path)
