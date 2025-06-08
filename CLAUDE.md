# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a fully functional MCP (Model Context Protocol) server implementation for incident.io integration. The server provides 6 tools for incident management and organizational data access through Bearer token authentication.

## Development Environment

This is a Python project with flexible container runtime support. The development setup features:
- **Container Runtime**: Automatic detection and support for both Docker and Podman (Podman preferred)
- **Compose**: Compatible with both `docker compose` and `podman compose`
- **Python Version**: Python 3.11 base image
- **Multi-service Setup**: Development, testing, and server containers with dedicated profiles
- **Volume Mounts**: Live code editing and debugging support
- **Environment**: Secure API key management via environment variables and .env files

## Project Status

The repository contains a fully functional MCP server implementation with:
- **API Integration**: Complete incident.io API integration with Bearer token authentication
- **MCP Tools**: 6 tools for incident management (list, get, create incidents, list users/severities/statuses)
- **Testing**: Comprehensive test suite with async support and coverage reporting
- **Container Support**: Flexible Docker/Podman development environment with runtime auto-detection
- **Quality Assurance**: Type checking (mypy), linting (flake8), and security checks (bandit/safety)
- **CI/CD**: GitHub Actions pipeline with testing, linting, and security checks
- **Documentation**: Complete README with security best practices and development workflows

## Development Guidelines

- **Commits**: Use conventional commit syntax for git commits
- **TODO Tracking**: Create a git commit after executing each TODO item for proper history
- **Container Commands**: Use `make` targets instead of direct container commands for consistency
- **Runtime Detection**: The Makefile automatically detects and uses the appropriate container runtime (docker/podman)
- **Testing**: Run quality checks with `make test`, `make typecheck`, `make lint`, and `make security`
- **Environment**: Use `make runtime-info` to verify detected container runtime

## Available Make Targets

Key development commands:
- `make runtime-info` - Show detected container runtime
- `make build` - Build all containers  
- `make dev` - Start development environment
- `make test` - Run all tests
- `make test-cov` - Run tests with coverage
- `make typecheck` - Run mypy type checking
- `make lint` - Run flake8 linting
- `make security` - Run bandit and safety checks
- `make shell` - Open development shell
- `make clean-deep` - Remove all project container artifacts
