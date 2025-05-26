.PHONY: help build up dev test shell logs clean typecheck lint security

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
	docker compose --profile test run --rm test pytest --cov=src/incident_io_mcp --cov-report=xml --cov-report=term-missing

# Run type checking with mypy
typecheck:
	docker compose --profile test run --rm test mypy src/incident_io_mcp/ --ignore-missing-imports

# Run code linting with flake8
lint:
	docker compose --profile test run --rm test flake8 src/ tests/ --count --select=E9,F63,F7,F82 --show-source --statistics
	docker compose --profile test run --rm test flake8 src/ tests/ --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

# Run security checks with bandit and safety
security:
	@echo "Running security checks with bandit and safety..."
	docker compose --profile test run --rm test bash -c "pip install bandit safety && /home/developer/.local/bin/bandit -r src/ && /home/developer/.local/bin/safety check"

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

# Stop all services
down:
	docker compose down

# Stop development profile
down-dev:
	docker compose --profile dev down