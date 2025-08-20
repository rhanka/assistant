#!/bin/bash

# Security Parser using jq
# Usage: ./security-parser.sh <scan_type> <input_file> <output_file> [service_name]
# Example: ./security-parser.sh semgrep semgrep-output.json parsed-results.yaml api

set -e

SCAN_TYPE="$1"
INPUT_FILE="$2"
OUTPUT_FILE="$3"
SERVICE_NAME="$4"

if [ -z "$SCAN_TYPE" ] || [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 <scan_type> <input_file> <output_file> [service_name]"
    echo "Scan types: semgrep, sca, container"
    echo "Service name: api, ui, scheduler, workers, ai (for proper path construction)"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file $INPUT_FILE not found"
    exit 1
fi

echo "🔍 Parsing $SCAN_TYPE results from $INPUT_FILE..."

case "$SCAN_TYPE" in
    "sast"|"semgrep")
        # Parse Semgrep JSON output (SAST)
        if command -v jq >/dev/null 2>&1; then
            # Extract findings count
            FINDINGS_COUNT=$(jq '.results | length' "$INPUT_FILE" 2>/dev/null || echo "0")
            
            if [ "$FINDINGS_COUNT" -gt 0 ]; then
                echo "Found $FINDINGS_COUNT findings"
                
                # Extract structured findings and create proper JSON array
                jq -r --arg service "$SERVICE_NAME" '{
                    scan_type: "semgrep",
                    timestamp: now,
                    findings_count: (.results | length),
                    findings: [.results[] | {
                        id: (.check_id + "_" + ("packages_" + $service + "_" + .path | gsub("/"; "_") | gsub("\\."; "_")) + "_L" + (.start.line | tostring)),
                        rule_id: .check_id,
                        severity: .extra.severity,
                        file: ("packages/" + $service + "/" + .path),
                        line: .start.line,
                        message: .extra.message,
                        fix: (.extra.fix // null),
                        cwe: (.extra.metadata.cwe // []),
                        owasp: (.extra.metadata.owasp // []),
                        category: (.extra.metadata.category // null),
                        confidence: (.extra.metadata.confidence // null)
                    }]
                }' "$INPUT_FILE" > "$OUTPUT_FILE"
                
                # Add context for each finding using sed
                echo "🔍 Extracting context for findings..."
                
                # Process each finding to add context
                for i in $(seq 0 $((FINDINGS_COUNT - 1))); do
                    FILE_PATH=$(jq -r ".findings[$i].file" "$OUTPUT_FILE")
                    LINE_NUM=$(jq -r ".findings[$i].line" "$OUTPUT_FILE")
                    
                    echo "  Extracting context for $FILE_PATH:$LINE_NUM"
                    
                    # Get context with sed around the specific line
                    if [ -f "$FILE_PATH" ]; then
                        # Extract 3 lines before and after the target line
                        CONTEXT=$(sed -n "$((LINE_NUM - 3)),$((LINE_NUM + 3))p" "$FILE_PATH" 2>/dev/null || echo "Context not available")
                        # Clean up context (remove empty lines at start/end)
                        CONTEXT=$(echo "$CONTEXT" | sed '/^$/d' | head -7 | tail -7)
                    else
                        CONTEXT="File not found: $FILE_PATH"
                    fi
                    
                    # Update the finding with context
                    jq --arg context "$CONTEXT" ".findings[$i].context = \$context" "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
                done
                
                # Convert JSON to YAML if output file has .yaml or .yml extension
                if [[ "$OUTPUT_FILE" == *.yaml ]] || [[ "$OUTPUT_FILE" == *.yml ]]; then
                    echo "🔄 Converting to YAML format..."
                    if command -v yq >/dev/null 2>&1; then
                        yq eval -P '.' "$OUTPUT_FILE" > "${OUTPUT_FILE}.yaml_tmp" && mv "${OUTPUT_FILE}.yaml_tmp" "$OUTPUT_FILE"
                    else
                        echo "⚠️  yq not found - keeping JSON format"
                    fi
                fi
                
                echo "✅ Parsed $FINDINGS_COUNT findings to $OUTPUT_FILE"
            else
                echo "No findings found"
                echo '{"findings_count": 0, "findings": []}' > "$OUTPUT_FILE"
            fi
        else
            echo "Error: jq is required for parsing Semgrep output"
            exit 1
        fi
        ;;
        
    "sca"|"container"|"iac")
        # Parse Trivy JSON output
        if command -v jq >/dev/null 2>&1; then
            FINDINGS_COUNT=$(jq '.Results | length' "$INPUT_FILE" 2>/dev/null || echo "0")
            
            if [ "$FINDINGS_COUNT" -gt 0 ]; then
                echo "Found $FINDINGS_COUNT results"
                
                # Extract structured findings from Trivy format
                jq -r --arg service "$SERVICE_NAME" '{
                    scan_type: "'$SCAN_TYPE'",
                    timestamp: now,
                    findings_count: ([.Results[]?.Vulnerabilities[]?] | length),
                    findings: [.Results[]?.Vulnerabilities[]? | {
                        id: (.VulnerabilityID + "_" + ($service + "_" + (.PkgName // "unknown") | gsub("/"; "_") | gsub("\\."; "_")) + "_" + (.InstalledVersion // "unknown")),
                        rule_id: .VulnerabilityID,
                        severity: .Severity,
                        file: (.PkgPath // "unknown"),
                        line: 1,
                        message: (.Description // .Title // "No description available"),
                        fix: (.FixedVersion // null),
                        cwe: (.CweIDs // []),
                        owasp: [],
                        category: "vulnerability",
                        confidence: "HIGH"
                    }]
                }' "$INPUT_FILE" > "$OUTPUT_FILE"
                
                # Convert JSON to YAML if output file has .yaml or .yml extension
                if [[ "$OUTPUT_FILE" == *.yaml ]] || [[ "$OUTPUT_FILE" == *.yml ]]; then
                    echo "🔄 Converting to YAML format..."
                    if command -v yq >/dev/null 2>&1; then
                        yq eval -P '.' "$OUTPUT_FILE" > "${OUTPUT_FILE}.yaml_tmp" && mv "${OUTPUT_FILE}.yaml_tmp" "$OUTPUT_FILE"
                    else
                        echo "⚠️  yq not found - keeping JSON format"
                    fi
                fi
                
                echo "✅ Parsed findings to $OUTPUT_FILE"
            else
                echo "No findings found"
                echo '{"findings_count": 0, "findings": []}' > "$OUTPUT_FILE"
            fi
        else
            echo "Error: jq is required for parsing Trivy output"
            exit 1
        fi
        ;;
        
    *)
        echo "Error: Unknown scan type: $SCAN_TYPE"
        exit 1
        ;;
esac

echo "✅ Parsing complete. Output written to: $OUTPUT_FILE"
