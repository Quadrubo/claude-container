#!/bin/sh
# The script starts the Remote Control server of Claude Code. A command in
# the arguments runs instead of the server, such as `claude auth login`.
set -eu

config="${CLAUDE_CONFIG_DIR}/.claude.json"

# Claude Code keeps the answers of the trust dialog and of the Remote Control
# question in .claude.json. The script writes both answers, so the server
# starts without questions.
if [ ! -s "${config}" ]; then
    (umask 077 && echo '{}' > "${config}")
fi
if ! jq -e '.remoteDialogSeen == true and .projects["/workspace"].hasTrustDialogAccepted == true' "${config}" > /dev/null; then
    (umask 077 && jq '.remoteDialogSeen = true | .projects["/workspace"].hasTrustDialogAccepted = true' "${config}" > "${config}.tmp")
    mv "${config}.tmp" "${config}"
fi

# Claude Code loads /etc/claude-code/CLAUDE.md in every session. The script
# writes the description of the container and REMOTE_INSTRUCTIONS into it.
{
    cat /usr/share/claude-container/CLAUDE.md
    if [ -n "${REMOTE_INSTRUCTIONS:-}" ]; then
        printf '\n# Instructions\n\n%s\n' "${REMOTE_INSTRUCTIONS}"
    fi
} > /etc/claude-code/CLAUDE.md

if [ "$#" -gt 0 ]; then
    exec "$@"
fi

spawn="${REMOTE_SPAWN:-worktree}"

# A worktree session needs a git repository with a commit. The script
# creates both when /workspace has no commit.
if [ "${spawn}" = worktree ] && ! git -C /workspace rev-parse --verify --quiet HEAD > /dev/null 2>&1; then
    git -C /workspace init --quiet
    git -C /workspace -c user.name=claude -c user.email=claude@localhost \
        commit --quiet --allow-empty --message "chore: create the workspace"
fi

set -- claude remote-control \
    --spawn "${spawn}" \
    --permission-mode "${REMOTE_PERMISSION_MODE:-default}"

if [ -n "${REMOTE_CAPACITY:-}" ]; then
    set -- "$@" --capacity "${REMOTE_CAPACITY}"
fi

if [ -n "${REMOTE_NAME:-}" ]; then
    set -- "$@" --name "${REMOTE_NAME}"
fi

exec "$@"
