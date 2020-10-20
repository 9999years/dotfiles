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
    repo: PrettyPath
    installed: PrettyPath
    link_dest: Path
    when: Optional[str] = None


@dataclass
class DotfilesJson:
    dotfiles: List[Dotfile]
    ignored: List[str]

    @classmethod
    def load_from_file(cls, fh: io.TextIOBase) -> DotfilesJson:
        """
        Reads the file at the given filename, parses it as JSON, and returns the
        "dotfiles" entry, or None if no such entry is found.

        >>> ".bash_profile" in load_dotfiles("dotfiles.json")
        True
        """
        raw_dotfiles = json.load(fh)
        return cls(
            dotfiles=[
                Dotfile.from_json(dotfile) for dotfile in raw_dotfiles["dotfiles"]
            ],
            ignored=raw_dotfiles.get("ignored", []),
        )


@dataclass
class PrettyPath:
    """A Path with an alternate display form
    """

    rel: Path
    abs: Path
    disp: str

    def __str__(self) -> str:
        return self.disp

    @classmethod
    def from_path(cls, rel: Path, abs: Path) -> PrettyPath:  # pylint: disable=W0622
        """Create from a plain path.
        """
        home = path.expanduser("~")
        if abs.startswith(home):
            disp = abs.replace(home, "~", 1)
        else:
            disp = abs
        return cls(rel=rel, abs=abs, disp=disp)
