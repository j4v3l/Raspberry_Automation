#!/bin/bash
cat << "EOF"
 __  __ _  ______ ___ ____  
|  \/  | |/ /  _ \_ _|  _ \ 
| |\/| | ' /| | | | || |_) |
| |  | | . \| |_| | ||  _ < 
|_|  |_|_|\_\____/___|_| \_\
                            
-----------------------------------------------------
by J4V3L (2023-11)
-----------------------------------------------------
EOF
echo "-----------------------------------------------------"

read -p "Enter the path where you want to create the folders: " folder_path

# Check if the folder_path exists and is a directory
if [ ! -d "$folder_path" ]; then
  echo "Error: The specified path does not exist or is not a directory."
  exit 1
fi

# Create an array to store folder names
folders=()

echo "Enter folder names (type 'done' to finish):"

while true; do
  read -p "Enter folder name: " folder_name

  # Sentinel value to break the loop
  if [[ $folder_name == "done" ]]; then
    break
  fi

  # Check for empty folder name
  if [[ -z $folder_name ]]; then
    echo "Folder name cannot be empty. Please try again."
    continue
  fi

  folder="${folder_path}/${folder_name}"

  # Check if the folder already exists
  if [ -d "$folder" ]; then
    echo "Folder '$folder_name' already exists at '$folder_path'."
    continue
  fi

  mkdir -p "$folder" && echo "Folder '$folder_name' created at '$folder_path'." || echo "Failed to create '$folder_name'."
  folders+=("$folder_name")
done

# Check if any folders were created
if [ ${#folders[@]} -eq 0 ]; then
  echo "No folders were created."
else
  echo "Folders created successfully."

  # Display the created folders in a table and column format
  echo -e "\nCreated folders:"
  echo -e "-----------------"
  echo "${folders[@]}" | column
fi
