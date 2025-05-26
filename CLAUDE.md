# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an MCP (Model Context Protocol) server implementation for incident.io integration. The project is currently in its initial setup phase.

## Development Environment

This is a Python project using Docker for development and deployment. The development setup uses:
- Docker and Docker Compose for containerized development
- Python 3.11 base image
- Multi-service setup with development, testing, and server containers
- Volume mounts for live code editing and debugging

## Project Status

The repository contains a fully functional MCP server implementation with:
- Complete incident.io API integration with Bearer token authentication
- 6 MCP tools for incident management (list, get, create incidents, list users/severities/statuses)
- Comprehensive test suite with async support
- Docker-based development environment with docker-compose
- GitHub Actions CI/CD pipeline with testing, linting, and security checks

## Development Guidelines

- Use conventional commit syntax for git commits
- Create a git commit after you execute each TODO item so there is a git commit history to undo from