# incident-io-mcp-server

An MCP (Model Context Protocol) server for integrating with incident.io API. This server provides tools for incident management, user lookup, and workflow automation through Claude and other MCP-compatible AI assistants.

## ⚠️ Security Warning

**🚨 DO NOT RUN THIS SERVER ON THE OPEN INTERNET 🚨**

This MCP server provides **NO AUTHENTICATION** on its tool APIs. Anyone who can reach the server can:
- List all incidents in your organization
- View sensitive incident details
- Create new incidents
- Access user information
- View organizational data (severities, statuses)

**Safe Usage:**
- ✅ Run only on localhost/127.0.0.1
- ✅ Use in local development environments
- ✅ Deploy behind proper authentication/VPN
- ❌ Never expose directly to the internet
- ❌ Never run on public cloud instances without proper network security

**This server is designed for local development and secure, authenticated environments only.**

## Features

- **Incident Management**: List, view, and create incidents
- **User Lookup**: Search and list organization users
- **Metadata Access**: Get incident severities and statuses
- **Secure Authentication**: Bearer token authentication with incident.io API
- **Comprehensive Testing**: Full test suite with async support
- **Container Runtime Flexibility**: Automatic detection and support for both Docker and Podman

## Authentication

This MCP server uses **Bearer token authentication** with the incident.io API. All API requests include an `Authorization: Bearer <YOUR_API_KEY>` header for secure authentication.

The server supports multiple secure methods for providing your API key and automatically loads environment variables from `.env` files for development convenience.

## Quick Start

### Prerequisites

- **Container Runtime**: Docker or Podman (automatically detected)
- **Compose**: docker compose or podman compose
- **Make**: Usually pre-installed on macOS/Linux
- **API Key**: incident.io API key

### Development Environment Setup

1. **Clone the repository:**
   ```bash
   git clone git@github.com:ianchesal/incident-io-mcp-server.git
   cd incident-io-mcp-server
   ```

2. **Check container runtime and build:**
   ```bash
   make runtime-info  # See which runtime is detected (docker/podman)
   make build         # Build all containers
   ```

   > **Note**: The Makefile automatically detects whether you have Docker or Podman installed and uses the appropriate commands. Podman is preferred over Docker if both are available.

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

**Option 1: Run the MCP server (recommended):**
```bash
make up
```

**Option 2: Run in detached mode:**
```bash
make up-d
```

**Option 3: Run with custom environment:**
```bash
INCIDENT_IO_API_KEY=your_api_key make up
```

The server will start and listen for MCP connections. You can then connect it to Claude Desktop or other MCP-compatible clients.

### Development Workflow

**Start development environment:**
```bash
make dev
```

**Open development shell:**
```bash
make shell
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
make down-dev
```

### Running Tests

**Run all tests:**
```bash
make test
```

**Run tests with coverage:**
```bash
make test-cov
```

**Run specific test file:**
```bash
make test-file FILE=test_server.py
```

**Run tests interactively in development container:**
```bash
make dev
make shell
# Inside container:
pytest -v
```

### Debugging

**Access logs:**
```bash
make logs      # Show logs
make logs-f    # Follow logs
```

**Interactive debugging:**
```bash
# Start development environment and open shell
make dev
make shell

# Inside container - run with debugger
python -m pdb -m src.incident_io_mcp.server
```

### Available Make Commands

Run `make help` to see all available commands:

```bash
make help
```

**Core commands:**
- `make runtime-info` - Show detected container runtime (docker/podman)
- `make build` - Build all containers
- `make up` - Start MCP server
- `make up-d` - Start MCP server in detached mode
- `make dev` - Start development environment
- `make shell` - Open development shell

**Testing and Quality:**
- `make test` - Run all tests
- `make test-cov` - Run tests with coverage report
- `make test-file FILE=test_server.py` - Run specific test file
- `make typecheck` - Run type checking with mypy
- `make lint` - Run code linting with flake8
- `make security` - Run security checks with bandit and safety

**Utility:**
- `make logs` - View server logs
- `make logs-f` - Follow server logs
- `make down` - Stop all services
- `make down-dev` - Stop development profile
- `make clean` - Stop and remove all containers
- `make clean-deep` - Deep clean: remove all containers, images, volumes, and build cache

