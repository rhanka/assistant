#!/bin/bash

# Security Compliance Checker
# Checks if all findings are in the accepted vulnerabilities list

set -e

SCAN_TYPE="$1"
SERVICE="$2"
# Map scan_type to file prefix
if [ "$SCAN_TYPE" = "sast" ]; then
    FILE_PREFIX="sast"
elif [ "$SCAN_TYPE" = "semgrep" ]; then
    FILE_PREFIX="semgrep"
elif [ "$SCAN_TYPE" = "sca" ]; then
    FILE_PREFIX="sca"
elif [ "$SCAN_TYPE" = "container" ]; then
    FILE_PREFIX="container"
elif [ "$SCAN_TYPE" = "iac" ]; then
    FILE_PREFIX="iac"
else
    FILE_PREFIX="$SCAN_TYPE"
fi

PARSED_FILE=".security/${FILE_PREFIX}-${SERVICE}-parsed.yaml"
ACCEPTED_FILE=".security/vulnerability-register.yaml"

if [ -z "$SCAN_TYPE" ] || [ -z "$SERVICE" ]; then
    echo "Usage: $0 <scan_type> <service>"
    echo "Example: $0 semgrep api"
    exit 1
fi

if [ ! -f "$PARSED_FILE" ]; then
    echo "❌ Parsed results file not found: $PARSED_FILE"
    exit 1
fi

if [ ! -f "$ACCEPTED_FILE" ]; then
    echo "❌ Accepted vulnerabilities file not found: $ACCEPTED_FILE"
    exit 1
fi

# Map scan_type to display name
if [ "$SCAN_TYPE" = "sast" ]; then
    SCAN_DISPLAY="SAST (Semgrep)"
elif [ "$SCAN_TYPE" = "semgrep" ]; then
    SCAN_DISPLAY="SAST (Semgrep)"
elif [ "$SCAN_TYPE" = "sca" ]; then
    SCAN_DISPLAY="SCA (Trivy)"
elif [ "$SCAN_TYPE" = "container" ]; then
    SCAN_DISPLAY="Container (Trivy)"
elif [ "$SCAN_TYPE" = "iac" ]; then
    SCAN_DISPLAY="IaC (Trivy)"
else
    SCAN_DISPLAY="$SCAN_TYPE"
fi

echo "🔍 Checking compliance for $SCAN_DISPLAY scan of $SERVICE..."

# Get findings count
FINDINGS_COUNT=$(yq -r '.findings_count // 0' "$PARSED_FILE")

if [ "$FINDINGS_COUNT" -eq 0 ]; then
    echo "✅ No findings to check - compliance passed"
    exit 0
fi

echo "Found $FINDINGS_COUNT findings to check..."

# Check each finding against accepted list
UNACCEPTED_FINDINGS=0

# Get all findings as a list
FINDINGS=$(yq -r '.findings[] | .id + "|" + .file + "|" + (.line | tostring) + "|" + .severity' "$PARSED_FILE")

if [ -n "$FINDINGS" ]; then
    echo "$FINDINGS" | while IFS='|' read -r FINDING_ID FINDING_FILE FINDING_LINE FINDING_SEVERITY; do
        echo "  Checking: $FINDING_ID in $FINDING_FILE:$FINDING_LINE ($FINDING_SEVERITY)"
        
        # Check if this finding is accepted
        ACCEPTED=$(yq -r ".vulnerability_register.vulnerabilities.\"$FINDING_ID\".category" "$ACCEPTED_FILE" 2>/dev/null || echo "")
        
        if [ -n "$ACCEPTED" ]; then
            echo "    ✅ ACCEPTED: $ACCEPTED"
        else
            echo "    ❌ NOT ACCEPTED: Must be added to vulnerability-register.yaml"
            echo "UNACCEPTED" >> /tmp/unaccepted_count
        fi
    done
    
    # Count unaccepted findings
    if [ -f "/tmp/unaccepted_count" ]; then
        UNACCEPTED_FINDINGS=$(wc -l < /tmp/unaccepted_count)
        rm /tmp/unaccepted_count
    fi
fi

echo ""
if [ "$UNACCEPTED_FINDINGS" -eq 0 ]; then
    echo "✅ COMPLIANCE PASSED: All findings are accepted"
    exit 0
else
    echo "❌ COMPLIANCE FAILED: $UNACCEPTED_FINDINGS findings are not accepted"
    echo ""
    echo "To fix this, either:"
    echo "1. Fix the vulnerabilities, or"
    echo "2. Add them to .security/vulnerability-register.yaml with justification"
    exit 1
fi
