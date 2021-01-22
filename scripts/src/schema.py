"""Basic dotfile classes and JSON loading.
"""

from __future__ import annotations

import enum
import io
import json
import os
from dataclasses import dataclass
from enum import Enum
from functools import cached_property
from os import path
from typing import Dict, List, NewType, Optional, TextIO, Union
from pathlib import Path

GlobPat = NewType("GlobPat", str)


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


class Status(Enum):
    """The status of an installed dotfile.
    """

    # The link already exists and points to the correct file.
    OK = enum.auto()
    # The link exists but points somewhere else; such a link may be broken.
    DIFF_DEST = enum.auto()
    # The path doesn't exist at all.
    MISSING = enum.auto()
    # The path exists and is a regular file/dir, not a link.
    NOT_LINK = enum.auto()


@dataclass
class ResolvedDotfile:
    repo: PrettyPath
    installed: PrettyPath
    link_dest: Path
    when: Optional[str] = None

    @cached_property
    def status(self) -> Status:
        """Get the status of a given dotfile.
        """
        exists = path.exists(self.installed.abs)

        if path.islink(self.installed.abs):
            if not exists:
                # Broken symlink.
                return Status.DIFF_DEST

            # Get the link destination as an absolute path.
            dest = path.join(
                path.dirname(self.installed.abs), os.readlink(self.installed.abs),
            )
            if path.samefile(dest, self.repo.abs):
                # The link points to the correct file.
                return Status.OK
            else:
                # The link points somewhere else.
                return Status.DIFF_DEST

        else:
            if exists:
                # A regular file.
                return Status.NOT_LINK
            else:
                # Missing.
                return Status.MISSING


@dataclass
class DotfilesJson:
    """``dotfiles.json`` schema.
    """

    dotfiles: List[Dotfile]
    ignored: List[GlobPat]

    @classmethod
    def load_from_file(cls, fh: TextIO) -> DotfilesJson:
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
            ignored=[GlobPat(pat) for pat in raw_dotfiles.get("ignored", [])],
        )


@dataclass
class ResolvedDotfilesJson:
    """``dotfiles.json`` schema with resolved dotfiles.
    """

    dotfiles: List[ResolvedDotfile]
    ignored: List[GlobPat]


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
    def from_path(
        cls, rel: Path, abs: Optional[Path] = None  # pylint: disable=W0622
    ) -> PrettyPath:
        """Create from a plain path.
        """
        if abs is None:
            abs = rel.absolute()
        home = Path.home()
        if str(abs).startswith(str(home)):
            disp = str(abs).replace(str(home), "~", 1)
        else:
            disp = str(abs)
        return cls(rel=rel, abs=abs, disp=disp)
