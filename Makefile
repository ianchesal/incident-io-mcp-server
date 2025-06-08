# Container runtime detection - prefer podman over docker
ifneq ($(shell which podman 2>/dev/null),)
    CONTAINER_RUNTIME := podman
    COMPOSE_CMD := podman-compose
    ifneq ($(shell which podman-compose 2>/dev/null),)
        COMPOSE_CMD := podman-compose
    else
        COMPOSE_CMD := podman compose
    endif
else ifneq ($(shell which docker 2>/dev/null),)
    CONTAINER_RUNTIME := docker
    COMPOSE_CMD := docker compose
else
    $(error Neither podman nor docker found. Please install one of them.)
endif

.PHONY: help build up dev test shell logs clean clean-deep typecheck lint security runtime-info

# Default target
help:
	@echo "Available commands:"
	@echo "  runtime-info - Show detected container runtime"
	@echo "  build      - Build all containers"
	@echo "  up         - Start the MCP server"
	@echo "  dev        - Start development environment"
	@echo "  test       - Run all tests"
	@echo "  test-cov   - Run tests with coverage report"
	@echo "  typecheck  - Run type checking with mypy"
	@echo "  lint       - Run code linting with flake8"
	@echo "  security   - Run security checks with bandit and safety"
	@echo "  shell      - Open shell in development container"
	@echo "  logs       - Show MCP server logs"
	@echo "  logs-f     - Follow MCP server logs"
	@echo "  clean      - Stop and remove all containers"
	@echo "  clean-deep - Deep clean: remove all containers, images, volumes, and build cache"
	@echo "  down       - Stop all services"

# Show detected container runtime
runtime-info:
	@echo "Using container runtime: $(CONTAINER_RUNTIME)"
	@echo "Using compose command: $(COMPOSE_CMD)"

# Build containers
build:
	$(COMPOSE_CMD) build

# Start MCP server
up:
	$(COMPOSE_CMD) up mcp-server

# Start MCP server in detached mode
up-d:
	$(COMPOSE_CMD) up -d mcp-server

# Start development environment
dev:
	$(COMPOSE_CMD) --profile dev up -d dev

# Run all tests
test:
	$(COMPOSE_CMD) --profile test run --rm test

# Run tests with coverage
test-cov:
	$(COMPOSE_CMD) --profile test run --rm test bash -c "pip install --no-warn-script-location pytest-cov && rm -f .coverage .coverage.* /tmp/.coverage* /tmp/coverage.xml && COVERAGE_PROCESS_START=/app/.coveragerc pytest --cov=src/incident_io_mcp --cov-report=xml --cov-report=term-missing --cov-config=/app/.coveragerc"

# Run type checking with mypy
typecheck:
	$(COMPOSE_CMD) --profile test run --rm test mypy src/incident_io_mcp/ --ignore-missing-imports

# Run code linting with flake8
lint:
	$(COMPOSE_CMD) --profile test run --rm test flake8 src/ tests/ --count --select=E9,F63,F7,F82 --show-source --statistics
	$(COMPOSE_CMD) --profile test run --rm test flake8 src/ tests/ --count --exit-zero --max-complexity=10 --max-line-length=127 --ignore=E501,W292 --statistics

# Run security checks with bandit and safety
security:
	@echo "Running security checks with bandit and safety..."
	$(COMPOSE_CMD) --profile test run --rm test bash -c "pip install --no-warn-script-location 'setuptools>=70.0.0' bandit safety && /home/developer/.local/bin/bandit -r src/ && /home/developer/.local/bin/safety check"

# Run specific test file (usage: make test-file FILE=test_server.py)
test-file:
	$(COMPOSE_CMD) --profile test run --rm test pytest tests/$(FILE) -v

# Open shell in development container
shell:
	$(COMPOSE_CMD) exec dev bash

# Show logs
logs:
	$(COMPOSE_CMD) logs mcp-server

# Follow logs
logs-f:
	$(COMPOSE_CMD) logs -f mcp-server

# Stop and remove containers
clean:
	$(COMPOSE_CMD) down --volumes --remove-orphans

# Deep clean: remove all project container artifacts
clean-deep:
	@echo "🧹 Deep cleaning all container artifacts for this project..."
	@echo "⏹️  Stopping all running containers..."
	-$(COMPOSE_CMD) --profile dev --profile test down --remove-orphans
	-$(CONTAINER_RUNTIME) stop incident-io-mcp-dev incident-io-mcp-dev-shell incident-io-mcp-test 2>/dev/null || true
	@echo "🗑️  Removing all project containers..."
	-$(CONTAINER_RUNTIME) rm -f incident-io-mcp-dev incident-io-mcp-dev-shell incident-io-mcp-test 2>/dev/null || true
	@echo "🏗️  Removing all project images..."
	-$(CONTAINER_RUNTIME) rmi -f incident-io-mcp-server-mcp-server incident-io-mcp-server-dev incident-io-mcp-server-test 2>/dev/null || true
	-$(CONTAINER_RUNTIME) rmi -f $$($(CONTAINER_RUNTIME) images --filter "reference=incident-io-mcp-server*" -q) 2>/dev/null || true
	@echo "💾 Removing all project volumes..."
	-$(CONTAINER_RUNTIME) volume rm incident-io-mcp-server_python-cache 2>/dev/null || true
	@echo "🔧 Removing compose networks..."
	-$(CONTAINER_RUNTIME) network rm incident-io-mcp-server_default 2>/dev/null || true
	@echo "🧽 Cleaning up build cache..."
	-$(CONTAINER_RUNTIME) builder prune -f --filter "label=stage=*" 2>/dev/null || true
	@echo "✨ Deep clean complete! All container artifacts for this project have been removed."

# Stop all services
down:
	$(COMPOSE_CMD) down

# Stop development profile
down-dev:
	$(COMPOSE_CMD) --profile dev down