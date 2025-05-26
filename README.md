# incident-io-mcp-server

An MCP (Model Context Protocol) server for integrating with incident.io API. This server provides tools for incident management, user lookup, and workflow automation through Claude and other MCP-compatible AI assistants.

## Features

- **Incident Management**: List, view, and create incidents
- **User Lookup**: Search and list organization users
- **Metadata Access**: Get incident severities and statuses
- **Secure Authentication**: Bearer token authentication with incident.io API
- **Comprehensive Testing**: Full test suite with async support

## Authentication

This MCP server uses **Bearer token authentication** with the incident.io API. All API requests include an `Authorization: Bearer <YOUR_API_KEY>` header for secure authentication.

The server supports multiple secure methods for providing your API key and automatically loads environment variables from `.env` files for development convenience.

## Quick Start

### Prerequisites

- Docker and Docker Compose
- incident.io API key

### Development Environment Setup

1. **Clone the repository:**
   ```bash
   git clone git@github.com:ianchesal/incident-io-mcp-server.git
   cd incident-io-mcp-server
   ```

2. **Build the development container:**
   ```bash
   docker-compose build
   ```

3. **Configure your incident.io API key securely:**

   First, obtain your API key from the [incident.io dashboard](https://app.incident.io/settings/api-keys).

   **🔐 Secure Configuration Options (choose one):**

   **Option A: Environment Variable (Recommended for production)**
   ```bash
   export INCIDENT_IO_API_KEY="your_incident_io_api_key_here"
   ```

   **Option B: .env File (Recommended for development)**
   ```bash
   # Copy the example file and edit with your API key
   cp .env.example .env
   # Then edit .env with your actual API key
   ```

   **Option C: Runtime Environment Variable**
   ```bash
   # Set the API key when running the server
   INCIDENT_IO_API_KEY="your_api_key" python -m src.incident_io_mcp.server
   ```

   **⚠️ Security Best Practices:**
   - **Never commit API keys to version control**
   - **Use environment variables in production environments**
   - **Rotate API keys regularly**
   - **Use the principle of least privilege** - create API keys with only the permissions needed
   - **Store API keys securely** using your organization's secret management system

### Running the MCP Server

**Option 1: Run with docker-compose (recommended):**
```bash
docker-compose up mcp-server
```

**Option 2: Run in detached mode:**
```bash
docker-compose up -d mcp-server
```

**Option 3: Run with custom environment:**
```bash
INCIDENT_IO_API_KEY=your_api_key docker-compose up mcp-server
```

The server will start and listen for MCP connections. You can then connect it to Claude Desktop or other MCP-compatible clients.

### Development Workflow

**Start a development shell:**
```bash
# Start development container with shell access
docker-compose --profile dev up -d dev
docker-compose exec dev bash
```

**Run commands inside the container:**
```bash
# Inside the development container
python -m src.incident_io_mcp.server  # Run the server
pytest                                # Run tests
python -c "import src.incident_io_mcp.server; print('Import successful')"  # Test imports
```

**Stop development containers:**
```bash
docker-compose --profile dev down
```

### Running Tests

**Run all tests (using docker-compose profile):**
```bash
docker-compose --profile test run --rm test
```

**Run tests with coverage:**
```bash
docker-compose --profile test run --rm test pytest --cov=src/incident_io_mcp --cov-report=term-missing
```

**Run specific test file:**
```bash
docker-compose --profile test run --rm test pytest tests/test_server.py -v
```

**Run tests interactively in development container:**
```bash
docker-compose --profile dev up -d dev
docker-compose exec dev pytest -v
```

### Debugging

**Access logs:**
```bash
docker-compose logs mcp-server
docker-compose logs -f mcp-server  # Follow logs
```

**Interactive debugging:**
```bash
# Start development container with shell
docker-compose --profile dev up -d dev
docker-compose exec dev bash

# Inside container - run with debugger
python -m pdb -m src.incident_io_mcp.server
```

