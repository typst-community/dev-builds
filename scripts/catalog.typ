#set document(
  title: "Typst dev builds",
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

= Artifacts in #link("https://github.com/typst-community/dev-builds/releases")[GitHub Releases] <artifacts>
#{
  let catalog = json("/dist/catalog.json")
  assert.eq(catalog.version, "0.1.1")

  for (name, releases) in catalog.artifacts {
    let repo = if name != "docs" { name } else { "typst" }

    link("https://github.com/typst/" + repo)[#[== #raw(name)] #label(name)]

    html.p({
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
