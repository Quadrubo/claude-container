FROM debian:trixie-slim

ARG CLAUDE_CODE_CHANNEL=stable
# Without a version, the build installs the newest version of the channel.
ARG CLAUDE_CODE_VERSION=

COPY keys/claude-code.asc /etc/apt/keyrings/claude-code.asc

# apt reaches the Claude Code repository over HTTPS, so ca-certificates
# installs before apt reads that repository.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git jq tini \
    && echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/${CLAUDE_CODE_CHANNEL} ${CLAUDE_CODE_CHANNEL} main" \
        > /etc/apt/sources.list.d/claude-code.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends "claude-code${CLAUDE_CODE_VERSION:+=${CLAUDE_CODE_VERSION}}" \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --uid 1000 --create-home --shell /bin/bash claude \
    && mkdir -p /home/claude/.claude /workspace /etc/claude-code \
    && chown claude:claude /home/claude/.claude /workspace /etc/claude-code

COPY --chmod=755 src/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 src/setup.sh /usr/local/bin/setup
COPY src/CLAUDE.md /usr/share/claude-container/CLAUDE.md

# With CLAUDE_CONFIG_DIR set, Claude Code writes .claude.json into the same
# directory, so one volume holds the login, the settings and the MCP servers.
ENV CLAUDE_CONFIG_DIR=/home/claude/.claude

USER claude
WORKDIR /workspace

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
