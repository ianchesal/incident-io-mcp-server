"""Tests for the incident.io MCP server"""

import pytest
import os
from unittest.mock import AsyncMock, patch, MagicMock
import httpx

from src.incident_io_mcp.server import IncidentIOClient, list_incidents, get_incident, create_incident


class TestIncidentIOClient:
    """Test the IncidentIOClient class"""
    
    def setup_method(self):
        """Set up test fixtures"""
        self.api_key = "test-api-key"
        self.client = IncidentIOClient(self.api_key)
    
    def test_client_initialization(self):
        """Test that the client initializes correctly"""
        assert self.client.api_key == self.api_key
        assert self.client.base_url == "https://api.incident.io"
        assert self.client.headers["Authorization"] == f"Bearer {self.api_key}"
        assert self.client.headers["Content-Type"] == "application/json"
    
    def test_client_custom_base_url(self):
        """Test client with custom base URL"""
        custom_url = "https://custom.api.example.com"
        client = IncidentIOClient(self.api_key, base_url=custom_url)
        assert client.base_url == custom_url
    
    @pytest.mark.asyncio
    async def test_make_request_success(self):
        """Test successful API request"""
        mock_response = {"incidents": [{"id": "123", "name": "Test Incident"}]}
        
        with patch("httpx.AsyncClient") as mock_client:
            mock_instance = AsyncMock()
            mock_client.return_value.__aenter__.return_value = mock_instance
            
            mock_response_obj = MagicMock()
            mock_response_obj.json.return_value = mock_response
            mock_response_obj.raise_for_status.return_value = None
            mock_instance.request.return_value = mock_response_obj
            
            result = await self.client._make_request("GET", "/v2/incidents")
            
            assert result == mock_response
            mock_instance.request.assert_called_once_with(
                method="GET",
                url="https://api.incident.io/v2/incidents",
                headers=self.client.headers
            )
    
    @pytest.mark.asyncio
    async def test_make_request_http_error(self):
        """Test API request with HTTP error"""
        with patch("httpx.AsyncClient") as mock_client:
            mock_instance = AsyncMock()
            mock_client.return_value.__aenter__.return_value = mock_instance
            
            mock_response_obj = MagicMock()
            mock_response_obj.status_code = 401
            mock_response_obj.text = "Unauthorized"
            
            http_error = httpx.HTTPStatusError(
                "Unauthorized", 
                request=MagicMock(), 
                response=mock_response_obj
            )
            mock_instance.request.side_effect = http_error
            
            with pytest.raises(Exception) as exc_info:
                await self.client._make_request("GET", "/v2/incidents")
            
            assert "API request failed: 401" in str(exc_info.value)


class TestMCPTools:
    """Test the MCP tool functions"""
    
    @pytest.mark.asyncio
    async def test_list_incidents_no_api_key(self):
        """Test list_incidents without API key"""
        with patch.dict(os.environ, {}, clear=True):
            with pytest.raises(Exception) as exc_info:
                await list_incidents()
            assert "INCIDENT_IO_API_KEY environment variable not set" in str(exc_info.value)
    
    @pytest.mark.asyncio
    async def test_list_incidents_success(self):
        """Test successful incident listing"""
        mock_incidents = {
            "incidents": [
                {"id": "inc_123", "name": "Test Incident 1"},
                {"id": "inc_456", "name": "Test Incident 2"}
            ]
        }
        
        with patch.dict(os.environ, {"INCIDENT_IO_API_KEY": "test-key"}):
            with patch("src.incident_io_mcp.server.IncidentIOClient") as mock_client_class:
                mock_client = AsyncMock()
                mock_client._make_request.return_value = mock_incidents
                mock_client_class.return_value = mock_client
                
                result = await list_incidents(page_size=10)
                
                assert str(mock_incidents) in result
                mock_client._make_request.assert_called_once_with(
                    "GET", "/v2/incidents", params={"page_size": 10}
                )
    
    @pytest.mark.asyncio
    async def test_get_incident_success(self):
        """Test successful incident retrieval"""
        incident_id = "inc_123"
        mock_incident = {"id": incident_id, "name": "Test Incident", "status": "open"}
        
        with patch.dict(os.environ, {"INCIDENT_IO_API_KEY": "test-key"}):
            with patch("src.incident_io_mcp.server.IncidentIOClient") as mock_client_class:
                mock_client = AsyncMock()
                mock_client._make_request.return_value = mock_incident
                mock_client_class.return_value = mock_client
                
                result = await get_incident(incident_id)
                
                assert str(mock_incident) in result
                mock_client._make_request.assert_called_once_with(
                    "GET", f"/v2/incidents/{incident_id}"
                )
    
    @pytest.mark.asyncio
    async def test_create_incident_success(self):
        """Test successful incident creation"""
        mock_created_incident = {
            "id": "inc_new_123",
            "name": "New Test Incident",
            "summary": "Test summary",
            "severity_id": "sev_high"
        }
        
        with patch.dict(os.environ, {"INCIDENT_IO_API_KEY": "test-key"}):
            with patch("src.incident_io_mcp.server.IncidentIOClient") as mock_client_class:
                mock_client = AsyncMock()
                mock_client._make_request.return_value = mock_created_incident
                mock_client_class.return_value = mock_client
                
                result = await create_incident(
                    name="New Test Incident",
                    summary="Test summary",
                    severity_id="sev_high"
                )
                
                assert str(mock_created_incident) in result
                
                expected_payload = {
                    "name": "New Test Incident",
                    "summary": "Test summary",
                    "severity_id": "sev_high"
                }
                mock_client._make_request.assert_called_once_with(
                    "POST", "/v2/incidents", json=expected_payload
                )
    
    @pytest.mark.asyncio
    async def test_list_incidents_with_pagination(self):
        """Test list_incidents with pagination parameters"""
        with patch.dict(os.environ, {"INCIDENT_IO_API_KEY": "test-key"}):
            with patch("src.incident_io_mcp.server.IncidentIOClient") as mock_client_class:
                mock_client = AsyncMock()
                mock_client._make_request.return_value = {"incidents": []}
                mock_client_class.return_value = mock_client
                
                await list_incidents(page_size=50, after="cursor_123", status="open")
                
                expected_params = {
                    "page_size": 50,
                    "after": "cursor_123",
                    "status": "open"
                }
                mock_client._make_request.assert_called_once_with(
                    "GET", "/v2/incidents", params=expected_params
                )
    
    @pytest.mark.asyncio
    async def test_list_incidents_page_size_limit(self):
        """Test that page_size is limited to 100"""
        with patch.dict(os.environ, {"INCIDENT_IO_API_KEY": "test-key"}):
            with patch("src.incident_io_mcp.server.IncidentIOClient") as mock_client_class:
                mock_client = AsyncMock()
                mock_client._make_request.return_value = {"incidents": []}
                mock_client_class.return_value = mock_client
                
                await list_incidents(page_size=200)  # Request more than 100
                
                # Should be limited to 100
                expected_params = {"page_size": 100}
                mock_client._make_request.assert_called_once_with(
                    "GET", "/v2/incidents", params=expected_params
                )