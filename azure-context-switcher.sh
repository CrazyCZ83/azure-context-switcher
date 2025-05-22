#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display usage information
usage() {
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  $0               - Show current active subscription"
    echo -e "  $0 -s <sub_id>   - Switch to the specified subscription"
    echo -e "  $0 -l            - List all Azure subscriptions"
    echo -e "  $0 <search_term> - Search subscriptions by name or ID"
    exit 1
}

# Function to search subscriptions
# This function is not directly called in a way that its output is colored here,
# as 'az account list' handles its own output.
# We will color the "Searching for..." message where this function would be invoked.
search_subscriptions() {
    local search_term="$1"
    # The "Searching for..." message is colored in the main logic
    az account list --query "[?contains(name, '${search_term}') || contains(id, '${search_term}')].{Name:name, SubscriptionId:id}" --output table
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI (az) is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo -e "${RED}Error: You are not logged in to Azure. Please run 'az login' first.${NC}"
    exit 1
fi

# Main script logic
if [ $# -eq 0 ]; then
    # No parameters: Show current active subscription
    echo -e "${GREEN}Current Active Subscription:${NC}"
    az account show --query "{Name:name, Id:id, TenantId:tenantId}" --output table
elif [ "$1" == "-l" ]; then
    # List all subscriptions with Name and ID
    echo -e "${GREEN}Azure Subscriptions (Name and ID):${NC}"
    az account list --query "[].{Name:name, SubscriptionId:id}" --output table
elif [ "$1" == "-s" ]; then
    # Check if subscription ID is provided
    if [ -z "$2" ]; then
        echo -e "${RED}Error: Subscription ID is required when using -s flag${NC}"
        usage
    fi

    # Switch to the specified subscription
    az account set --subscription "$2"
    if [ $? -eq 0 ]; then
        # Confirm the switch
        current_sub_name=$(az account show --query "name" -o tsv)
        current_sub_id=$(az account show --query "id" -o tsv)
        echo -e "${GREEN}Switched to Subscription:${NC}"
        echo -e "  ${CYAN}Name:${NC} $current_sub_name"
        echo -e "  ${CYAN}ID:${NC}   $current_sub_id"
    else
        echo -e "${RED}Failed to switch to subscription $2.${NC}"
    fi
elif [ $# -eq 1 ]; then
    # Search for subscriptions and handle single result
    search_term="$1"
    echo -e "${YELLOW}Searching for subscriptions matching: ${CYAN}$search_term${NC}"
    
    # Execute the az command and capture output
    # We capture stderr to check for "does not exist in cloud" type errors later if needed,
    # though 'az account list' itself might not produce them for valid queries.
    az_output_and_warnings=$(az account list --query "[?contains(name, '${search_term}') || contains(id, '${search_term}')].{Name:name, SubscriptionId:id}" --output table 2>&1)
    
    # Separate warnings from actual table output for parsing
    warnings=$(echo "$az_output_and_warnings" | grep '^WARNING:')
    az_output=$(echo "$az_output_and_warnings" | grep -v '^WARNING:')

    # Display warnings if any
    if [ -n "$warnings" ]; then
        echo -e "${YELLOW}$warnings${NC}"
    fi

    # Filter out header, separator, and empty lines from the actual table output to count results
    filtered_output=$(echo "$az_output" | grep -v '^-' | sed '1d' | grep -v '^$')
    result_lines=$(echo "$filtered_output" | wc -l)

    if [ "$result_lines" -eq 1 ]; then
        # Extract subscription name and ID from the single result line
        subscription_info=$(echo "$filtered_output")
        
        sub_id=$(echo "$subscription_info" | awk '{print $NF}')
        sub_name=$(echo "$subscription_info" | awk '{$NF=""; print $0}' | sed 's/^[ \t]*//;s/[ \t]*$//')

        echo -e "${YELLOW}Found one subscription:${NC}"
        echo -e "  ${CYAN}Name:${NC} $sub_name"
        echo -e "  ${CYAN}ID:${NC}   $sub_id"
        read -r -p "Do you want to switch to this subscription? (y/N) " response
        if [[ "$response" =~ ^([yY])$ ]]; then
            az account set --subscription "$sub_id"
            if [ $? -eq 0 ]; then
                current_sub_name_after_switch=$(az account show --query "name" -o tsv)
                current_sub_id_after_switch=$(az account show --query "id" -o tsv)
                echo -e "${GREEN}Switched to Subscription:${NC}"
                echo -e "  ${CYAN}Name:${NC} $current_sub_name_after_switch"
                echo -e "  ${CYAN}ID:${NC}   $current_sub_id_after_switch"
            else
                # Error message from 'az account set' should have been printed to stderr
                echo -e "${RED}Failed to switch to subscription $sub_id.${NC}"
            fi
        else
            echo -e "${YELLOW}Subscription switch cancelled.${NC}"
            # Display original table output (without our filtering) if cancelled, including any non-warning headers etc.
            echo "$az_output" 
        fi
    else
        # Display full az output (table part) if not exactly one result
        # Warnings were already displayed above.
        echo "$az_output"
    fi
else
    # Invalid parameters
    usage
fi
