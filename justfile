# Includes everything a commit must pass.
check: lint

lint:
    shellcheck --shell=sh src/entrypoint.sh src/setup.sh

# Development
build:
    docker compose build

up:
    docker compose up --build --detach

down *args:
    docker compose down {{ args }}

logs:
    docker compose logs --follow

# Runs a command in the development container, such as `just run setup`.
run *args:
    docker compose run --rm --build claude {{ args }}

# Git
install-hooks:
    git config core.hooksPath .githooks
    @echo "hooks installed"
