# incident-io-mcp-server

An MCP (Model Context Protocol) server for integrating with incident.io API. This server provides tools for incident management, user lookup, and workflow automation through Claude and other MCP-compatible AI assistants.

## Features

- **Incident Management**: List, view, and create incidents
- **User Lookup**: Search and list organization users
- **Metadata Access**: Get incident severities and statuses
- **Secure Authentication**: API key-based authentication with incident.io
- **Comprehensive Testing**: Full test suite with async support

## Quick Start

### Prerequisites

- Python 3.11.4 or higher
- pyenv (recommended for virtual environment management)
- incident.io API key

### Development Environment Setup

1. **Install Python and create virtual environment:**
   ```bash
   pyenv install 3.11.4
   pyenv virtualenv 3.11.4 incident-io-mcp-server
   pyenv activate incident-io-mcp-server
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up environment variables:**
   ```bash
   export INCIDENT_IO_API_KEY="your_incident_io_api_key_here"
   ```
   
   Or create a `.env` file (not tracked in git):
   ```bash
   echo "INCIDENT_IO_API_KEY=your_incident_io_api_key_here" > .env
   ```

### Running the MCP Server

**Option 1: Using Python module:**
```bash
python -m src.incident_io_mcp.server
```

**Option 2: Direct execution:**
```bash
python src/incident_io_mcp/server.py
```

The server will start and listen for MCP connections. You can then connect it to Claude Desktop or other MCP-compatible clients.

### Running Tests

**Run all tests:**
```bash
pytest
```

**Run tests with coverage:**
```bash
pytest --cov=src/incident_io_mcp
```

**Run specific test file:**
```bash
pytest tests/test_server.py
```

**Run tests in verbose mode:**
```bash
pytest -v
```

