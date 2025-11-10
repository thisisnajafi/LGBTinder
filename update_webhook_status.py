#!/usr/bin/env python3
"""
Update API Verification Log with Webhook Status
Webhooks are backend-only and should be marked as Not Used from Flutter app perspective
"""

import re
import os

def update_webhook_status_in_log(log_path):
    """Update webhook endpoints status in verification log"""
    with open(log_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Webhook endpoints to mark as Not Used
    webhook_patterns = [
        (r'### POST /stripe/webhook', 'Stripe Webhook'),
        (r'### POST /stripe/subscription-webhook', 'Stripe Subscription Webhook'),
        (r'### POST /superlike-packs/stripe-webhook', 'Superlike Packs Webhook'),
        (r'### POST /paypal/webhook', 'PayPal Webhook'),
    ]
    
    for pattern, name in webhook_patterns:
        # Find the section for this webhook
        section_start = content.find(pattern)
        if section_start != -1:
            # Find the Status line
            status_start = content.find('**Status:**', section_start)
            if status_start != -1:
                status_end = content.find('\n', status_start)
                # Replace status
                content = content[:status_start] + '**Status:** ❌ Not Used (Backend-only endpoint called by Stripe/PayPal servers)' + content[status_end:]
    
    # Update the summary section
    # Count webhooks
    webhook_count = len(webhook_patterns)
    
    # Update summary - find and replace counts
    summary_pattern = r'## Summary.*?\*\*Progress:\*\*'
    summary_match = re.search(summary_pattern, content, re.DOTALL)
    if summary_match:
        summary_text = summary_match.group(0)
        # Count current statuses
        total_review = summary_text.count('📝 Review Needed')
        total_not_used = summary_text.count('❌ Not Used')
        
        # Update counts
        new_not_used = total_not_used + webhook_count
        new_review = total_review - webhook_count
        
        # Replace summary section
        summary_start = summary_match.start()
        summary_end = content.find('**Progress:**', summary_start)
        if summary_end != -1:
            progress_line = content.find('\n', summary_end)
            old_summary = content[summary_start:progress_line]
            
            # Extract total endpoints
            total_match = re.search(r'\*\*Total Endpoints:\*\* (\d+)', old_summary)
            if total_match:
                total_endpoints = int(total_match.group(1))
                
                new_summary = f"""## Summary

- **Total Endpoints:** {total_endpoints}
- ✅ **Verified:** 0
- ❌ **Not Used:** {new_not_used}
- 🔧 **Needs Fix:** 0
- ➕ **Missing:** 0
- 📝 **Review Needed:** {new_review}

**Progress:** {0}/{total_endpoints} (0%)"""
                
                content = content[:summary_start] + new_summary + content[progress_line:]
    
    # Write updated content
    with open(log_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Updated webhook status in verification log: {webhook_count} webhooks marked as Not Used")

if __name__ == '__main__':
    log_path = os.path.join('API_VERIFICATION_LOG.md')
    
    if not os.path.exists(log_path):
        print(f"Error: Verification log not found at {log_path}")
        exit(1)
    
    update_webhook_status_in_log(log_path)


