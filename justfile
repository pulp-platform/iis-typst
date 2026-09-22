# Copyright 2026 ETH Zurich.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author: Tim Fischer <fischeti@iis.ee.ethz.ch>

packages := "dissertation thesis research-plan assignment"

# List available recipes
default:
    @just --list

# Install a single package into the @local Typst namespace
link pkg:
    #!/usr/bin/env sh
    version=$(grep '^version' {{pkg}}/typst.toml | sed 's/version = "\(.*\)"/\1/')
    pkg_root=$(typst info --format json | jq -r '.packages["package-path"]')
    dest="$pkg_root/local/ethz-iis-{{pkg}}/$version"
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$(pwd)/{{pkg}}" "$dest"
    echo "🔗 @local/ethz-iis-{{pkg}}:$version → $(pwd)/{{pkg}}"

# Install all packages into the @local Typst namespace
link-all:
    @for pkg in {{packages}}; do just link $pkg; done

# Compile a single template
compile pkg:
    typst compile {{pkg}}/template/main.typ

# Compile all templates
compile-all:
    @for pkg in {{packages}}; do just compile $pkg; done

# Generate thumbnail for a single template
thumbnail pkg:
    typst compile -f png --pages 1 --ppi 250 \
        {{pkg}}/template/main.typ \
        {{pkg}}/thumbnail.png

# Generate thumbnails for all templates
thumbnail-all:
    @for pkg in {{packages}}; do just thumbnail $pkg; done

# Run typst-package-check on a single package
check pkg:
    typst-package-check check {{pkg}}

# Run typst-package-check on all packages
check-all:
    @for pkg in {{packages}}; do just check $pkg; done

# Check formatting (no modifications)
fmt-check:
    typstyle --check **/*.typ

# Format all .typ files in-place
fmt:
    typstyle -i **/*.typ


# Bump version — updates typst.toml and import strings, commits, and pushes.
# Previews by default; pass --execute / -x to actually apply, commit, and push.
[arg('ver_type', pattern='major|minor|patch')]
[arg('execute', long='execute', short='x', value='true')]
bump pkg ver_type execute='false':
    #!/usr/bin/env sh
    set -e
    current=$(grep '^version' {{pkg}}/typst.toml | sed 's/version = "\(.*\)"/\1/')
    major=$(echo "$current" | cut -d. -f1)
    minor=$(echo "$current" | cut -d. -f2)
    patch=$(echo "$current" | cut -d. -f3)
    case "{{ver_type}}" in
        major) major=$((major + 1)); minor=0; patch=0 ;;
        minor) minor=$((minor + 1)); patch=0 ;;
        patch) patch=$((patch + 1)) ;;
    esac
    new_ver="$major.$minor.$patch"
    run() { if [ "{{execute}}" = true ]; then "$@"; else echo "🙈 $*"; fi; }
    edit() { f=; for a in "$@"; do f=$a; done; run sed -i.bak "$@"; [ "{{execute}}" = true ] && rm -f "$f.bak"; return 0; }
    echo "🔖 Bumping {{pkg}} $current → $new_ver"
    edit "s/version = \"$current\"/version = \"$new_ver\"/" {{pkg}}/typst.toml
    for f in $(find {{pkg}}/template -name '*.typ'); do
        edit "s|ethz-iis-{{pkg}}:$current|ethz-iis-{{pkg}}:$new_ver|g" "$f"
    done
    if [ -f {{pkg}}/README.md ]; then
        edit "s|ethz-iis-{{pkg}}:$current|ethz-iis-{{pkg}}:$new_ver|g" {{pkg}}/README.md
    fi
    run git add {{pkg}}/
    run git commit -m "chore({{pkg}}): bump to v$new_ver"
    run git push
    echo "✅ Bumped — run 'just prepare {{pkg}} <fork>' then 'just release {{pkg}}' after PR is accepted"

# Stamp CHANGELOG, tag, and push — run after the Typst Universe PR is accepted.
# Previews by default; pass --execute / -x to actually apply, commit, tag, and push.
[arg('execute', long='execute', short='x', value='true')]
release pkg execute='false':
    #!/usr/bin/env sh
    set -e
    ver=$(grep '^version' {{pkg}}/typst.toml | sed 's/version = "\(.*\)"/\1/')
    rel_date=$(date +%Y-%m-%d)
    run() { if [ "{{execute}}" = true ]; then "$@"; else echo "🙈 $*"; fi; }
    # edit [sed-flags...] <expr> <file> — edits in place, removing the backup only on a real run
    edit() { f=; for a in "$@"; do f=$a; done; run sed -i.bak "$@"; [ "{{execute}}" = true ] && rm -f "$f.bak"; return 0; }
    echo "📝 Stamping CHANGELOG for {{pkg}} v$ver"
    edit -E "s/## (\[Unreleased\]|Unreleased)/## v$ver — $rel_date/" {{pkg}}/CHANGELOG.md
    run git add {{pkg}}/CHANGELOG.md
    run git commit -m "chore({{pkg}}): release v$ver"
    echo "🚀 Tagging {{pkg}} v$ver"
    run git tag "{{pkg}}/v$ver"
    run git push --follow-tags
    echo "✅ {{pkg}} v$ver released"

# Copy all packages into a local fork of typst/packages
prepare-all fork:
    @for pkg in {{packages}}; do just prepare $pkg {{fork}}; done

# Copy a package into a local fork of typst/packages, resolving symlinks in the process.
# Usage: just prepare dissertation /path/to/typst-packages
prepare pkg fork:
    #!/usr/bin/env sh
    set -e
    version=$(grep '^version' {{pkg}}/typst.toml | sed 's/version = "\(.*\)"/\1/')
    dest="{{fork}}/packages/preview/ethz-iis-{{pkg}}/$version"
    echo "📦 Copying {{pkg}} v$version to $dest"
    mkdir -p "$dest"
    rsync -rL --exclude='*.pdf' --exclude='CHANGELOG.md' {{pkg}}/ "$dest/"
    cp LICENSES/Apache-2.0.txt "$dest/LICENSE"
    echo "🔍 Running typst-package-check"
    typst-package-check check "$dest"
    echo "🏗️  Initialising template into temp directory"
    tmp=$(mktemp -d)
    typst init --package-path "{{fork}}/packages" "@preview/ethz-iis-{{pkg}}:$version" "$tmp/project"
    echo "⚙️  Compiling"
    typst compile --package-path "{{fork}}/packages" "$tmp/project/main.typ"
    rm -rf "$tmp"
    echo "✅ Done — commit and push in {{fork}}"
