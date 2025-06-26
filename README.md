# gh-asset-downloader

_gh-asset-downloader_ is a bash script for downloading a specific asset from a tagged GitHub repository release using GitHub API v3.

## Usage

### gh-asset-downloader.sh

The script call needs four parameters:

```bash
gh-asset-downloader.sh [owner] [repo] [tag] [name]
```
With real values this could be:

```bash
gh-asset-downloader.sh baz-ga gh-asset-downloader 1.0.0 asset.tar.gz
```

> [!NOTE]
> This script requires curl, grep, sed, awk, and xargs (or gxargs).
> But it will check for these when run.

### gh-ref-type-checker.sh

The script call needs three parameters:

```bash
gh-ref-type-checker.sh [owner] [repo] [ref]
````
With real values this could be:

```bash
gh-ref-type-checker.sh baz-ga gh-asset-downloader 1.0.0
````

The scipt uses exit codes to encode the github reference type and errors:

* `0`: Reference is a release
* `1`: Reference is a branch
* `2`: Reference not found (neither release nor branch)
* `3`: API error or invalid input

## Licenses

This software is being published under the terms of the _GNU General Public License 3_ ([GPLv3](LICENSE-GPLv3.md)).[^1]

## Acknowledgements

The code as published und the semantic version [1.0.0](https://github.com/baz-ga/gh-asset-downloader/releases/tag/1.0.0) was originally published by @kenorb at [_Stack Overflow_](http://stackoverflow.com/a/35688093/55075) and thus – according to the [Public Network Terms of Service](https://stackoverflow.com/legal/terms-of-service/public) – under the [_Creative Commons Attribution-ShareAlike 4.0 International_](LICENSE-CC-BY_SA-4.0) license.[^1]

---
[^1] The ([GPLv3](LICENSE-GPLv3.md)) license was declared a compatible license to as of 8 October 2015 and added to the [CC compatible license page](https://creativecommons.org/share-your-work/licensing-considerations/compatible-licenses/).