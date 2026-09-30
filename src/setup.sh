#!/bin/sh
# The script logs in to Claude Code and to every MCP server that needs a
# login. It skips a login that the config volume already holds, so a second
# run changes nothing.
set -eu

if ! claude auth status > /dev/null 2>&1; then
    claude auth login
fi

servers="$(claude mcp list 2> /dev/null | sed -n 's/^\([A-Za-z0-9_-]*\): .*Needs authentication.*$/\1/p')"
for server in ${servers}; do
    claude mcp login "${server}" --no-browser
done

echo "setup complete"
