# claude-container

The image runs a [Claude Code](https://code.claude.com) Remote Control
server. The Claude app and claude.ai/code start sessions in it, and each
session works in a git worktree of its own. It is published for amd64 and
arm64 at `ghcr.io/quadrubo/claude-container`, and each tag is the Claude
Code version it holds.

## Usage

`compose.prod.yaml` runs the image. It mounts `managed-settings.json` with
the MCP servers of the sessions. Copy `managed-settings.example.json` to
start it.

Remote Control needs a claude.ai login on a Pro, Max, Team or Enterprise
plan. `setup` logs in to Claude Code and to every MCP server once. Open
each printed URL in a browser and paste the result back at the prompt.

```sh
docker compose -f compose.prod.yaml run --rm claude setup
docker compose -f compose.prod.yaml up -d
```

### Variables

| Variable                 | Default    | Meaning                                                                                    |
| ------------------------ | ---------- | ------------------------------------------------------------------------------------------ |
| `REMOTE_NAME`            | none       | Title of the server in the session list.                                                   |
| `REMOTE_CAPACITY`        | `32`       | Sessions that run at the same time.                                                        |
| `REMOTE_SPAWN`           | `worktree` | `same-dir` runs every session in `/workspace` instead.                                     |
| `REMOTE_PERMISSION_MODE` | `default`  | Permission mode of new sessions, such as `acceptEdits`.                                    |
| `REMOTE_INSTRUCTIONS`    | none       | Instructions for every session, after the description of the container in `src/CLAUDE.md`. |

### Volumes

| Path                                     | Content                                                             |
| ---------------------------------------- | ------------------------------------------------------------------- |
| `/home/claude/.claude`                   | Login, MCP tokens and the sessions.                                 |
| `/workspace`                             | Git repository of the sessions.                                     |
| `/etc/claude-code/managed-settings.json` | MCP servers of the sessions, as in `managed-settings.example.json`. |

## Development

`compose.yaml` builds the image from the checkout. Copy
`managed-settings.example.json` to `managed-settings.json` before the first
start. Git ignores the copy.

```sh
just run setup   # log in once
just up          # start the server, just logs and just down follow
just check       # everything a commit must pass
```

The workflow reads the newest version of the `stable` channel from the apt
repository of Anthropic every six hours. It builds each new version and
publishes the tags `2.1.280`, `2.1` and `latest`. `keys/claude-code.asc`
is the signing key of that repository, with the fingerprint
`31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE`.

The entrypoint writes the answers to the trust dialog and to the Remote
Control question into `.claude.json`. The Remote Control answer uses the
undocumented key `remoteDialogSeen`. When a new Claude Code version waits
for that question again, `docker attach` shows it.
