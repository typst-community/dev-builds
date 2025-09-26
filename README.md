# Typst dev builds

Unofficial builds of [Typst](https://typst.app/home) artifacts for development purposes.

Only x86_64 Linux (musl) and Windows binaries are offered for CLI programs. You can open an issue if you really need binaries for other platforms.

## Artifacts

```shell
gh workflow run
```

### [Documentation](https://github.com/typst-community/typst-docs-web)

```shell
gh run download --name docs.json

mkdir assets && cd assets
gh run download --name docs-assets
cd -
```

The base URL is set to `/DOCS-BASE/`. Please replace the string with your actual base URL. For example, [`sd '/DOCS-BASE/' '/' docs.json`](https://webinstall.dev/sd/).

### [Typst](https://typst.app/open-source/#download)

```shell
gh run download --name typst-x86_64-unknown-linux-musl
tar -xf typst-x86_64-unknown-linux-musl.tar.xz
./typst-x86_64-unknown-linux-musl/typst --version

gh run download --name typst-x86_64-pc-windows-msvc
unzip typst-x86_64-pc-windows-msvc.zip
./typst-x86_64-pc-windows-msvc/typst.exe --version
```

### [Typst package check](https://github.com/typst/package-check)

```shell
gh run download --name typst-package-check-x86_64-unknown-linux-musl
tar -xf typst-package-check-x86_64-unknown-linux-musl.tar.xz
./typst-package-check-x86_64-unknown-linux-musl/typst-package-check check --help

gh run download --name typst-package-check-x86_64-pc-windows-msvc
unzip typst-package-check-x86_64-pc-windows-msvc.zip
./typst-package-check-x86_64-pc-windows-msvc/typst-package-check.exe check --help
```

### [Hayagriva](https://github.com/typst/hayagriva)

```shell
gh run download --name hayagriva-x86_64-unknown-linux-musl
tar -xf hayagriva-x86_64-unknown-linux-musl.tar.xz
./hayagriva-x86_64-unknown-linux-musl/hayagriva --version

gh run download --name hayagriva-x86_64-pc-windows-msvc
unzip hayagriva-x86_64-pc-windows-msvc.zip
./hayagriva-x86_64-pc-windows-msvc/hayagriva.exe --version
```
