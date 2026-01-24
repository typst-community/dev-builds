#set document(
  title: link("https://github.com/typst-community/dev-builds")[Typst dev builds],
  description: [Unofficial builds of #link("https://typst.app/home")[Typst] artifacts for development purposes.],
  author: "Typst Community",
  keywords: ("typst", "hayagriva", "typst-docs"),
)

#html.style(
  ```css
  body {
    background-color: white;
    color: black;

    max-width: 40em;
    margin: 0 auto;
    padding-inline: 1em;

    font-family: system-ui;
  }
  @media (prefers-color-scheme: dark) {
    body {
      background-color: #282828;
      color: white;
    }
  }

  h1 {
    margin-block: 2em;
    text-align: center;
  }

  p {
    line-height: 1.5;
  }

  li {
    margin-block: 0.3em;
  }

  a {
    color: #1464CC;
    text-decoration: none;
  }
  a:visited {
    color: #681da8;
  }
  a:hover {
    text-decoration: underline;
  }
  @media (prefers-color-scheme: dark) {
    a {
      color: #9fc1f9;
    }
    a:visited {
      color: #c58af9;
    }
  }

  code {
    background: #e6e6e6;
    padding: 0.15em 0.35em;
    border-radius: 4px;
  }
  @media (prefers-color-scheme: dark) {
    code {
      background: #4a4a4a;
    }
  }
  ```.text,
)

#title()

#context document.description

#show outline: body => {
  // Remove external links
  show link: it => if type(it.dest) == str { it.body } else { it }
  body
}
#outline()

= Introduction <introduction>
#{
  let full = read("/README.md")
  let start = "<!-- included by catalog.typ — start -->"
  let end = "<!-- included by catalog.typ — end -->"

  let readme = full.slice(full.position(start) + start.len(), full.position(end))

  import "@preview/cmarker:0.1.6": render
  render(readme)
}

= Artifacts <artifacts>

Only artifacts in #link("https://github.com/typst-community/dev-builds/releases")[GitHub Releases] are listed below.
There might be more recent builds in #link("https://github.com/typst-community/dev-builds/actions")[GitHub Actions]. You can find them by clicking the #html.span(html.img(src: "https://img.shields.io/badge/build-gray?style=flat-square&logo=github", alt: "build", style: "vertical-align: middle;")) badges.

#{
  let catalog = json("/dist/catalog.json")
  assert.eq(catalog.version, "0.1.2")

  for (name, releases) in catalog.artifacts {
    let (repo, path) = if name == "docs" {
      ("typst", "/tree/main/docs")
    } else if name == "packages-bundler" {
      ("packages", "/tree/main/bundler")
    } else {
      (name, "")
    }

    [#[== #link("https://github.com/typst/" + repo + path, raw(name))] #label(name)]

    html.p({
      // Display the latest release
      // Skip the packages repo because it's untagged.
      if repo != "packages" {
        html.a(href: "https://github.com/typst/{repo}/releases/latest".replace("{repo}", repo), {
          html.img(
            src: (
              "https://img.shields.io/github/v/release/typst/{repo}?include_prereleases&style=flat-square&label=latest%20tag&color=249dad"
            ).replace("{repo}", repo),
            alt: "latest release",
          )
          html.img(
            src: (
              "https://img.shields.io/github/release-date-pre/typst/{repo}?display_date=published_at&style=flat-square&label=%20"
            ).replace("{repo}", repo),
            alt: "release date",
          )
        })
      }
      [ ]
      // Display the status of GitHub Actions
      link(
        "https://github.com/typst-community/dev-builds/actions/workflows/{}.yaml".replace("{}", name),
        html.img(
          src: "https://img.shields.io/github/actions/workflow/status/typst-community/dev-builds/{}.yaml?style=flat-square&logo=github".replace(
            "{}",
            name,
          ),
          alt: "build {}".replace("{}", name),
        ),
      )
    })

    list(
      ..releases.map(r => list.item[
        #link(r.releaseUrl, r.revision)
        (#link(r.officialUrl, {
          let tagged = r.officialUrl.contains("/releases/tag/")
          if tagged [release notes] else [tree]
        }))
      ]),
    )
  }
}
