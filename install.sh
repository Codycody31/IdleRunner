#!/bin/bash

TARGET_DIR="$HOME/IdleRunner" # Default installation directory

# Function to display help message
display_help() {
    echo "Usage: $0 [options]"
    echo "  -h  Display this help message."
}

# Function to check and install necessary commands
check_and_install_command() {
    local cmd=$1
    local package=$2
    if ! [ -x "$(command -v $cmd)" ]; then
        echo "$cmd is not installed. Installing..."
        install_package $package
    else
        echo "$cmd is already installed."
    fi
}

# Function to detect and use system's package manager
install_package() {
    local package=$1
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install $package
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install $package
    else
        echo "No known package manager found. Install $package manually."
        exit 1
    fi
}

# Check for --help option
if [[ " $* " == *" --help "* ]]; then
    display_help
    exit 0
fi

# Parse CLI arguments
while getopts ":h" opt; do
    case ${opt} in
    h) # process option h
        display_help
        exit 0
        ;;
    \?)
        echo "Usage: $0 [options]"
        exit 1
        ;;
    esac
done

# Welcome message
echo "Welcome to the setup script for IdleRunner!"

# Check if the repository already exists
if [ -d "$TARGET_DIR" ]; then
    echo "It seems the repository is already installed at $TARGET_DIR."
    echo "As we don't support updating the repository yet, please remove the old release before installing a new one."
    echo "Exiting setup..."
    exit 1
fi

echo "Checking if wget, unzip, and cron are installed..."
check_and_install_command "wget" "wget"
check_and_install_command "unzip" "unzip"
check_and_install_command "crontab" "cron"

# Ensure the target directory exists
mkdir -p "$TARGET_DIR"

echo "This script will install the repo into $TARGET_DIR..."

# Define the URL for the GitHub zip file
REPO_ZIP_URL="https://github.com/Drag-NDrop/IdleRunner/archive/refs/heads/main.zip"

# Fetch and unzip the repo
echo "Fetching and unzipping the repo..."
wget $REPO_ZIP_URL -O "$HOME/IdleRunner.zip"
unzip "$HOME/IdleRunner.zip" -d "$HOME/"

echo "Moving the repo to $TARGET_DIR..."

# Check if target dir is not empty
if [ "$(ls -A "$TARGET_DIR")" ]; then
    echo "Target directory is not empty. Cleaning up..."
    rm -f -r "${TARGET_DIR/*/}"
fi

# Move content to location
mv "$HOME"/IdleRunner-main/* "$TARGET_DIR"

# Clean up files
rm -f -r "$HOME/IdleRunner.zip" "$HOME/IdleRunner-main"

# TODO: Bring over logic from `InstallInstructions.sh` to set up the repo

echo "Setup complete!"
