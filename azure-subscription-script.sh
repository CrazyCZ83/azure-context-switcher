#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage:"
    echo "  $0               - Show current active subscription"
    echo "  $0 -s <sub_id>   - Switch to the specified subscription"
    echo "  $0 -l            - List all Azure subscriptions"
    echo "  $0 <search_term> - Search subscriptions by name or ID"
    exit 1
}

# Function to search subscriptions
search_subscriptions() {
    local search_term="$1"
    echo "Searching for subscriptions matching: $search_term"
    
    # Search using JMESPath query to filter subscriptions and show only Name and ID with column names
    az account list --query "[?contains(name, '${search_term}') || contains(id, '${search_term}')]" --output table --query "[].{Name:name, SubscriptionId:id}"
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI (az) is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo "Error: You are not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Main script logic
if [ $# -eq 0 ]; then
    # No parameters: Show current active subscription
    echo "Current Active Subscription:"
    az account show --query "{Name:name, Id:id, TenantId:tenantId}" --output table
elif [ "$1" == "-l" ]; then
    # List all subscriptions with Name and ID
    echo "Azure Subscriptions (Name and ID):"
    az account list --query "[].{Name:name, SubscriptionId:id}" --output table
elif [ "$1" == "-s" ]; then
    # Check if subscription ID is provided
    if [ -z "$2" ]; then
        echo "Error: Subscription ID is required when using -s flag"
        usage
    fi

    # Switch to the specified subscription
    az account set --subscription "$2"
    
    # Confirm the switch
    current_sub=$(az account show --query "{Name:name, Id:id}" --output tsv)
    echo "Switched to Subscription:"
    echo "$current_sub"
elif [ $# -eq 1 ]; then
    # Search for subscriptions
    search_subscriptions "$1"
else
    # Invalid parameters
    usage
fi
