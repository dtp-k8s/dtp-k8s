#!/usr/bin/env bash
# Template script for scripts that must be sourced, not executed directly.

if ! (return 0 2>/dev/null); then
  echo "$(basename "${BASH_SOURCE[0]}"): Use \`source\` to run this file"
  exit 1
fi

echo "This script is being sourced correctly."
