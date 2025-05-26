.PHONY: help build up dev test shell logs clean clean-deep typecheck lint security

# Default target
help:
	@echo "Available commands:"
	@echo "  build      - Build all Docker containers"
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

# Build containers
build:
	docker compose build

# Start MCP server
up:
	docker compose up mcp-server

# Start MCP server in detached mode
up-d:
	docker compose up -d mcp-server

# Start development environment
dev:
	docker compose --profile dev up -d dev

# Run all tests
test:
	docker compose --profile test run --rm test

# Run tests with coverage
test-cov:
	docker compose --profile test run --rm test bash -c "pip install --no-warn-script-location pytest-cov && rm -f .coverage .coverage.* /tmp/.coverage* /tmp/coverage.xml && COVERAGE_PROCESS_START=/app/.coveragerc pytest --cov=src/incident_io_mcp --cov-report=xml --cov-report=term-missing --cov-config=/app/.coveragerc"

# Run type checking with mypy
typecheck:
	docker compose --profile test run --rm test mypy src/incident_io_mcp/ --ignore-missing-imports

# Run code linting with flake8
lint:
	docker compose --profile test run --rm test flake8 src/ tests/ --count --select=E9,F63,F7,F82 --show-source --statistics
	docker compose --profile test run --rm test flake8 src/ tests/ --count --exit-zero --max-complexity=10 --max-line-length=127 --ignore=E501,W292 --statistics

# Run security checks with bandit and safety
security:
	@echo "Running security checks with bandit and safety..."
	docker compose --profile test run --rm test bash -c "pip install --no-warn-script-location 'setuptools>=70.0.0' bandit safety && /home/developer/.local/bin/bandit -r src/ && /home/developer/.local/bin/safety check"

# Run specific test file (usage: make test-file FILE=test_server.py)
test-file:
	docker compose --profile test run --rm test pytest tests/$(FILE) -v

# Open shell in development container
shell:
	docker compose exec dev bash

# Show logs
logs:
	docker compose logs mcp-server

# Follow logs
logs-f:
	docker compose logs -f mcp-server

# Stop and remove containers
clean:
	docker compose down --volumes --remove-orphans

# Deep clean: remove all project Docker artifacts
clean-deep:
	@echo "🧹 Deep cleaning all Docker artifacts for this project..."
	@echo "⏹️  Stopping all running containers..."
	-docker compose --profile dev --profile test down --remove-orphans
	-docker stop incident-io-mcp-dev incident-io-mcp-dev-shell incident-io-mcp-test 2>/dev/null || true
	@echo "🗑️  Removing all project containers..."
	-docker rm -f incident-io-mcp-dev incident-io-mcp-dev-shell incident-io-mcp-test 2>/dev/null || true
	@echo "🏗️  Removing all project images..."
	-docker rmi -f incident-io-mcp-server-mcp-server incident-io-mcp-server-dev incident-io-mcp-server-test 2>/dev/null || true
	-docker rmi -f $$(docker images --filter "reference=incident-io-mcp-server*" -q) 2>/dev/null || true
	@echo "💾 Removing all project volumes..."
	-docker volume rm incident-io-mcp-server_python-cache 2>/dev/null || true
	@echo "🔧 Removing Docker Compose networks..."
	-docker network rm incident-io-mcp-server_default 2>/dev/null || true
	@echo "🧽 Cleaning up build cache..."
	-docker builder prune -f --filter "label=stage=*"
	@echo "✨ Deep clean complete! All Docker artifacts for this project have been removed."

# Stop all services
down:
	docker compose down

# Stop development profile
down-dev:
	docker compose --profile dev down