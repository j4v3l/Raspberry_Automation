#!/bin/bash

read -p "Enter the number of folders you want to create: " num_folders
read -p "Enter the path where you want to create the folders: " folder_path

# Check if the folder_path exists and is a directory
if [ ! -d "$folder_path" ]; then
  echo "Error: The specified path does not exist or is not a directory."
  exit 1
fi

# Create an array to store folder names
folders=()

# Create the folders
for ((i = 1; i <= num_folders; i++)); do
  read -p "Enter the name for folder $i: " folder_name
  folder="${folder_path}/${folder_name}"
  sudo mkdir -p "$folder"
  sudo chown -R $(whoami) "$folder" # Change ownership to the current user
  echo "Folder '$folder_name' created at '$folder_path'."
  folders+=("$folder_name")
done

echo "All $num_folders folders created successfully."

# Display the created folders in a table and column format
echo -e "\nCreated folders:"
echo -e "-----------------"
echo "${folders[@]}" | column
