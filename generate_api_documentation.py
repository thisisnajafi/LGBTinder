import json
import re
from typing import Dict, List, Any, Optional

def extract_url_from_request(request: Dict) -> str:
    """Extract the full URL from a request object"""
    url_obj = request.get("url", {})
    raw = url_obj.get("raw", "")
    if raw:
        return raw.replace("{{base_url}}", "BASE_URL")
    path = url_obj.get("path", [])
    return "/" + "/".join(path) if path else ""

def extract_body_from_request(request: Dict) -> Optional[str]:
    """Extract request body if present"""
    body = request.get("body", {})
    if body.get("mode") == "raw":
        raw_body = body.get("raw", "")
        if raw_body:
            return raw_body.strip()
    return None

def extract_response_info(responses: List[Dict]) -> List[Dict]:
    """Extract response information from response array"""
    response_info = []
    for response in responses:
        name = response.get("name", "Response")
        status = response.get("status", "")
        code = response.get("code", 0)
        body = response.get("body", "")
        
        # Try to parse JSON body
        json_body = None
        if body:
            try:
                json_body = json.loads(body)
            except:
                pass
        
        response_info.append({
            "name": name,
            "status": status,
            "code": code,
            "body": body,
            "json_body": json_body
        })
    return response_info

def parse_json_schema(schema_obj: Any) -> Dict:
    """Parse JSON schema to understand structure"""
    if isinstance(schema_obj, dict):
        result = {}
        if "properties" in schema_obj:
            for prop, prop_schema in schema_obj["properties"].items():
                prop_type = prop_schema.get("type", "object")
                if prop_type == "array":
                    items = prop_schema.get("items", {})
                    result[prop] = f"array[{items.get('type', 'object')}]"
                else:
                    result[prop] = prop_type
        elif "type" in schema_obj:
            result["type"] = schema_obj["type"]
        return result
    return {}

def analyze_response_structure(body_str: str) -> Dict:
    """Analyze response body to extract structure"""
    if not body_str:
        return {}
    
    try:
        data = json.loads(body_str)
        return analyze_data_structure(data, "response")
    except:
        return {}

def analyze_data_structure(data: Any, prefix: str = "") -> Dict:
    """Recursively analyze data structure"""
    structure = {}
    
    if isinstance(data, dict):
        for key, value in data.items():
            full_key = f"{prefix}.{key}" if prefix else key
            if isinstance(value, (dict, list)):
                structure[full_key] = type(value).__name__
                structure.update(analyze_data_structure(value, full_key))
            else:
                structure[full_key] = type(value).__name__
    elif isinstance(data, list) and len(data) > 0:
        structure[f"{prefix}[0]"] = "array_item"
        if isinstance(data[0], dict):
            structure.update(analyze_data_structure(data[0], f"{prefix}[0]"))
    
    return structure

def format_response_example(json_body: Any, indent: int = 2) -> str:
    """Format JSON response example"""
    if json_body is None:
        return ""
    try:
        return json.dumps(json_body, indent=indent, ensure_ascii=False)
    except:
        return str(json_body)

def document_endpoint(endpoint: Dict, category_name: str) -> str:
    """Document a single endpoint"""
    name = endpoint.get("name", "Unknown")
    request = endpoint.get("request", {})
    method = request.get("method", "GET")
    description = request.get("description", "")
    url = extract_url_from_request(request)
    body = extract_body_from_request(request)
    responses = endpoint.get("response", [])
    
    doc = f"\n### {name}\n\n"
    doc += f"**Method:** `{method}`\n\n"
    doc += f"**Endpoint:** `{url}`\n\n"
    
    if description:
        doc += f"**Description:** {description}\n\n"
    
    # Request body
    if body:
        doc += "**Request Body:**\n\n"
        doc += "```json\n"
        try:
            body_json = json.loads(body)
            doc += json.dumps(body_json, indent=2, ensure_ascii=False)
        except:
            doc += body
        doc += "\n```\n\n"
    
    # Headers
    headers = request.get("header", [])
    auth_required = any(h.get("key") == "Authorization" for h in headers)
    if auth_required:
        doc += "**Authentication:** Required (Bearer Token)\n\n"
    
    # Responses
    if responses:
        doc += "**Responses:**\n\n"
        
        for idx, response in enumerate(responses, 1):
            resp_name = response.get("name", f"Response {idx}")
            resp_code = response.get("code", 0)
            resp_status = response.get("status", "")
            resp_body = response.get("body", "")
            
            # Determine response type
            if resp_code == 200 or "success" in resp_name.lower() or "Success" in resp_name:
                response_type = "Success"
            elif resp_code == 201:
                response_type = "Created"
            elif resp_code == 422:
                response_type = "Validation Error"
            elif resp_code == 401 or resp_code == 403:
                response_type = "Authentication Error"
            elif resp_code == 404:
                response_type = "Not Found"
            elif resp_code >= 500:
                response_type = "Server Error"
            else:
                response_type = "Error"
            
            doc += f"#### {response_type} Response ({resp_code})\n\n"
            
            if resp_body:
                try:
                    resp_json = json.loads(resp_body)
                    doc += "**Response Structure:**\n\n"
                    doc += "```json\n"
                    doc += json.dumps(resp_json, indent=2, ensure_ascii=False)
                    doc += "\n```\n\n"
                    
                    # Analyze structure
                    structure = analyze_data_structure(resp_json)
                    if structure:
                        doc += "**Response Fields:**\n\n"
                        for field, field_type in sorted(structure.items()):
                            if not field.endswith("[0]") and field != "type":
                                doc += f"- `{field}` ({field_type})\n"
                        doc += "\n"
                except:
                    doc += "```\n"
                    doc += resp_body[:500]  # Limit length
                    if len(resp_body) > 500:
                        doc += "\n... (truncated)"
                    doc += "\n```\n\n"
    else:
        # Generate comprehensive default response examples based on endpoint patterns
        doc += "**Responses:**\n\n"
        
        # Generate responses based on endpoint URL pattern
        url_lower = url.lower()
        
        # Success response (common for all methods)
        if method == "GET":
            if "list" in url_lower or "history" in url_lower or "matches" in url_lower:
                doc += "#### Success Response (200)\n\n"
                doc += "```json\n"
                doc += '{\n  "status": true,\n  "message": "Data retrieved successfully",\n  "data": {\n    "items": [],\n    "current_page": 1,\n    "per_page": 15,\n    "total": 0,\n    "last_page": 1\n  }\n}\n'
                doc += "```\n\n"
                doc += "**Response Fields:**\n\n"
                doc += "- `status` (boolean) - Operation status\n"
                doc += "- `message` (string) - Response message\n"
                doc += "- `data.items` (array) - List of items\n"
                doc += "- `data.current_page` (integer) - Current page number\n"
                doc += "- `data.per_page` (integer) - Items per page\n"
                doc += "- `data.total` (integer) - Total number of items\n"
                doc += "- `data.last_page` (integer) - Last page number\n\n"
            else:
                doc += "#### Success Response (200)\n\n"
                doc += "```json\n"
                doc += '{\n  "status": true,\n  "message": "Data retrieved successfully",\n  "data": {}\n}\n'
                doc += "```\n\n"
                doc += "**Response Fields:**\n\n"
                doc += "- `status` (boolean) - Operation status\n"
                doc += "- `message` (string) - Response message\n"
                doc += "- `data` (object) - Response data object\n\n"
        elif method == "POST":
            if "register" in url_lower:
                doc += "#### Success Response (200)\n\n"
                doc += "```json\n"
                doc += '{\n  "status": true,\n  "message": "Registration successful! Please check your email for verification code.",\n  "data": {\n    "user_id": 1,\n    "email": "user@example.com",\n    "email_sent": true,\n    "resend_available_at": "2024-01-01 12:02:00",\n    "hourly_attempts_remaining": 2\n  }\n}\n'
                doc += "```\n\n"
                doc += "**Response Fields:**\n\n"
                doc += "- `status` (boolean) - Operation status\n"
                doc += "- `message` (string) - Success message\n"
                doc += "- `data.user_id` (integer) - Created user ID\n"
                doc += "- `data.email` (string) - User email address\n"
                doc += "- `data.email_sent` (boolean) - Whether email was sent\n"
                doc += "- `data.resend_available_at` (string) - When resend is available\n"
                doc += "- `data.hourly_attempts_remaining` (integer) - Remaining attempts\n\n"
            elif "login" in url_lower:
                doc += "#### Success Response (200)\n\n"
                doc += "```json\n"
                doc += '{\n  "status": true,\n  "message": "Login successful",\n  "data": {\n    "user": {},\n    "token": "auth_token_here",\n    "token_type": "Bearer",\n    "profile_completed": true,\n    "needs_profile_completion": false,\n    "user_state": "ready_for_app"\n  }\n}\n'
                doc += "```\n\n"
                doc += "**Response Fields:**\n\n"
                doc += "- `status` (boolean) - Operation status\n"
                doc += "- `message` (string) - Success message\n"
                doc += "- `data.user` (object) - User object\n"
                doc += "- `data.token` (string) - Authentication token\n"
                doc += "- `data.token_type` (string) - Token type (Bearer)\n"
                doc += "- `data.profile_completed` (boolean) - Profile completion status\n"
                doc += "- `data.needs_profile_completion` (boolean) - Whether profile completion is needed\n"
                doc += "- `data.user_state` (string) - Current user state\n\n"
            elif "like" in url_lower or "superlike" in url_lower:
                doc += "#### Success Response (200)\n\n"
                doc += "```json\n"
                doc += '{\n  "status": true,\n  "message": "User liked successfully",\n  "data": {\n    "like_id": 1,\n    "target_user_id": 2,\n    "status": "pending",\n    "is_match": false,\n    "created_at": "2024-01-01T12:00:00Z"\n  }\n}\n'
                doc += "```\n\n"
                doc += "**Response Fields:**\n\n"
                doc += "- `status` (boolean) - Operation status\n"
                doc += "- `message` (string) - Success message\n"
                doc += "- `data.like_id` (integer) - Like record ID\n"
                doc += "- `data.target_user_id` (integer) - Liked user ID\n"
                doc += "- `data.status` (string) - Like status (pending/accepted/rejected)\n"
                doc += "- `data.is_match` (boolean) - Whether it\'s a match\n"
                doc += "- `data.created_at` (string) - Creation timestamp\n\n"
                doc += "#### Match Response (200) - When Mutual Like Occurs\n\n"
                doc += "```json\n"
                doc += '{\n  "status": true,\n  "message": "It\'s a match!",\n  "data": {\n    "is_match": true,\n    "match_id": 1,\n    "users": [\n      {"id": 1, "name": "User 1"},\n      {"id": 2, "name": "User 2"}\n    ],\n    "created_at": "2024-01-01T12:00:00Z"\n  }\n}\n'
                doc += "```\n\n"
            elif "send" in url_lower and "message" in url_lower:
                doc += "#### Success Response (200)\n\n"
                doc += "```json\n"
                doc += '{\n  "status": true,\n  "message": "Message sent successfully",\n  "data": {\n    "message": {\n      "id": 1,\n      "chat_id": 1,\n      "sender_id": 1,\n      "receiver_id": 2,\n      "content": "Hello!",\n      "type": "text",\n      "created_at": "2024-01-01T12:00:00Z",\n      "read_at": null\n    }\n  }\n}\n'
                doc += "```\n\n"
                doc += "**Response Fields:**\n\n"
                doc += "- `status` (boolean) - Operation status\n"
                doc += "- `message` (string) - Success message\n"
                doc += "- `data.message.id` (integer) - Message ID\n"
                doc += "- `data.message.chat_id` (integer) - Chat ID\n"
                doc += "- `data.message.sender_id` (integer) - Sender user ID\n"
                doc += "- `data.message.receiver_id` (integer) - Receiver user ID\n"
                doc += "- `data.message.content` (string) - Message content\n"
                doc += "- `data.message.type` (string) - Message type (text/image/video)\n"
                doc += "- `data.message.created_at` (string) - Creation timestamp\n"
                doc += "- `data.message.read_at` (string|null) - Read timestamp\n\n"
            else:
                doc += "#### Success Response (200)\n\n"
                doc += "```json\n"
                doc += '{\n  "status": true,\n  "message": "Operation successful",\n  "data": {}\n}\n'
                doc += "```\n\n"
                doc += "**Response Fields:**\n\n"
                doc += "- `status` (boolean) - Operation status\n"
                doc += "- `message` (string) - Success message\n"
                doc += "- `data` (object) - Response data object\n\n"
            
            # Validation error for POST
            doc += "#### Validation Error Response (422)\n\n"
            doc += "```json\n"
            doc += '{\n  "status": false,\n  "message": "Validation error",\n  "errors": {\n    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]\n  }\n}\n'
            doc += "```\n\n"
            doc += "**Response Fields:**\n\n"
            doc += "- `status` (boolean) - Always false for errors\n"
            doc += "- `message` (string) - Error message\n"
            doc += "- `errors` (object) - Validation errors object with field names as keys and array of error messages as values\n\n"
            
        elif method in ["PUT", "PATCH"]:
            doc += "#### Success Response (200)\n\n"
            doc += "```json\n"
            doc += '{\n  "status": true,\n  "message": "Updated successfully",\n  "data": {}\n}\n'
            doc += "```\n\n"
            doc += "**Response Fields:**\n\n"
            doc += "- `status` (boolean) - Operation status\n"
            doc += "- `message` (string) - Success message\n"
            doc += "- `data` (object) - Updated data object\n\n"
            doc += "#### Validation Error Response (422)\n\n"
            doc += "```json\n"
            doc += '{\n  "status": false,\n  "message": "Validation error",\n  "errors": {\n    "field_name": ["Error message"]\n  }\n}\n'
            doc += "```\n\n"
        elif method == "DELETE":
            doc += "#### Success Response (200)\n\n"
            doc += "```json\n"
            doc += '{\n  "status": true,\n  "message": "Deleted successfully"\n}\n'
            doc += "```\n\n"
            doc += "**Response Fields:**\n\n"
            doc += "- `status` (boolean) - Operation status\n"
            doc += "- `message` (string) - Success message\n\n"
        
        # Common error responses
        if auth_required:
            doc += "#### Unauthorized Response (401)\n\n"
            doc += "```json\n"
            doc += '{\n  "message": "Unauthenticated"\n}\n'
            doc += "```\n\n"
            doc += "**Response Fields:**\n\n"
            doc += "- `message` (string) - Error message indicating authentication is required\n\n"
        
        doc += "#### Not Found Response (404)\n\n"
        doc += "```json\n"
        doc += '{\n  "status": false,\n  "message": "Resource not found"\n}\n'
        doc += "```\n\n"
        doc += "**Response Fields:**\n\n"
        doc += "- `status` (boolean) - Always false for errors\n"
        doc += "- `message` (string) - Error message\n\n"
        
        doc += "#### Server Error Response (500)\n\n"
        doc += "```json\n"
        doc += '{\n  "status": false,\n  "message": "Internal server error",\n  "error": "Detailed error message"\n}\n'
        doc += "```\n\n"
        doc += "**Response Fields:**\n\n"
        doc += "- `status` (boolean) - Always false for errors\n"
        doc += "- `message` (string) - Error message\n"
        doc += "- `error` (string) - Detailed error information\n\n"
    
    return doc

def parse_postman_collection(file_path: str) -> Dict:
    """Parse Postman collection file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def generate_markdown_documentation(collection_path: str, output_path: str):
    """Generate complete API documentation markdown file"""
    
    print("Loading Postman collection...")
    collection = parse_postman_collection(collection_path)
    
    items = collection.get("item", [])
    base_url = "http://localhost:8000/api"  # Default from collection
    
    print(f"Found {len(items)} categories")
    
    doc = "# LGBTinder API - Complete Methods Documentation\n\n"
    doc += f"**Generated from:** Postman Collection\n"
    doc += f"**Base URL:** `{base_url}`\n"
    doc += f"**Total Categories:** {len(items)}\n\n"
    doc += "---\n\n"
    
    total_endpoints = 0
    
    for category in items:
        category_name = category.get("name", "Unknown Category")
        category_items = category.get("item", [])
        
        doc += f"## {category_name}\n\n"
        doc += f"**Total Endpoints:** {len(category_items)}\n\n"
        
        endpoint_count = 0
        for item in category_items:
            # Check if it's an endpoint or subfolder
            if "item" in item:
                # It's a subfolder
                subfolder_name = item.get("name", "Subfolder")
                doc += f"### {subfolder_name}\n\n"
                sub_items = item.get("item", [])
                for sub_item in sub_items:
                    endpoint_count += 1
                    total_endpoints += 1
                    doc += f"- [ ] {sub_item.get('name', 'Unknown')} - `{sub_item.get('request', {}).get('method', 'GET')}` `{extract_url_from_request(sub_item.get('request', {}))}`\n"
                    doc += document_endpoint(sub_item, subfolder_name)
            else:
                # It's an endpoint
                endpoint_count += 1
                total_endpoints += 1
                doc += f"- [ ] {item.get('name', 'Unknown')} - `{item.get('request', {}).get('method', 'GET')}` `{extract_url_from_request(item.get('request', {}))}`\n"
                doc += document_endpoint(item, category_name)
        
        doc += "\n---\n\n"
    
    doc += f"\n## Summary\n\n"
    doc += f"- **Total Categories:** {len(items)}\n"
    doc += f"- **Total Endpoints:** {total_endpoints}\n"
    doc += f"- **Documentation Generated:** {len(doc)} characters\n"
    
    print(f"Writing documentation to {output_path}...")
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(doc)
    
    print("Documentation generated successfully!")
    print(f"Total endpoints documented: {total_endpoints}")
    print(f"Output file: {output_path}")

if __name__ == "__main__":
    collection_path = "LGBTinder_API_Postman_Collection_Updated.json"
    output_path = "All_API_Methods.md"
    
    generate_markdown_documentation(collection_path, output_path)

