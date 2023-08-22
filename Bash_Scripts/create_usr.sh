#!/bin/bash

# Colors for formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_colored() {
    color=$1
    message=$2
    echo -e "${color}${message}${NC}"
}

# Check if sudo is installed, install if not
if ! command -v sudo &>/dev/null; then
    print_colored $RED "sudo is not installed. Installing it..."
    su -c "pacman -S --noconfirm sudo"
fi

# Function to add user to sudoers file
add_user_to_sudoers() {
    username=$1
    echo "$username ALL=(ALL) ALL" >> /etc/sudoers
    print_colored $GREEN "User '$username' added to sudoers file."
}

# Menu for user actions
print_colored $GREEN "Select an action:"
echo "1. Create user"
echo "2. Remove user"
read -p "Enter your choice: " choice

case $choice in
    1)
        read -p "Enter username: " username
        read -s -p "Enter password: " password
        echo

        if id "$username" &>/dev/null; then
            print_colored $RED "User '$username' already exists."
            exit 1
        fi

        useradd -m $username
        echo -e "$password\n$password" | passwd $username &>/dev/null
        usermod -aG wheel $username
        add_user_to_sudoers $username

        print_colored $GREEN "User '$username' has been created, added to the sudo group, and added to the sudoers file."
        ;;
    2)
        read -p "Enter username to remove: " username

        if ! id "$username" &>/dev/null; then
            print_colored $RED "User '$username' does not exist."
            exit 1
        fi

        userdel -r $username

        print_colored $GREEN "User '$username' has been removed."
        ;;
    *)
        print_colored $RED "Invalid choice."
        exit 1
        ;;
esac
