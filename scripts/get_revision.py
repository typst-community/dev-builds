"""Generate the tag for publishing artifacts."""

from datetime import UTC, datetime
from os import getenv
from pathlib import PurePosixPath as PurePath
from subprocess import run


def get_tag() -> str | None:
    result = run(
        ["git", "describe", "--tags", "--exact-match"], capture_output=True, text=True
    )
    if result.returncode == 0:
        return result.stdout.strip()


def get_description() -> str:
    # We can't use the git-describe format because of Typst's branch model.
    #
    #   v0.11.0 -- * -- * -- * -- * -- main
    #               \         \
    #                v0.12.0   v0.13.1
    #
    # Tags after v0.11.0 are outside the main branch.
    # As a result, `git describe --tags` is always relative to v0.11.0, like `v0.11.0-1051-g586b04948`.

    name_full = run(
        ["git", "name-rev", "--name-only", "HEAD"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    # Simplify `main`, `main~2`, etc. as `main`.
    name = name_full.split("~")[0]

    rev = run(
        ["git", "rev-parse", "--short", "HEAD"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    # Note that `len(revision)` might grow in the future, in order to avoid ambiguity.

    committer_date = datetime.fromisoformat(
        run(
            ["git", "log", "-1", "--format=%cd", "--date=iso-strict"],
            # Parsing is necessary, because:
            # - %cs can output YYYY-MM-DD, but in the original timezone.
            # - iso-strict-local with TZ=UTC can output in UTC, but will not strip the time.
            #
            # We use committer date (%cd) instead of author date (%ad), because it's more intuitive.
            # However, most pull requests are merged by squashing, so two dates are the same time in different timezones.
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
    )
    committer_date_utc = committer_date.astimezone(UTC).date().isoformat()

    return f"{name}.{committer_date_utc}.{rev}"


def get_workflow_name() -> str:
    # See https://docs.github.com/actions/reference/workflows-and-actions/variables
    if ref := getenv("GITHUB_WORKFLOW_REF"):
        return PurePath(ref.split("@")[0]).stem
    else:
        return "unknown"


if __name__ == "__main__":
    workflow = get_workflow_name()
    rev = get_tag() or get_description()
    print(f"{workflow}-{rev}")
