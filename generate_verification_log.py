#!/usr/bin/env python3
"""
Generate API Verification Log from Postman Collection
Creates a tracking file for all API endpoints to verify against Flutter app implementation
"""

import json
import os
from datetime import datetime

def extract_endpoints_from_postman(collection_path):
    """Extract all endpoints from Postman collection"""
    with open(collection_path, 'r', encoding='utf-8') as f:
        collection = json.load(f)
    
    endpoints = []
    
    def process_item(item, category_name=""):
        """Recursively process Postman collection items"""
        if 'item' in item:
            # This is a folder/category
            category = item.get('name', 'Unknown')
            for sub_item in item['item']:
                process_item(sub_item, category)
        else:
            # This is an endpoint
            request = item.get('request', {})
            method = request.get('method', 'GET')
            url_obj = request.get('url', {})
            
            if isinstance(url_obj, dict):
                path_parts = url_obj.get('path', [])
                if isinstance(path_parts, list):
                    path = '/' + '/'.join(path_parts)
                else:
                    path = url_obj.get('raw', '')
            else:
                path = str(url_obj)
            
            # Clean up path variables
            path = path.replace('{{base_url}}', '')
            path = path.replace('{id}', ':id')
            path = path.replace('{userId}', ':userId')
            path = path.replace('{groupId}', ':groupId')
            path = path.replace('{feedId}', ':feedId')
            path = path.replace('{commentId}', ':commentId')
            path = path.replace('{storyId}', ':storyId')
            path = path.replace('{subscriptionId}', ':subscriptionId')
            path = path.replace('{step}', ':step')
            path = path.replace('{planId}', ':planId')
            path = path.replace('{languageId}', ':languageId')
            path = path.replace('{jobId}', ':jobId')
            path = path.replace('{relationGoalId}', ':relationGoalId')
            path = path.replace('{interestId}', ':interestId')
            path = path.replace('{musicGenreId}', ':musicGenreId')
            path = path.replace('{educationId}', ':educationId')
            path = path.replace('{preferredGenderId}', ':preferredGenderId')
            path = path.replace('{genderId}', ':genderId')
            path = path.replace('{verificationId}', ':verificationId')
            path = path.replace('{currency}', ':currency')
            path = path.replace('{type}', ':type')
            path = path.replace('{subPlan}', ':subPlan')
            
            description = request.get('description', '')
            
            # Check if auth is required
            auth_required = False
            headers = request.get('header', [])
            for header in headers:
                if isinstance(header, dict) and header.get('key') == 'Authorization':
                    auth_required = True
                    break
            
            # Check collection-level auth
            if not auth_required and 'auth' in collection:
                auth_required = True
            
            endpoints.append({
                'category': category_name or 'Unknown',
                'method': method,
                'path': path,
                'description': description,
                'auth_required': auth_required,
                'name': item.get('name', 'Unknown')
            })
    
    # Process all items
    for item in collection.get('item', []):
        process_item(item)
    
    return endpoints

def generate_verification_log(endpoints, output_path):
    """Generate markdown verification log file"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    lines = []
    lines.append("# API Verification Log")
    lines.append("")
    lines.append(f"**Generated:** {timestamp}")
    lines.append(f"**Total Endpoints:** {len(endpoints)}")
    lines.append(f"**Base URL:** `https://lg.abolfazlnajafi.com/api`")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Status Legend")
    lines.append("")
    lines.append("- ✅ **Verified** - Endpoint is correctly implemented and tested")
    lines.append("- ⏳ **In Progress** - Currently being verified")
    lines.append("- ❌ **Not Used** - Endpoint not related to app or should be skipped")
    lines.append("- 🔧 **Needs Fix** - Endpoint exists but has issues")
    lines.append("- ➕ **Missing** - Endpoint should be used but is not implemented")
    lines.append("- 📝 **Review Needed** - Requires manual review")
    lines.append("")
    lines.append("---")
    lines.append("")
    
    # Group by category
    categories = {}
    for endpoint in endpoints:
        category = endpoint['category']
        if category not in categories:
            categories[category] = []
        categories[category].append(endpoint)
    
    # Sort categories
    sorted_categories = sorted(categories.keys())
    
    total_verified = 0
    total_not_used = 0
    total_needs_fix = 0
    total_missing = 0
    total_review = 0
    
    for category in sorted_categories:
        lines.append(f"## {category}")
        lines.append("")
        
        category_endpoints = sorted(categories[category], key=lambda x: (x['method'], x['path']))
        
        lines.append(f"**Total Endpoints:** {len(category_endpoints)}")
        lines.append("")
        
        for endpoint in category_endpoints:
            method = endpoint['method']
            path = endpoint['path']
            name = endpoint['name']
            auth = "🔒" if endpoint['auth_required'] else "🔓"
            desc = endpoint['description']
            
            lines.append(f"### {method} {path} {auth}")
            lines.append("")
            lines.append(f"**Name:** {name}")
            if desc:
                lines.append(f"**Description:** {desc}")
            lines.append("")
            lines.append("**Status:** 📝 Review Needed")
            lines.append("")
            lines.append("**Location in App:** _To be determined_")
            lines.append("")
            lines.append("**Notes:**")
            lines.append("")
            lines.append("- [ ] Check if endpoint is used in app")
            lines.append("- [ ] Verify request body matches API spec")
            lines.append("- [ ] Verify response handling matches API spec")
            lines.append("- [ ] Test endpoint with actual API")
            lines.append("")
            lines.append("---")
            lines.append("")
            total_review += 1
    
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- **Total Endpoints:** {len(endpoints)}")
    lines.append(f"- ✅ **Verified:** {total_verified}")
    lines.append(f"- ❌ **Not Used:** {total_not_used}")
    lines.append(f"- 🔧 **Needs Fix:** {total_needs_fix}")
    lines.append(f"- ➕ **Missing:** {total_missing}")
    lines.append(f"- 📝 **Review Needed:** {total_review}")
    lines.append("")
    lines.append(f"**Progress:** {total_verified}/{len(endpoints)} ({total_verified*100//len(endpoints) if len(endpoints) > 0 else 0}%)")
    lines.append("")
    
    # Write to file
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"Verification log generated successfully!")
    print(f"Total endpoints: {len(endpoints)}")
    print(f"Output file: {output_path}")

if __name__ == '__main__':
    collection_path = os.path.join('LGBTinder_API_Postman_Collection_Updated.json')
    output_path = os.path.join('API_VERIFICATION_LOG.md')
    
    if not os.path.exists(collection_path):
        print(f"Error: Postman collection not found at {collection_path}")
        exit(1)
    
    endpoints = extract_endpoints_from_postman(collection_path)
    generate_verification_log(endpoints, output_path)


