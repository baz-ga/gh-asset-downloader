#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# gh-ref-type-checker
# -----------------------------------------------------------------------------
# A script to check if a given GitHub reference is a release tag or a branch.
# Version: 1.0.0
# Date: 2025-06-26
#Author: Benjamin W. Bohl <https://github.com/bwbohl>
# Publisher: Bernd Alois Zimmermann-Gesamtausgabe <https://github.com/baz-ga>

# -----------------------------------------------------------------------------
# License: GNU General Public License v3.0
# --------------------------------------------------------------------------------
#
# Copyright (C) 2025 Benjamin W. Bohl <https://github.com/bwbohl>
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
# -----------------------------------------------------------------------------# Exit Codes:
# Usage: gh-ref-type-checker.sh [owner] [repo] [ref_or_tag]
# Example:
# gh-ref-type-checker.sh bwbohl gh-asset-downloader 1.0.0
#
# Exit codes:
# 0: Reference is a release
# 1: Reference is a branch
# 2: Reference not found (neither release nor branch)
# 3: API error or invalid input
# -----------------------------------------------------------------------------
# Script starts here.
# ------------------------------------------------------------------------------

# Enable strict mode for robust error handling
set -euo pipefail

# Validate settings.
[ -f ~/.secrets ] && source ~/.secrets || true # Source secrets if they exist, but don't fail if not.
[ -z "${GITHUB_API_TOKEN:-}" ] && { echo "Error: GITHUB_API_TOKEN variable is not defined." >&2; exit 3; }
[ $# -ne 3 ] && { echo "Usage: $0 [owner] [repo] [ref_or_tag]" >&2; exit 3; }

# Set variables from arguments
owner=$1
repo=$2
ref_or_tag=$3

# GitHub API settings
GH_API="https://api.github.com"
GH_REPO="$GH_API/repos/$owner/$repo"
FORMAT="Accept: application/vnd.github+json"
AUTH="Authorization: Bearer $GITHUB_API_TOKEN"
API_VERSION="X-GitHub-Api-Version: 2022-11-28"

# Try to fetch as a release tag
RELEASE_URL=""
if [ "$ref_or_tag" = "release-latest" ]; then
  RELEASE_URL="$GH_REPO/releases/latest"
else
  RELEASE_URL="$GH_REPO/releases/tags/$ref_or_tag"
fi

RELEASE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -L -H "$FORMAT" -H "$AUTH" -H "$API_VERSION" "$RELEASE_URL" || echo "000")

if [ "$RELEASE_STATUS" -eq 200 ]; then exit 0; # Reference is a release
elif [ "$RELEASE_STATUS" -eq 404 ]; then
  BRANCH_URL="$GH_REPO/branches/$ref_or_tag"
  BRANCH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -L -H "$FORMAT" -H "$AUTH" -H "$API_VERSION" "$BRANCH_URL" || echo "000")
  if [ "$BRANCH_STATUS" -eq 200 ]; then exit 1; # Reference is a branch
  else exit 2; # Reference is not found
  fi
else
  echo "Error: Failed to connect to GitHub API or unexpected status for release check ($RELEASE_STATUS)." >&2
  exit 3 # API error
fi
