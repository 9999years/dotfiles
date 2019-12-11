#! /usr/bin/env python

from __future__ import print_function

import os
import json
import sys
import socket

try:
    from glob import fnmatch  # type: ignore
except ImportError:
    import fnmatch  # type: ignore

DOTFILES_FILENAME = "dotfiles.json"

IS_PY3 = sys.version_info[0] == 3
if IS_PY3:
    Text = str
else:
    Text = unicode  # type: ignore


def load_dotfiles(filename):
    with open(filename) as f:
        return json.load(f).get("dotfiles", None)


def dotfiles_filename(filename=None):
    if filename is not None:
        return filename
    else:
        return os.path.join(
            os.path.dirname(os.path.realpath(__file__)), DOTFILES_FILENAME
        )


def os_error_to_dict(err):
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
            self.path = dotfile
            self.dest = dotfile
            self.platforms = None
            self.hostname_pats = None
        else:
            self.path = dotfile["path"]
            self.dest = dotfile.get("dest", self.path)

            when = dotfile.get("when", {})
            self.platforms = when.get("platform", None)
            if isinstance(self.platforms, Text):
                self.platforms = [self.platforms]

            self.hostname_pats = when.get("hostname", None)
            if isinstance(self.hostname_pats, Text):
                self.hostname_pats = [self.hostname_pats]

    def __eq__(self, other):
        return (
            isinstance(other, Dotfile)
            and self.path == other.path
            and self.dest == other.dest
            and self.platforms == other.platforms
            and self.hostname_pats == other.hostname_pats
        )

    def __repr__(self):
        return "Dotfile({{'path': {}, 'dest': {}, 'platform': {}, 'hostname': {}}})".format(
            repr(self.path),
            repr(self.dest),
            repr(self.platforms),
            repr(self.hostname_pats),
        )


LINK_STATUS = {
    "DOESNT_EXIST": "The link doesn't exist",
    "EXISTS": "A different file exists where the link would be",
    "OK": "The link exists and points to the correct destination",
}

DIR_STATUS = {
    "DOESNT_EXIST": "The directory doesn't exist",
    "EXISTS": "The directory exists",
    "FILE_EXISTS": "A file with the same name exists where the directory is expected",
}


def mkdir(dest):
    dirname = os.path.dirname(dest)
    if not os.path.exists(dirname):
        os.makedirs(dirname)
        return DIR_STATUS["DOESNT_EXIST"]
    elif os.path.isdir(dirname):
        return DIR_STATUS["EXISTS"]
    else:
        return DIR_STATUS["FILE_EXISTS"]


class Dotfiles:
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
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'platform': ['win32', 'darwin']}}))
        False
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'platform': ['win32', 'darwin', 'linux']}}))
        True
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'platform': 'linux'}}))
        True
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'hostname': '*.baz.edu'}}))
        False
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'hostname': ['*.baz.edu', 'bux']}}))
        False
        >>> dotfiles._should_link(Dotfile({'path': 'foo', 'when': {'hostname': ['*.baz.edu', '*f*']}}))
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

    def _link_exists(self, path, dest):
        if os.path.exists(dest):
            if os.path.realpath(dest) == os.path.realpath(path):
                return LINK_STATUS["OK"]
            else:
                return LINK_STATUS["EXISTS"]
        else:
            return LINK_STATUS["DOESNT_EXIST"]

    def link_all(self):
        ret = {"changed": False, "failed": False}
        report = []

        def link(path, dest):
            report.append(
                {"path": path, "dest": dest, "status": "linked",}
            )
            try:
                kwargs = {}
                if IS_PY3:
                    kwargs["target_is_directory"] = os.path.isdir(dest)
                os.symlink(path, dest, **kwargs)
                ret["changed"] = True
            except OSError as e:
                report[-1]["status"] = "errored"
                report[-1]["error"] = os_error_to_dict(e)
                ret["failed"] = True

        for dotfile in self.files():
            resolved_path = os.path.join(self.basename, dotfile.path)
            if self._should_link(dotfile):
                resolved_dest = os.path.join(self.home, dotfile.dest)
                report.append({"path": resolved_path, "status": "link created"})
                dir_exists = mkdir(resolved_dest)
                if dir_exists == DIR_STATUS["FILE_EXISTS"]:
                    report[-1]["status"] = dir_exists
                    continue
                exists = self._link_exists(resolved_path, resolved_dest)
                if exists == LINK_STATUS["OK"]:
                    report[-1]["status"] = "link already exists"
                elif exists == LINK_STATUS["EXISTS"]:
                    report[-1][
                        "status"
                    ] = "something else exists; refusing to overwrite"
                    ret["failed"] = True
                elif exists == LINK_STATUS["DOESNT_EXIST"]:
                    # Attempt to link.
                    link(resolved_path, resolved_dest)
            else:
                report.append({"path": resolved_path, "status": "skipped"})
        ret["files"] = report
        return ret


def main():
    dotfiles = Dotfiles()
    report = dotfiles.link_all()
    json.dump(report, fp=sys.stdout, indent=2)
    print()


if __name__ == "__main__":
    main()
