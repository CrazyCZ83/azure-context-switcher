# Azure Subscription Manager

A simple Bash script to manage and navigate Azure subscriptions from the command line.

## Overview

This utility script makes it easier to work with multiple Azure subscriptions by providing simple commands to:
- View your current active Azure subscription
- List all available subscriptions
- Search for subscriptions by name or ID
- Quickly switch between subscriptions

## Prerequisites

- Bash shell environment
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- Active Azure account with access to one or more subscriptions

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/azure-subscription-manager.git
   ```

2. Make the script executable:
   ```bash
   chmod +x azure-subscription-script.sh
   ```

3. Optionally, create a symbolic link to make it available system-wide:
   ```bash
   sudo ln -s $(pwd)/azure-subscription-script.sh /usr/local/bin/azsub
   ```

## Usage

```bash
./azure-subscription-script.sh         # Show current active subscription
./azure-subscription-script.sh -l      # List all subscriptions
./azure-subscription-script.sh -s ID   # Switch to subscription with specified ID
./azure-subscription-script.sh TERM    # Search subscriptions by name or ID
```

### Examples

Show your current active subscription:
```bash
./azure-subscription-script.sh
```

List all available subscriptions:
```bash
./azure-subscription-script.sh -l
```

Switch to a specific subscription using its ID:
```bash
./azure-subscription-script.sh -s 12345678-1234-1234-1234-123456789012
```

Search for subscriptions containing "dev" in their name or ID:
```bash
./azure-subscription-script.sh dev
```

## Features

- **Authentication Check**: Automatically verifies if you're logged into Azure
- **Formatted Output**: Clean tabular presentation of subscription information
- **Efficient Searching**: Quickly find subscriptions in large Azure environments
- **Easy Switching**: Change your active subscription with a simple command

## Troubleshooting

If you encounter any issues:

1. Ensure Azure CLI is installed and up to date
2. Verify you're logged in with `az login`
3. Check that you have proper permissions to view/access subscriptions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
