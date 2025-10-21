"""Build a catalog for published artifacts."""

# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "packaging",
# ]
# ///

import json
import re
from os import getenv
from pathlib import Path
from subprocess import run
from typing import Literal

from packaging.version import Version

URL_PREFIX = (
    f"{getenv('GITHUB_SERVER_URL', default='https://github.com')}"
    f"/{getenv('GITHUB_REPOSITORY', default='typst-community/dev-builds')}"
    "/releases/tag/"
)

TAG_PATTERN = re.compile(
    r"(?P<artifact>[-a-z]+)-(?P<revision>v[-.0-9rc]+|main\.\d{4}-\d{2}-\d{2}\.[0-9a-f]{6,})"
)

type RawReleaseMeta = Literal["name", "tagName", "publishedAt"]
type ReleaseMeta = Literal[
    "name", "publishedAt", "revision", "releaseTag", "releaseUrl", "officialUrl"
]


def get_raw_releases() -> list[dict[RawReleaseMeta, str]]:
    result = run(
        ["gh", "release", "list", "--json", "name,tagName,publishedAt"],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def generate_catalog(
    raw_releases: list[dict[RawReleaseMeta, str]],
) -> dict[str, list[dict[ReleaseMeta, str]]]:
    catalog: dict[str, list[dict[ReleaseMeta, str]]] = {
        # Specify the order of artifacts
        "docs": [],
        "typst": [],
        "package-check": [],
        "hayagriva": [],
    }

    for r in raw_releases:
        m = TAG_PATTERN.fullmatch(r["tagName"])
        assert m is not None, f"failed to parse “{r['tagName']}”"
        match = m.groupdict()

        release: dict[ReleaseMeta, str] = {
            "name": r["name"],
            "publishedAt": r["publishedAt"],
            "revision": match["revision"],
            "releaseTag": r["tagName"],
            "releaseUrl": f"{URL_PREFIX}{r['tagName']}",
            "officialUrl": get_official_url(match["artifact"], match["revision"]),
        }

        catalog[match["artifact"]].append(release)

    for v in catalog.values():
        v.sort(key=key_for_release, reverse=True)

    return catalog


def is_tagged(revision: str) -> bool:
    """Determine whether the revision is officially tagged"""
    # This can be improved in the future when necessary.
    return revision.startswith("v")


def key_for_release(it: dict[ReleaseMeta, str]) -> tuple[int | str | Version, ...]:
    if is_tagged(it["revision"]):
        version = Version(it["revision"])
        return 1, version
    else:
        return 0, it["revision"], it["publishedAt"]


def get_official_url(artifact: str, revision: str) -> str:
    repo = artifact if artifact != "docs" else "typst"
    if is_tagged(revision):
        return f"https://github.com/typst/{repo}/releases/tag/{revision}"
    else:
        commit = revision.split(".")[-1]
        return f"https://github.com/typst/{repo}/tree/{commit}"


if __name__ == "__main__":
    root_dir = Path(__file__).parent.parent
    dist_dir = root_dir / "dist"
    dist_dir.mkdir(exist_ok=True)

    raw_releases = get_raw_releases()
    catalog = generate_catalog(raw_releases)

    catalog_json = json.dumps(
        {
            "version": "0.1.1",
            "artifacts": catalog,
        },
        indent=2,
        ensure_ascii=False,
    )
    (dist_dir / "catalog.json").write_text(catalog_json, encoding="utf-8")

    run(
        [
            "typst",
            "compile",
            root_dir / "scripts/catalog.typ",
            dist_dir / "index.html",
            "--features=html",
            f"--root={root_dir}",
        ],
        check=True,
    )
