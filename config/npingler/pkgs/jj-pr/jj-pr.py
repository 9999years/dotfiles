import argparse
import re
import subprocess
from dataclasses import dataclass
from typing import Self

GH_USER_REGEX = re.compile(r"^(https://github\.com/|git@github\.com:)([^/]+)/.*")
GH_REPO_REGEX = re.compile(
    r"^(?P<prefix>https://github\.com/|git@github\.com:)"
    r"(?P<owner>[^/]+)/(?P<repo>[^/]+?)(?:\.git)?$"
)
DEFAULT_BRANCH_REGEX = re.compile(r"^ref: refs/heads/(.+)\tHEAD$")


def jj_log(template: str, rev: str) -> list[str]:
    stdout = subprocess.check_output(
        [
            "jj",
            "--ignore-working-copy",
            "--quiet",
            "log",
            "--no-graph",
            "--template",
            template,
            "-r",
            rev,
        ],
        text=True,
    )
    if stdout:
        return stdout.split(" ")
    return []


def jj_remotes() -> dict[str, str]:
    return {
        name: url
        for (name, url) in (
            line.split(" ", 1)
            for line in subprocess.check_output(
                [
                    "jj",
                    "--ignore-working-copy",
                    "--quiet",
                    "git",
                    "remote",
                    "list",
                ],
                text=True,
            ).splitlines()
        )
    }


def get_default_branch(owner: str) -> str:
    remotes = jj_remotes()
    github_remotes = [
        match for url in remotes.values() if (match := GH_REPO_REGEX.match(url))
    ]
    if not github_remotes:
        raise ValueError("Can't determine the GitHub repository from jj remotes")

    match = next(
        (
            match
            for match in github_remotes
            if match.group("owner").casefold() == owner.casefold()
        ),
        github_remotes[0],
    )
    target_url = f"{match.group('prefix')}{owner}/{match.group('repo')}.git"
    stdout = subprocess.check_output(
        ["git", "ls-remote", "--symref", target_url, "HEAD"],
        text=True,
    )
    for line in stdout.splitlines():
        if match := DEFAULT_BRANCH_REGEX.match(line):
            return match.group(1)

    raise ValueError(f"Can't determine the default branch for {target_url}")


@dataclass
class Bookmark:
    name: str
    remote: str

    @classmethod
    def from_remote_bookmark(cls, remote_bookmark: str) -> Self:
        try:
            name, remote = remote_bookmark.rsplit("@", 1)
        except ValueError:
            raise ValueError(
                f"Remote bookmarks should contain an '@': {remote_bookmark!r}"
            )
        return cls(name=name, remote=remote)

    @classmethod
    def from_remote_bookmarks(cls, remote_bookmarks: list[str]) -> list[Self]:
        return [
            cls.from_remote_bookmark(bookmark)
            for bookmark in remote_bookmarks
            if not bookmark.endswith("@git")
        ]

    def get_github_user(self) -> str:
        remotes = jj_remotes()
        url = remotes[self.remote]
        m = GH_USER_REGEX.match(url)
        assert m
        return m.group(2)

    def get_github_branch(self) -> str:
        user = self.get_github_user()
        return f"{user}:{self.name}"


@dataclass
class MakePrOpts:
    editor: bool
    fill: bool
    web: bool
    push: bool
    owner: str | None
    base: str | None
    extra_gh_args: list[str]

    def get_base(self) -> str | None:
        if self.base and ":" in self.base:
            return self.base

        if self.owner:
            return f"{self.owner}:{self.base or get_default_branch(self.owner)}"

        return self.base

    def get_gh_args(self) -> list[str]:
        args = []

        if self.web:
            if "-w" not in self.extra_gh_args and "--web" not in self.extra_gh_args:
                args.append("--web")
        elif (
            "-e" not in self.extra_gh_args
            and "--editor" not in self.extra_gh_args
            and self.editor
        ):
            args.append("--editor")

        if (
            all(
                arg not in self.extra_gh_args
                for arg in ["-f", "--fill", "--fill-first", "--fill-verbose"]
            )
            and self.fill
        ):
            args.append("--fill")

        if base := self.get_base():
            args.extend(["--base", base])

        args.extend(self.extra_gh_args)
        return args


def make_pr(rev: str, opts: MakePrOpts):
    bookmarks = jj_log("local_bookmarks", rev)
    remote_bookmarks = jj_log("remote_bookmarks", rev)
    candidate_remote_bookmarks = Bookmark.from_remote_bookmarks(remote_bookmarks)

    if len(bookmarks) > 1:
        raise ValueError(f"Wrong number of bookmarks there buddy: {bookmarks}")

    if len(bookmarks) != 1 or not candidate_remote_bookmarks:
        if not opts.push:
            if len(bookmarks) != 1:
                raise ValueError(
                    f"Wrong number of bookmarks there buddy: {bookmarks}. "
                    "Try again with --push to create a bookmark."
                )
            raise ValueError(
                f"No candidate remote bookmarks for revision {rev!r}. "
                "Try again with --push to push the local bookmark."
            )

        if bookmarks:
            subprocess.check_call(["jj", "git", "push", "--bookmark", bookmarks[0]])
        else:
            subprocess.check_call(["jj", "git", "push", "--change", rev])

        remote_bookmarks = jj_log("remote_bookmarks", rev)
        candidate_remote_bookmarks = Bookmark.from_remote_bookmarks(remote_bookmarks)

    # find current pr
    if len(candidate_remote_bookmarks) > 1:
        raise ValueError(
            f"More bookmarks on this commit than there should be: {candidate_remote_bookmarks}"
        )

    if not candidate_remote_bookmarks:
        raise ValueError(f"No candidate remote bookmarks for revision {rev!r}")

    # find the pr then
    github_branch = candidate_remote_bookmarks[0].get_github_branch()

    if len(candidate_remote_bookmarks) == 1:
        pr_view = [
            "gh",
            "pr",
            "view",
            "--json",
            "url,title",
            "--template",
            "{{ .url }}: {{ .title }}",
            github_branch,
        ]
        res = subprocess.call(pr_view)
        if res == 0:
            # well it exists, we're done here
            return

    # make a pr!
    subprocess.call(
        ["gh", "pr", "create", "--head", github_branch, *opts.get_gh_args()]
    )


def main():
    ap = argparse.ArgumentParser(description="Create pull requests with jj")
    ap.add_argument("revs", nargs="+", help="Revisions to PR")
    ap.add_argument(
        "--no-editor",
        dest="editor",
        action="store_false",
        help="Don't use an editor to write the PR title/body",
    )
    ap.add_argument(
        "--no-fill",
        dest="fill",
        action="store_false",
        help="Don't fill in the PR title/body from the commit message. Try this if you get a silly 'invalid object name' or 'unknown revision' error.",
    )
    ap.add_argument(
        "--web",
        action="store_true",
        help="Finish creating the PR in your web browser; implies `--no-editor`",
    )
    ap.add_argument(
        "--push",
        action="store_true",
        help="Push revisions that don't have a remote bookmark",
    )
    ap.add_argument(
        "--owner", default=None, help="Open the PR against a non-default owner"
    )
    ap.add_argument(
        "--base",
        default=None,
        help="The branch you want the code merged into; optionally accepts an owner like `owner:repo`",
    )
    # REMAINDER swallows everything from the first option onward, so option
    # values that look positional (e.g. the foo in --title foo) aren't eaten
    # as revisions.
    ap.add_argument(
        "gh_args",
        nargs=argparse.REMAINDER,
        help="Options passed to `gh pr create` verbatim, like `--base owner:repo` or `--web`",
    )
    args = ap.parse_args()

    make_pr_opts = MakePrOpts(
        editor=args.editor,
        fill=args.fill,
        web=args.web,
        push=args.push,
        owner=args.owner,
        base=args.base,
        extra_gh_args=args.gh_args,
    )

    for rev in args.revs:
        make_pr(rev, make_pr_opts)


if __name__ == "__main__":
    main()
