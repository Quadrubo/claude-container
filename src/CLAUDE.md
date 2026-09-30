# Session environment

This session runs in a Claude Code Remote Control server inside a
container. The user connects to it through the Claude app or
claude.ai/code.

- The working directory is `/workspace` or a git worktree below it. The git
  repository there only keeps parallel sessions apart. It is not a project
  of the user.
- The MCP servers of the session come from the configuration of the
  container.
- Shell commands run in the container, a Debian system with git, curl and
  jq. The container has no access to the computer of the user.
