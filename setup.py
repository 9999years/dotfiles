#! /usr/bin/env python
"""Reads and creates symlinks to dotfiles.

Utility for reading dotfiles (see dotfiles.json) and creating symlinks from ~/
to the dotfiles in this repository / referenced by dotfiles.json.

Unfortunately, this script needs to run on the old Python distributions that
many computers come with -- 2.7, probably, but it'll get even cruftier if I
need to support older versions.
"""

from __future__ import print_function, unicode_literals

import os
import json
import sys
import socket
import io

# Python 2/3 compatability.
try:
    from glob import fnmatch  # type: ignore
except ImportError:
    import fnmatch  # type: ignore

# Again, Python 2/3 compatability.
IS_PY3 = sys.version_info[0] == 3
if IS_PY3:
    Text = str
    Bytes = bytes
else:
    Text = unicode  # type: ignore  # noqa  # pylint: disable=E0602
    Bytes = str  # type: ignore

DOTFILES_FILENAME = "dotfiles.json"


def load_dotfiles(filename):
    """
    Reads the file at the given filename, parses it as JSON, and returns the
    "dotfiles" entry, or None if no such entry is found.

    >>> # Returns nothing; no 'dotfiles' entry.
    >>> load_dotfiles("dotfiles_schema.json")
    >>> ".bash_profile" in load_dotfiles("dotfiles.json")
    True
    """
    with io.open(filename, encoding="utf-8") as fh:
        return json.load(fh).get("dotfiles", None)


def dotfiles_filename(filename=None):
    """
    Gets the dotfiles filename, either the directory of this script joined with
    DOTFILES_FILENAME or the given filename.

    >>> dotfiles_filename('aslkdgjalskjdg')
    'aslkdgjalskjdg'
    >>> dotfiles_filename().split('/')[-1]
    'dotfiles.json'
    """
    if filename is not None:
        return filename
    else:
        return os.path.join(
            os.path.dirname(os.path.realpath(__file__)), DOTFILES_FILENAME
        )


def os_error_to_dict(err):
    """
    Converts an OsError to a dict, for easy JSON serialization.
    """
    ret = {
        "errno": err.errno,
        "strerror": err.strerror,
    }
    if IS_PY3:
        if sys.platform == "win32":
            ret["winerror"] = err.winerror
        ret["filename"] = err.filename
        ret["filename2"] = err.filename2
    return ret


class Dotfile:
    """A dotfile to be symlinked.

    Properties:
        path (str): The dotfile's path, relative to this script.
        dest (str): The dotfile's destination, relative to the user's home directory.
        platforms (List[str]): The platforms the dotfile should be linked on,
            or None if it should always be linked.
        hostname_pats (List[str]): Hostname-globs that this file should be linked on,
            or None if it should always be linked.
    """

    def __init__(self, dotfile):
        """Creates a new Dotfile instance.

        >>> Dotfile('xyz')
        Dotfile({'path': 'xyz', 'dest': 'xyz', 'platform': None, 'hostname': None})

        >>> Dotfile({'path': 'xyz', 'when': {'hostname': 'win32'}})
        Dotfile({'path': 'xyz', 'dest': 'xyz', 'platform': None, 'hostname': ['win32']})

        >>> Dotfile({'path': 'xyz', 'when': {'hostname': ['win32', 'linux']}})
        Dotfile({'path': 'xyz', 'dest': 'xyz', 'platform': None, 'hostname': ['win32', 'linux']})

        >>> Dotfile({'path': 'xyz', 'dest': 'abc'})
        Dotfile({'path': 'xyz', 'dest': 'abc', 'platform': None, 'hostname': None})
        """
        if isinstance(dotfile, Text):
            # A simple path; assume defaults.
            self.path = dotfile
            self.dest = dotfile
            self.platforms = None
            self.hostname_pats = None
        else:
            # A dict, get data that's present and assume defaults for the rest.
            self.path = dotfile["repo"]
            self.dest = dotfile.get("dest", self.path)

            when = dotfile.get("when", {})
            self.platforms = when.get("platform", None)
            if isinstance(self.platforms, Text):
                self.platforms = [self.platforms]

            self.hostname_pats = when.get("hostname", None)
            if isinstance(self.hostname_pats, Text):
                self.hostname_pats = [self.hostname_pats]

    def __repr__(self):
        return "Dotfile({{'path': {}, 'dest': {}, 'platform': {}, 'hostname': {}}})".format(
            repr(self.path),
            repr(self.dest),
            repr(self.platforms),
            repr(self.hostname_pats),
        )


DIR_STATUS = {
    "DOESNT_EXIST": "The directory doesn't exist",
    "EXISTS": "The directory exists",
    "FILE_EXISTS": "A file with the same name exists where the directory is expected",
}


def mkdir(dest):
    """Creates the given directory, and any necessary leading components.

    Returns: A status string, one of the values of DIR_STATUS.
    """
    dirname = os.path.dirname(dest)
    if not os.path.exists(dirname):
        os.makedirs(dirname)
        return DIR_STATUS["DOESNT_EXIST"]
    elif os.path.isdir(dirname):
        return DIR_STATUS["EXISTS"]
    else:
        return DIR_STATUS["FILE_EXISTS"]


LINK_STATUS = {
    "DOESNT_EXIST": "Link doesn't exist",
    "EXISTS": "A different file exists where the link would be",
    "OK": "The link exists and points to the correct destination",
    "CREATED": "Link newly-created",
}

STATUSES = {
    "ERRORED": "An OS error was encountered",
    "LINK_OK": "OK",
    "EXISTS": "Something else exists where the link would be; refusing to overwrite",
    "SKIPPED": "Skipped",
}


def link_exists(path, dest):
    """Checks if a symlink exists, pointing to `dest`.

    Returns: A status string, one of the values of LINK_STATUS.
    """
    if os.path.exists(dest):
        if os.path.realpath(dest) == os.path.realpath(path):
            return LINK_STATUS["OK"]
        else:
            return LINK_STATUS["EXISTS"]
    else:
        return LINK_STATUS["DOESNT_EXIST"]


class Dotfiles:
    """Resolves and links dotfiles. Ingests dotfile configuration data, checks
    the filesystem, and creates links.
    """

    def __init__(self, dotfiles=None, hostname=None, platform=None):
        """Creates a new Dotfiles instance.
        """
        if dotfiles is None or isinstance(dotfiles, Text):
            if dotfiles is None:
                # Use defaults
                self.basename = dotfiles_filename()
            elif isinstance(dotfiles, Text):
                # `dotfiles` is a filename
                self.basename = dotfiles
            self.dotfiles = load_dotfiles(self.basename)
            self.basename = os.path.dirname(self.basename)
        else:
            # `dotfiles` is an iterable of dotfiles
            self.basename = ""
            self.dotfiles = list(dotfiles)

        if hostname:
            self.hostname = hostname
        else:
            self.hostname = socket.getfqdn()

        if platform:
            self.platform = platform
        else:
            self.platform = sys.platform

        self.home = os.path.expanduser("~")

    def files(self):
        """Gets an iterator over this instane's dotfiles.

        Returns (Iterator[Dotfile]): An iterator over each of the dotfiles held
            by this instance.
        """
        return map(Dotfile, self.dotfiles)

    def _should_link(self, dotfile):
        """
        Arguments:
            dotfile (Dotfile): The dotfile to inspect

        >>> dotfiles = Dotfiles([], hostname='foo', platform='linux')
        >>> dotfiles._should_link(Dotfile('foo'))
        True
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'platform': 'win32'}}))
        False
        >>> dotfiles._should_link(Dotfile({
        ...     'path': 'foo',
        ...     'when': {'platform': ['win32', 'darwin']}
        ... }))
        False
        >>> dotfiles._should_link(Dotfile({
        ...     'path': 'foo',
        ...     'when': {'platform': ['win32', 'darwin', 'linux']}
        ... }))
        True
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'platform': 'linux'}}))
        True
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'hostname': '*.baz.ed'}}))
        False
        >>> dotfiles._should_link(Dotfile({
        ...     'path': 'foo',
        ...     'when': {'hostname': ['*.baz.edu', 'bux']}
        ... }))
        False
        >>> dotfiles._should_link(Dotfile({
        ...     'path': 'foo',
        ...     'when': {'hostname': ['*.baz.edu', '*f*']}
        ... }))
        True
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'hostname': '*fo*'}}))
        True
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'hostname': 'foo'}}))
        True
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'hostname': 'baz*'}}))
        False
        """
        if dotfile.platforms and self.platform not in dotfile.platforms:
            return False

        if dotfile.hostname_pats:
            for hostname_pat in dotfile.hostname_pats:
                if fnmatch.fnmatch(self.hostname, hostname_pat):
                    return True
            return False

        return True

    def link_all(self):
        """Creates links for all dotfiles represented by this instance.

        Returns: A JSON report describing the changes made.
        """
        ret = {"changed": False, "failed": False}
        report = []

        def link(path, dest):
            report.append(
                {"path": path, "dest": dest, "status": LINK_STATUS["CREATED"]}
            )
            try:
                kwargs = {}
                if IS_PY3:
                    kwargs["target_is_directory"] = os.path.isdir(dest)
                os.symlink(path, dest, **kwargs)
                ret["changed"] = True
            except OSError as err:
                report[-1]["status"] = STATUSES["ERRORED"]
                report[-1]["error"] = os_error_to_dict(err)
                ret["failed"] = True

        for dotfile in self.files():
            resolved_path = os.path.join(self.basename, dotfile.path)
            if self._should_link(dotfile):
                resolved_dest = os.path.join(self.home, dotfile.dest)
                report.append({"path": resolved_path, "status": LINK_STATUS["CREATED"]})
                dir_exists = mkdir(resolved_dest)
                if dir_exists == DIR_STATUS["FILE_EXISTS"]:
                    report[-1]["status"] = dir_exists
                    continue
                exists = link_exists(resolved_path, resolved_dest)
                if exists == LINK_STATUS["OK"]:
                    report[-1]["status"] = STATUSES["LINK_OK"]
                elif exists == LINK_STATUS["EXISTS"]:
                    report[-1]["status"] = STATUSES["EXISTS"]
                    ret["failed"] = True
                elif exists == LINK_STATUS["DOESNT_EXIST"]:
                    # Attempt to link.
                    link(resolved_path, resolved_dest)
            else:
                report.append({"path": resolved_path, "status": STATUSES["SKIPPED"]})
        ret["files"] = report
        return ret


def main():
    dotfiles = Dotfiles()
    report = dotfiles.link_all()
    json.dump(report, fp=sys.stdout, indent=2)
    print()


if __name__ == "__main__":
    main()
