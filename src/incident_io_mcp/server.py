"""Incident.io MCP Server Implementation"""

import os
import logging
from typing import Any, Dict, List, Optional
import asyncio

from mcp.server.fastmcp import FastMCP
from mcp.server.models import ServerError
import httpx
from dotenv import load_dotenv


class IncidentIOClient:
    """Client for interacting with incident.io API"""
    
    def __init__(self, api_key: str, base_url: str = "https://api.incident.io"):
        self.api_key = api_key
        self.base_url = base_url
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
    
    async def _make_request(self, method: str, endpoint: str, **kwargs) -> Dict[str, Any]:
        """Make an HTTP request to the incident.io API"""
        url = f"{self.base_url}{endpoint}"
        
        async with httpx.AsyncClient() as client:
            try:
                response = await client.request(
                    method=method,
                    url=url,
                    headers=self.headers,
                    **kwargs
                )
                response.raise_for_status()
                return response.json()
            except httpx.HTTPStatusError as e:
                raise ServerError(f"API request failed: {e.response.status_code} - {e.response.text}")
            except Exception as e:
                raise ServerError(f"Request failed: {str(e)}")


# Initialize the MCP server
mcp = FastMCP("Incident.io MCP Server")


@mcp.tool()
async def list_incidents(
    page_size: int = 25,
    after: Optional[str] = None,
    status: Optional[str] = None
) -> str:
    """
    List incidents from incident.io
    
    Args:
        page_size: Number of incidents to return (max 100, default 25)
        after: Pagination cursor for fetching next page
        status: Filter by incident status (e.g., 'open', 'closed')
    
    Returns:
        JSON string containing the list of incidents
    """
    api_key = os.getenv("INCIDENT_IO_API_KEY")
    if not api_key:
        raise ServerError("INCIDENT_IO_API_KEY environment variable not set")
    
    client = IncidentIOClient(api_key)
    
    params = {"page_size": min(page_size, 100)}
    if after:
        params["after"] = after
    if status:
        params["status"] = status
    
    try:
        result = await client._make_request("GET", "/v2/incidents", params=params)
        return str(result)
    except Exception as e:
        raise ServerError(f"Failed to list incidents: {str(e)}")


@mcp.tool()
async def get_incident(incident_id: str) -> str:
    """
    Get details for a specific incident
    
    Args:
        incident_id: The unique identifier for the incident
    
    Returns:
        JSON string containing incident details
    """
    api_key = os.getenv("INCIDENT_IO_API_KEY")
    if not api_key:
        raise ServerError("INCIDENT_IO_API_KEY environment variable not set")
    
    client = IncidentIOClient(api_key)
    
    try:
        result = await client._make_request("GET", f"/v2/incidents/{incident_id}")
        return str(result)
    except Exception as e:
        raise ServerError(f"Failed to get incident {incident_id}: {str(e)}")


@mcp.tool()
async def create_incident(
    name: str,
    summary: str,
    severity_id: str,
    status_id: Optional[str] = None,
    incident_type_id: Optional[str] = None
) -> str:
    """
    Create a new incident
    
    Args:
        name: The name/title of the incident
        summary: A brief summary of the incident
        severity_id: The severity level ID for the incident
        status_id: Optional status ID (defaults to organization's default)
        incident_type_id: Optional incident type ID
    
    Returns:
        JSON string containing the created incident details
    """
    api_key = os.getenv("INCIDENT_IO_API_KEY")
    if not api_key:
        raise ServerError("INCIDENT_IO_API_KEY environment variable not set")
    
    client = IncidentIOClient(api_key)
    
    payload = {
        "name": name,
        "summary": summary,
        "severity_id": severity_id
    }
    
    if status_id:
        payload["status_id"] = status_id
    if incident_type_id:
        payload["incident_type_id"] = incident_type_id
    
    try:
        result = await client._make_request("POST", "/v2/incidents", json=payload)
        return str(result)
    except Exception as e:
        raise ServerError(f"Failed to create incident: {str(e)}")


@mcp.tool()
async def list_users(page_size: int = 25, after: Optional[str] = None) -> str:
    """
    List users in the organization
    
    Args:
        page_size: Number of users to return (max 100, default 25)
        after: Pagination cursor for fetching next page
    
    Returns:
        JSON string containing the list of users
    """
    api_key = os.getenv("INCIDENT_IO_API_KEY")
    if not api_key:
        raise ServerError("INCIDENT_IO_API_KEY environment variable not set")
    
    client = IncidentIOClient(api_key)
    
    params = {"page_size": min(page_size, 100)}
    if after:
        params["after"] = after
    
    try:
        result = await client._make_request("GET", "/v2/users", params=params)
        return str(result)
    except Exception as e:
        raise ServerError(f"Failed to list users: {str(e)}")


@mcp.tool()
async def list_severities() -> str:
    """
    List all available incident severities
    
    Returns:
        JSON string containing the list of severities
    """
    api_key = os.getenv("INCIDENT_IO_API_KEY")
    if not api_key:
        raise ServerError("INCIDENT_IO_API_KEY environment variable not set")
    
    client = IncidentIOClient(api_key)
    
    try:
        result = await client._make_request("GET", "/v2/severities")
        return str(result)
    except Exception as e:
        raise ServerError(f"Failed to list severities: {str(e)}")


@mcp.tool()
async def list_incident_statuses() -> str:
    """
    List all available incident statuses
    
    Returns:
        JSON string containing the list of incident statuses
    """
    api_key = os.getenv("INCIDENT_IO_API_KEY")
    if not api_key:
        raise ServerError("INCIDENT_IO_API_KEY environment variable not set")
    
    client = IncidentIOClient(api_key)
    
    try:
        result = await client._make_request("GET", "/v2/incident_statuses")
        return str(result)
    except Exception as e:
        raise ServerError(f"Failed to list incident statuses: {str(e)}")


def main():
    """Run the MCP server"""
    # Load environment variables from .env file if it exists
    load_dotenv()
    
    # Configure logging
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    
    # Check for required environment variables
    api_key = os.getenv("INCIDENT_IO_API_KEY")
    if not api_key:
        logger.error("INCIDENT_IO_API_KEY environment variable not set.")
        logger.error("Please set your incident.io API key using one of these methods:")
        logger.error("1. Environment variable: export INCIDENT_IO_API_KEY='your_api_key'")
        logger.error("2. Create a .env file with: INCIDENT_IO_API_KEY=your_api_key")
        logger.error("3. Pass it when running: INCIDENT_IO_API_KEY=your_api_key python -m src.incident_io_mcp.server")
        raise SystemExit("Missing required INCIDENT_IO_API_KEY environment variable")
    
    logger.info("incident.io MCP Server starting...")
    logger.info("API key configured (Bearer token authentication)")
    
    # Run the server
    mcp.run()


if __name__ == "__main__":
    main()