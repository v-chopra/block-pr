#!/bin/bash
# Varun Chopra <vchopra@eightfold.ai>
#
# This action runs every time a label is added/removed/modified
# We check if labels needs_ci or needs_revision are present. These are blockers.

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Set the GITHUB_REPOSITORY env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "Set the GITHUB_EVENT_PATH env variable."
  exit 1
fi

URI="https://api.github.com"
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

body=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/${GITHUB_REPOSITORY}/pulls/${number}")

labels="$(echo "$body" | jq --raw-output '.labels[].name')"

for label in $labels; do
  case $label in
    needs_revision)
      echo "Needs revision!"
      exit 1
      ;;
    needs_test_plan)
      echo "Needs test plan!"
      exit 1
      ;;
    needs_ci)
      echo "Needs ci!"
      exit 1
      ;;
    *)
      echo "LGTM!"
      ;;
  esac
done