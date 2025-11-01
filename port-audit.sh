#!/bin/bash

################################################################################
# PortAudit - Bash script for auditing open ports and active services
# Author: Riantsoa RAJHONSON
# Description: Audits open ports and active services on Linux systems
################################################################################

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
OUTPUT_FILE=""
SHOW_PORTS=false
SHOW_SERVICES=false
SHOW_ALL=true

################################################################################
# Display help message
################################################################################
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Audit open ports and active services on Linux systems."
    echo ""
    echo "Options:"
    echo "  -p, --ports          Display only open ports"
    echo "  -s, --services       Display only active services"
    echo "  -a, --all            Display both ports and services (default)"
    echo "  -o, --output FILE    Save output to specified file"
    echo "  -h, --help           Display this help message"
    echo ""
    echo "Examples:"
    echo "  sudo $0                          # Show all information"
    echo "  sudo $0 --ports                  # Show only open ports"
    echo "  sudo $0 --services               # Show only active services"
    echo "  sudo $0 --output report.txt      # Save output to file"
    echo ""
    echo "Author: Riantsoa RAJHONSON"
}

################################################################################
# Check if script is run with root privileges
################################################################################
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: This script must be run as root${NC}"
        echo "Please use: sudo $0"
        exit 1
    fi
}

################################################################################
# Display timestamp
################################################################################
show_timestamp() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Audit Timestamp: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${BLUE}Hostname: $(hostname)${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

################################################################################
# Audit open ports
################################################################################
audit_ports() {
    echo -e "${GREEN}[+] OPEN PORTS AUDIT${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Check if ss command is available
    if command -v ss &> /dev/null; then
        echo -e "${YELLOW}TCP Listening Ports:${NC}"
        ss -tlnp | head -n 1
        ss -tlnp | grep LISTEN | awk '{print $1, $4, $5, $6}' | column -t
        echo ""
        
        echo -e "${YELLOW}UDP Listening Ports:${NC}"
        ss -ulnp | head -n 1
        ss -ulnp | awk '{print $1, $4, $5}' | column -t
        echo ""
    elif command -v netstat &> /dev/null; then
        echo -e "${YELLOW}TCP Listening Ports:${NC}"
        netstat -tlnp | grep LISTEN
        echo ""
        
        echo -e "${YELLOW}UDP Listening Ports:${NC}"
        netstat -ulnp
        echo ""
    else
        echo -e "${RED}Error: Neither 'ss' nor 'netstat' command found${NC}"
    fi
    
    # Additional port information using lsof if available
    if command -v lsof &> /dev/null; then
        echo -e "${YELLOW}Processes with Open Network Connections:${NC}"
        lsof -i -P -n | head -n 20
        echo ""
    fi
}

################################################################################
# Audit active services
################################################################################
audit_services() {
    echo -e "${GREEN}[+] ACTIVE SERVICES AUDIT${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Check which init system is being used
    if command -v systemctl &> /dev/null; then
        echo -e "${YELLOW}Active systemd services:${NC}"
        systemctl list-units --type=service --state=active --no-pager | head -n 30
        echo ""
        
        echo -e "${YELLOW}Services listening on network ports:${NC}"
        systemctl list-units --type=service --state=active --no-pager | \
            grep -E 'ssh|http|ftp|dns|mail|mysql|postgres|redis|mongodb'
        echo ""
    elif command -v service &> /dev/null; then
        echo -e "${YELLOW}Active services (SysV):${NC}"
        service --status-all 2>&1 | grep '+'
        echo ""
    else
        echo -e "${RED}Error: Unable to determine init system${NC}"
    fi
}

################################################################################
# Parse command line arguments
################################################################################
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--ports)
                SHOW_PORTS=true
                SHOW_ALL=false
                shift
                ;;
            -s|--services)
                SHOW_SERVICES=true
                SHOW_ALL=false
                shift
                ;;
            -a|--all)
                SHOW_ALL=true
                shift
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Error: Unknown option: $1${NC}"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
        esac
    done
}

################################################################################
# Main function
################################################################################
main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    # Check root privileges
    check_root
    
    # Redirect output to file if specified
    if [ -n "$OUTPUT_FILE" ]; then
        exec > >(tee "$OUTPUT_FILE")
    fi
    
    # Display header
    show_timestamp
    
    # Run audits based on options
    if [ "$SHOW_ALL" = true ]; then
        audit_ports
        echo ""
        audit_services
    elif [ "$SHOW_PORTS" = true ]; then
        audit_ports
    elif [ "$SHOW_SERVICES" = true ]; then
        audit_services
    fi
    
    # Display footer
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Audit completed at: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    
    if [ -n "$OUTPUT_FILE" ]; then
        echo -e "${GREEN}Output saved to: $OUTPUT_FILE${NC}"
    fi
}

# Run main function with all arguments
main "$@"
