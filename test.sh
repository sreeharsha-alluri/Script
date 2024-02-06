#!/bin/bash

# Define variables
SPECIFIED_PATH='/home/ubuntu'
REQUIRED_DISK_SPACE_GB=2

# Required versions
required_java_version='openjdk 11.0.13'
required_git_version='2.17.1'
required_python_version='2.7.17'
required_cmake_version='3.10.2'
required_gcc_version='7.5.0'
required_gplusplus_version='7.5.0'
required_docker_version='20.10.11'

# Function to check mount points and disk space
check_mount_points_and_disk_space() {
    echo "Checking Mount Points..."
    for mount_point in "${SPECIFIED_PATH}"; do
        if [ -e "${mount_point}" ]; then
            echo "Mount Point ${mount_point} is available."
        else
            echo "Mount Point ${mount_point} is not available."
            echo "Insufficient Disk Space. Required: ${REQUIRED_DISK_SPACE_GB}GB" >> tool_versions.txt
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
        echo "Insufficient Disk Space. Required: ${REQUIRED_DISK_SPACE_GB}GB" >> tool_versions.txt
        exit 1
    fi
}

# Function to check tool version or display a warning if not found
check_tool_version() {
    tool_name=$1
    command_name=$2
    required_version=$3
    echo "Checking ${tool_name}..."

    if command -v ${command_name} &> /dev/null; then
        # Capture the output of the command
        version=$(${command_name} --version 2>&1)

        # Check if the output contains version information
        if [[ "${version}" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
            captured_version="${BASH_REMATCH}"
            echo "Current ${tool_name} Version: ${captured_version}, Required Version: ${required_version}"
            echo -e "${tool_name}:\t${captured_version}" >> tool_versions.txt

            # Check for version mismatch
            if [[ "${captured_version}" != "${required_version}" ]]; then
                echo "Warning: Version mismatch for ${tool_name}. Required: ${required_version}, Found: ${captured_version}" >> tool_versions.txt
            fi
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
check_tool_version "Java" "java" "${required_java_version}"
check_tool_version "Git" "git" "${required_git_version}"
check_tool_version "Python" "python2" "${required_python_version}"
check_tool_version "CMake" "cmake" "${required_cmake_version}"
check_tool_version "GCC" "gcc" "${required_gcc_version}"
check_tool_version "G++" "g++" "${required_gplusplus_version}"
check_tool_version "Docker" "docker" "${required_docker_version}"

# Capture Disk Space information
echo -e "Disk Space (GB):  ${free_disk_space_gb}" >> tool_versions.txt

echo "Tool versions and Disk Space are written to tool_versions.txt"
