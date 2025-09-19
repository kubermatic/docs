#!/bin/bash

set -e

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <KUBEONE_VERSION> <KUBERNETES_PATCH_VERSION> [JSON_FILE]" >&2
    echo "Example: $0 1.11.0 1.33.4 result.json" >&2
    exit 1
fi

KUBEONE_VERSION="$1"
KUBERNETES_PATCH_VERSION="$2"
JSON_FILE="${3:-result.json}"

# Check if JSON file exists
if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file '$JSON_FILE' not found" >&2
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed" >&2
    exit 1
fi

# Extract benchmark info from JSON
BENCHMARK_ID=$(jq -r '.ID' "$JSON_FILE" | sed 's/k8s-//')
BENCHMARK_TITLE=$(jq -r '.Title' "$JSON_FILE")

# Extract Kubernetes version from the provided patch version (drop patch number)
KUBERNETES_VERSION=$(echo "$KUBERNETES_PATCH_VERSION" | sed 's/\.[0-9]*$//')

# Function to get section title
get_section_title() {
    local section="$1"
    case "$section" in
        "1") echo "Control Plane Components" ;;
        "1.1") echo "Control Plane Node Configuration Files" ;;
        "1.2") echo "API Server" ;;
        "1.3") echo "Controller Manager" ;;
        "1.4") echo "Scheduler" ;;
        "2"|"2.1"|"2.2"|"2.3"|"2.4"|"2.5"|"2.6") echo "Etcd" ;;
        "3") echo "Control Plane Configuration" ;;
        "3.1") echo "Authentication and Authorization" ;;
        "3.2") echo "Logging" ;;
        "4") echo "Worker Nodes" ;;
        "4.1") echo "Worker Node Configuration Files" ;;
        "4.2") echo "Kubelet" ;;
        "5") echo "Policies" ;;
        "5.1") echo "RBAC and Service Accounts" ;;
        "5.2") echo "Pod Security Standards" ;;
        "5.3") echo "Network Policies and CNI" ;;
        "5.4") echo "Secrets Management" ;;
        "5.5") echo "Extensible Admission Control" ;;
        "5.6"|"5.7") echo "General Policies" ;;
        *) echo "Section $section" ;;
    esac
}

# Convert to uppercase for benchmark ID
BENCHMARK_ID_UPPER=$(echo "$BENCHMARK_ID" | tr '[:lower:]' '[:upper:]')

# Print header
echo "+++"
echo "title = \"Benchmark on Kubernetes $KUBERNETES_VERSION with KubeOne $KUBEONE_VERSION\""
echo "date = $(date +%Y-%m-%dT%H:%M:%S+02:00)"
echo "+++"
echo ""
echo "This guide helps you evaluate the security of a Kubernetes cluster created using KubeOne against each control in the CIS Kubernetes Benchmark."
echo ""
echo "This guide corresponds to the following versions of KubeOne, CIS Benchmarks, and Kubernetes:"
echo ""
echo "| KubeOne Version  | Kubernetes Version | CIS Benchmark Version |"
echo "| ---------------- | ------------------ | --------------------- |"
echo "| $KUBEONE_VERSION               | $KUBERNETES_PATCH_VERSION                 | $BENCHMARK_ID_UPPER                    |"
echo ""
echo "## Testing Methodology"
echo ""
echo "### Running the Benchmark"
echo ""
echo "[Trivy](https://github.com/aquasecurity/trivy) was used to run the benchmark. Trivy runs [kube-bench](https://github.com/aquasecurity/kube-bench) under the hood and checks if the cluster meets the CIS Kubernetes Benchmark."
echo ""
echo '```bash'
echo "trivy k8s --compliance=k8s-$BENCHMARK_ID --report summary --timeout=1h --tolerations node-role.kubernetes.io/control-plane=\"\":NoSchedule"
echo '```'
echo ""
echo "### Results"
echo ""
echo "Summary Report for compliance: $BENCHMARK_TITLE"
echo ""
echo "Each control in the CIS Kubernetes Benchmark was evaluated. These are the possible results for each control:"
echo ""
echo "🟢 **Pass:** The cluster passes the audit/control outlined in the benchmark."
echo ""
echo "🔵 **Pass (Additional Configuration Required):** The cluster passes the audit/control outlined in the benchmark with some extra configuration. The documentation is provided."
echo ""
echo "🔴 **Fail:** The audit/control will be fixed in a future KubeOne release."
echo ""

# Function to get control type (manual/automated)
get_control_type() {
    local name="$1"
    if echo "$name" | grep -qi "(Manual)"; then
        echo "Manual"
    else
        echo "Automated"
    fi
}

# Process controls grouped by sections
CURRENT_MAJOR=""
CURRENT_MINOR=""

# Get all controls sorted by ID
jq -r '.SummaryControls[] | @json' "$JSON_FILE" | while read -r control_json; do
    # Parse control fields
    ID=$(echo "$control_json" | jq -r '.ID')
    NAME=$(echo "$control_json" | jq -r '.Name')
    SEVERITY=$(echo "$control_json" | jq -r '.Severity // "MEDIUM"')
    TOTAL_FAIL=$(echo "$control_json" | jq -r '.TotalFail // null')

    # Extract major and minor section numbers
    MAJOR=$(echo "$ID" | cut -d. -f1)
    MINOR=$(echo "$ID" | cut -d. -f1-2)

    # Print major section header if changed
    if [ "$MAJOR" != "$CURRENT_MAJOR" ]; then
        CURRENT_MAJOR="$MAJOR"
        SECTION_NAME=$(get_section_title "$MAJOR")
        echo ""
        echo "## Control Type: $SECTION_NAME"
    fi

    # Print minor section header if changed
    if [ "$MINOR" != "$CURRENT_MINOR" ]; then
        CURRENT_MINOR="$MINOR"
        MINOR_TITLE=$(get_section_title "$MINOR")
        MAJOR_TITLE=$(get_section_title "$MAJOR")
        if [ -n "$MINOR_TITLE" ] && [ "$MINOR_TITLE" != "$MAJOR_TITLE" ]; then
            echo ""
            echo "### $MINOR. $MINOR_TITLE"
        fi
    fi

    # Print control details
    echo ""
    echo "#### $ID: $NAME"
    echo ""
    echo "**Severity:** $SEVERITY"
    echo ""

    # Determine pass/fail status
    if [ "$TOTAL_FAIL" = "null" ]; then
        # Manual control without TotalFail field
        CONTROL_TYPE=$(get_control_type "$NAME")
        echo "**Result:** $CONTROL_TYPE check required"
    elif [ "$TOTAL_FAIL" = "0" ]; then
        # Pass
        echo "**Result:** 🟢 Pass"
    else
        # Fail
        echo "**Result:** 🔴 Fail"
        echo ""
        echo "_The issue is under investigation to provide a fix in a future KubeOne release_"
    fi

    echo ""
    echo "---"
done

# Print references section
cat << 'EOF'

## References

[audit-logging]: {{< ref "../../../tutorials/creating-clusters-oidc/#audit-logging" >}}
[encryption-providers]: {{< ref "../../../guides/encryption-providers/" >}}
[oidc]: {{< ref "../../../tutorials/creating-clusters-oidc/" >}}
[anon-req]: https://kubernetes.io/docs/reference/access-authn-authz/authentication/#anonymous-requests
[eventratelimit]: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#eventratelimit
[securitycontextdeny]: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#securitycontextdeny
EOF