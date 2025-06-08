# Container runtime detection - prefer podman over docker
ifneq ($(shell which podman 2>/dev/null),)
    CONTAINER_RUNTIME := podman
    COMPOSE_CMD := podman compose
else ifneq ($(shell which docker 2>/dev/null),)
    CONTAINER_RUNTIME := docker
    COMPOSE_CMD := docker compose
else
    $(error Neither podman nor docker found. Please install one of them.)
endif

.PHONY: help build up up-d dev test test-cov test-file shell logs logs-f clean clean-deep typecheck lint security runtime-info down down-dev

# Default target
help:
	@echo "Available commands:"
	@echo ""
	@echo "🏗️  Build & Runtime:"
	@echo "  runtime-info - Show detected container runtime (docker/podman)"
	@echo "  build        - Build all containers"
	@echo ""
	@echo "🚀 Server Operations:"
	@echo "  up           - Start the MCP server (foreground)"
	@echo "  up-d         - Start the MCP server (detached/background)"
	@echo "  down         - Stop all services"
	@echo ""
	@echo "🛠️  Development:"
	@echo "  dev          - Start development environment"
	@echo "  down-dev     - Stop development environment"
	@echo "  shell        - Open shell in development container"
	@echo ""
	@echo "🧪 Testing & Quality:"
	@echo "  test         - Run all tests"
	@echo "  test-cov     - Run tests with coverage report"
	@echo "  test-file    - Run specific test file (usage: make test-file FILE=test_server.py)"
	@echo "  typecheck    - Run type checking with mypy"
	@echo "  lint         - Run code linting with flake8"
	@echo "  security     - Run security checks with bandit and safety"
	@echo ""
	@echo "📋 Monitoring:"
	@echo "  logs         - Show MCP server logs"
	@echo "  logs-f       - Follow MCP server logs (real-time)"
	@echo ""
	@echo "🧹 Cleanup:"
	@echo "  clean        - Stop and remove all containers"
	@echo "  clean-deep   - Deep clean: remove all containers, images, volumes, and build cache"

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
ifeq ($(CONTAINER_RUNTIME), podman)
	$(CONTAINER_RUNTIME) build -t incident-io-mcp-dev . && \
	$(CONTAINER_RUNTIME) run -d --replace --name incident-io-mcp-dev-shell -v $(PWD):/app -e INCIDENT_IO_API_KEY=test-key-for-development -e LOG_LEVEL=DEBUG incident-io-mcp-dev tail -f /dev/null
else
	$(COMPOSE_CMD) --profile dev up -d dev
endif

# Run all tests
test:
ifeq ($(CONTAINER_RUNTIME), podman)
	$(CONTAINER_RUNTIME) build -t incident-io-mcp-test . && \
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/app -e INCIDENT_IO_API_KEY=test-key-for-ci incident-io-mcp-test pytest -v
else
	$(COMPOSE_CMD) --profile test run --rm test
endif

# Run tests with coverage
test-cov:
ifeq ($(CONTAINER_RUNTIME), podman)
	$(CONTAINER_RUNTIME) build -t incident-io-mcp-test . && \
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/app -e INCIDENT_IO_API_KEY=test-key-for-ci incident-io-mcp-test bash -c "pip install --no-warn-script-location pytest-cov && rm -f .coverage .coverage.* /tmp/.coverage* /tmp/coverage.xml && COVERAGE_PROCESS_START=/app/.coveragerc pytest --cov=src/incident_io_mcp --cov-report=xml --cov-report=term-missing --cov-config=/app/.coveragerc"
else
	$(COMPOSE_CMD) --profile test run --rm test bash -c "pip install --no-warn-script-location pytest-cov && rm -f .coverage .coverage.* /tmp/.coverage* /tmp/coverage.xml && COVERAGE_PROCESS_START=/app/.coveragerc pytest --cov=src/incident_io_mcp --cov-report=xml --cov-report=term-missing --cov-config=/app/.coveragerc"
endif

# Run type checking with mypy
typecheck:
ifeq ($(CONTAINER_RUNTIME), podman)
	$(CONTAINER_RUNTIME) build -t incident-io-mcp-test . && \
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/app -e INCIDENT_IO_API_KEY=test-key-for-ci incident-io-mcp-test mypy src/incident_io_mcp/ --ignore-missing-imports
else
	$(COMPOSE_CMD) --profile test run --rm test mypy src/incident_io_mcp/ --ignore-missing-imports
endif

# Run code linting with flake8
lint:
ifeq ($(CONTAINER_RUNTIME), podman)
	$(CONTAINER_RUNTIME) build -t incident-io-mcp-test . && \
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/app -e INCIDENT_IO_API_KEY=test-key-for-ci incident-io-mcp-test flake8 src/ tests/ --count --select=E9,F63,F7,F82 --show-source --statistics && \
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/app -e INCIDENT_IO_API_KEY=test-key-for-ci incident-io-mcp-test flake8 src/ tests/ --count --exit-zero --max-complexity=10 --max-line-length=127 --ignore=E501,W292 --statistics
else
	$(COMPOSE_CMD) --profile test run --rm test flake8 src/ tests/ --count --select=E9,F63,F7,F82 --show-source --statistics
	$(COMPOSE_CMD) --profile test run --rm test flake8 src/ tests/ --count --exit-zero --max-complexity=10 --max-line-length=127 --ignore=E501,W292 --statistics
endif

# Run security checks with bandit and safety
security:
	@echo "Running security checks with bandit and safety..."
ifeq ($(CONTAINER_RUNTIME), podman)
	$(CONTAINER_RUNTIME) build -t incident-io-mcp-test . && \
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/app -e INCIDENT_IO_API_KEY=test-key-for-ci incident-io-mcp-test bash -c "pip install --no-warn-script-location 'setuptools>=70.0.0' bandit safety && /home/developer/.local/bin/bandit -r src/ && /home/developer/.local/bin/safety check"
else
	$(COMPOSE_CMD) --profile test run --rm test bash -c "pip install --no-warn-script-location 'setuptools>=70.0.0' bandit safety && /home/developer/.local/bin/bandit -r src/ && /home/developer/.local/bin/safety check"
endif

# Run specific test file (usage: make test-file FILE=test_server.py)
test-file:
ifeq ($(CONTAINER_RUNTIME), podman)
	$(CONTAINER_RUNTIME) build -t incident-io-mcp-test . && \
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/app -e INCIDENT_IO_API_KEY=test-key-for-ci incident-io-mcp-test pytest tests/$(FILE) -v
else
	$(COMPOSE_CMD) --profile test run --rm test pytest tests/$(FILE) -v
endif

# Open shell in development container
shell:
ifeq ($(CONTAINER_RUNTIME), podman)
	$(CONTAINER_RUNTIME) exec -it incident-io-mcp-dev-shell bash
else
	$(COMPOSE_CMD) exec dev bash
endif

# Show logs
logs:
	$(COMPOSE_CMD) logs mcp-server

# Follow logs
logs-f:
	$(COMPOSE_CMD) logs -f mcp-server

# Stop and remove containers
clean:
ifeq ($(CONTAINER_RUNTIME), podman)
	-$(CONTAINER_RUNTIME) stop incident-io-mcp-dev-shell 2>/dev/null || true
	-$(CONTAINER_RUNTIME) rm incident-io-mcp-dev-shell 2>/dev/null || true
else
	$(COMPOSE_CMD) down --volumes --remove-orphans
endif

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