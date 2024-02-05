#!/bin/bash

# Define variables
SPECIFIED_PATH='/home/ubuntu'
REQUIRED_DISK_SPACE_GB=2

# Function to check mount points and disk space
check_mount_points_and_disk_space() {
    echo "Checking Mount Points..."
    for mount_point in "${SPECIFIED_PATH}"; do
        if [ -e "${mount_point}" ]; then
            echo "Mount Point ${mount_point} is available."
        else
            echo "Mount Point ${mount_point} is not available."
            exit 1
        fi
    done

    echo "Checking Disk Space..."
    free_disk_space_mb=$(df -m "${SPECIFIED_PATH}" | tail -n 1 | awk '{print $4}')
    echo "Free Disk Space (MB): ${free_disk_space_mb}"

    # Convert MB to GB
    free_disk_space_gb=$(echo "scale=2; ${free_disk_space_mb} / 1024.0" | bc)
    echo "Free Disk Space (GB): ${free_disk_space_gb}"

    if (( $(echo "${free_disk_space_gb} >= ${REQUIRED_DISK_SPACE_GB}" | bc -l) )); then
        echo "Disk Space is sufficient."
    else
        echo "Insufficient Disk Space. Required: ${REQUIRED_DISK_SPACE_GB}GB"
        exit 1
    fi
}

# Function to check tool version or display a warning if not found
check_tool_version() {
    tool_name=$1
    command_name=$2
    echo "Checking ${tool_name}..."
    
    if command -v ${command_name} &> /dev/null; then
        # Capture the output of the command
        version=$(${command_name} --version 2>&1)
        
        # Check if the output contains version information
        if [[ "${version}" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
            echo "${tool_name}: ${BASH_REMATCH}"
            echo -e "${tool_name}:\t${BASH_REMATCH}" >> tool_versions.txt
        else
            echo "Warning: Unable to determine ${tool_name} version."
            echo -e "${tool_name}:\tNot Found" >> tool_versions.txt
        fi
    else
        echo "Warning: ${tool_name} not found."
        echo -e "${tool_name}:\tNot Found" >> tool_versions.txt
    fi
}

# Main script
check_mount_points_and_disk_space

# Generate a text file with available versions
echo -e "Tool\tVersion" > tool_versions.txt

# Capture the version for each tool
check_tool_version "Python" "python3"
check_tool_version "Docker" "docker"
check_tool_version "Java" "java"
check_tool_version "CMake" "cmake"
check_tool_version "GCC" "gcc"
check_tool_version "G++" "g++"
check_tool_version "Git" "git"

# Capture Disk Space information
echo -e "Disk Space (GB):  ${free_disk_space_gb}" >> tool_versions.txt

echo "Tool versions and Disk Space are written to tool_versions.txt"
