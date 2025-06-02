#!/usr/bin/env bash
# Script to download asset file from tag release using GitHub API v3.
# See: http://stackoverflow.com/a/35688093/55075

# Echo welcome.
echo "#######################################"
echo "# WELCOME TO THE GH-ASSETS DOWNLOADER #"
echo "#######################################"

CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

# Check dependencies.
echo "Checking dependencies…"
echo "----------------------"
set -e
type curl grep sed tr >&2
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
echo ""

# Get ID of the asset based on given name.
echo "Getting ID of asset based on given name…"
echo "-----------------------------------------"
eval $(echo "$response" | grep -C3 "name.:.\+$name" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
#id=$(echo "$response" | jq --arg name "$name" '.assets[] | select(.name == $name).id') # If jq is installed, this can be used instead.
[ "$id" ] || { echo "Error: Failed to get asset id, response: $response" | awk 'length($0)<100' >&2; exit 1; }
GH_ASSET="$GH_REPO/releases/assets/$id"

# Download asset file.
echo "Downloading asset..." >&2
curl $CURL_ARGS -H "Authorization: token $GITHUB_API_TOKEN" -H 'Accept: application/octet-stream' "$GH_ASSET"
echo "$0 done." >&2echo "Downloading asset…"
echo "------------------"
echo ""
