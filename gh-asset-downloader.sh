#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# gh-asset-downloader
# -----------------------------------------------------------------------------
# A script for downloading a specific asset from a tagged GitHub
# repository release using GitHub API v3.
# Version: 1.0.1
# Date: 2025-06-02
# Author: Rafal W. <https://github.com/kenorb>
# Contributors: Benjamin W. Bohl <https://github.com/bwbohl>
# Publisher: Bernd Alois Zimmermann-Gesamtausgabe <https://github.com/baz-ga>
#
# -----------------------------------------------------------------------------
# License starting with version 1.0.1: https://opensource.org/license/GPL-3.0
# -----------------------------------------------------------------------------
#
# Copyright (C) 2025 Rafal W. <https://github.com/kenorb> and
# Benjamin W. Bohl <https://github.com/bwbohl>
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script.  If not, see <http://www.gnu.org/licenses/>.
#
# -----------------------------------------------------------------------------
# Usage: gh-asset-downloader.sh [owner] [repo] [tag] [name]
# Example:
# gh-asset-downloader.sh bwbohl gh-asset-downloader 1.0.0 asset.tar.gz
# Note:
# This script requires curl, grep, sed, awk, and xargs (or gxargs).
# -----------------------------------------------------------------------------
# Script starts here.
# -----------------------------------------------------------------------------

# Echo welcome.
echo "#######################################"
echo "# WELCOME TO THE GH-ASSETS DOWNLOADER #"
echo "#######################################"

CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

# Check dependencies.
echo "Checking dependencies…"
echo "----------------------"
set -e
type awk curl grep sed tr >&2
xargs=$(which gxargs || which xargs)
echo ""

# Validate settings.
[ -f ~/.secrets ] && source ~/.secrets
[ "$GITHUB_API_TOKEN" ] || { echo "Error: Please define GITHUB_API_TOKEN variable." >&2; exit 1; }
[ $# -ne 4 ] && { echo "Usage: $0 [owner] [repo] [tag] [name]"; exit 1; }
[ "$TRACE" ] && set -x
read owner repo tag name <<<$@

# Define variables.
GH_API="https://api.github.com"
GH_REPO="$GH_API/repos/$owner/$repo"
GH_TAGS="$GH_REPO/releases/tags/$tag"
AUTH="Authorization: token $GITHUB_API_TOKEN"
WGET_ARGS="--content-disposition --auth-no-challenge --no-cookie"
CURL_ARGS="-LJO#"

curl -o /dev/null -sH "$AUTH" $GH_REPO || { echo "Error: Invalid repo, token or network issue!";  exit 1; }
# Echo variables for debugging.
echo "Variables are…"
echo "--------------"
echo "GH_API:    $GH_API"
echo "GH_REPO:   $GH_REPO"
echo "GH_TAGS:   $GH_TAGS"
echo "AUTH:      $AUTH"
echo "CURL_ARGS: $CURL_ARGS"
echo ""

# Validate GitHub API token.
echo "Validating GitHub API token."
echo "------------------------"
echo ""

# Read asset tags.
response=$(curl -sH "$AUTH" $GH_TAGS)
echo "Reading Asset Tags…"
echo "-------------------"
echo $response
echo ""

# Get ID of the asset based on given name.
echo "Getting ID of asset based on given name…"
echo "-----------------------------------------"
eval $(echo "$response" | grep -C3 "name.:.\+$name" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
#id=$(echo "$response" | jq --arg name "$name" '.assets[] | select(.name == $name).id') # If jq is installed, this can be used instead.
[ "$id" ] || { echo "Error: Failed to get asset id, response: $response" | awk 'length($0)<100' >&2; exit 1; }
GH_ASSET="$GH_REPO/releases/assets/$id"
echo "$id"
echo ""

# Download asset file.
echo "Downloading asset..." >&2
curl $CURL_ARGS -H "Authorization: token $GITHUB_API_TOKEN" -H 'Accept: application/octet-stream' "$GH_ASSET"
echo "$0 done." >&2echo "Downloading asset…"
echo "Downloading asset…"
echo "------------------"
echo "$0 done."
echo ""
