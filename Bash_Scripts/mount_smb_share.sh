#!/bin/bash

# Function to read input securely
read_input_secure() {
  prompt=$1
  var_name=$2

  echo -n "$prompt: "
  IFS= read -rs "$var_name"
  echo
}

# Function to install cifs-utils package if not installed
install_cifs_utils() {
  if ! dpkg -l cifs-utils &>/dev/null; then
    echo "cifs-utils package not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y cifs-utils
  else
    echo "cifs-utils package is already installed."
  fi
}

# Function to install smbclient package if not installed
install_smbclient() {
  if ! dpkg -l smbclient &>/dev/null; then
    echo "smbclient package not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y smbclient
  else
    echo "smbclient package is already installed."
  fi
}

# Function to check if smbclient is installed and list SMB drives
list_smb_drives() {
  if ! dpkg -l smbclient &>/dev/null; then
    echo "smbclient package not found. Installing..."
    install_smbclient
  fi

  echo "Listing SMB drives..."
  smbclient -L "$1" -U "$2%$3" || exit 1
}

# Function to mount SMB share
mount_smb_share() {
  local smb_username=$1
  local smb_password
  local remote_host=$2
  local shared_dir=$3
  local mount_dir=$4

  # Read SMB password securely
  read_input_secure "Enter your SMB password" smb_password

  # Store the credentials in /opt/.creds file
  echo "username=${smb_username}" | sudo tee "/opt/.creds" > /dev/null
  echo "password=${smb_password}" | sudo tee -a "/opt/.creds" > /dev/null
  sudo chmod 400 "/opt/.creds"

  # Create the mount directory
  sudo mkdir -p "$mount_dir"

  # Mount the SMB share
  sudo mount -t cifs -o rw,vers=3.1.1,credentials="/opt/.creds" "//${remote_host}${shared_dir}" "$mount_dir"

  # Automount on system reboot
  echo -e "//${remote_host}${shared_dir} ${mount_dir} cifs vers=3.1.1,credentials=/opt/.creds 0 0" | sudo tee -a /etc/fstab

  echo "SMB share mounted successfully for: ${mount_dir}"
}

# Check and install cifs-utils if needed
install_cifs_utils

# Check and install smbclient if needed
install_smbclient

# Check and list SMB drives if smbclient is installed
read -p "Enter the remote host IP address or hostname: " remote_host
read_input_secure "Enter your SMB username" smb_username

list_smb_drives "$remote_host" "$smb_username" "$smb_password"

# Maximum number of SMB drives to mount
max_drives=4

# Loop through and mount each SMB share
for ((i = 1; i <= max_drives; i++)); do
  read -p "Enter the shared directory path for SMB drive ${i}: " shared_dir
  read -p "Enter the mount directory path for SMB drive ${i}: " mount_dir

  # Call the mount_smb_share function
  mount_smb_share "$smb_username" "$remote_host" "$shared_dir" "$mount_dir"
done
