#!/bin/bash

# Function to display manual page
display_manual() {
    echo "internsctl - Custom Linux Command"
    echo "Version: v0.1.0"
    echo
    echo "DESCRIPTION:"
    echo "  Custom Linux command for various operations."
    echo
    echo "USAGE:"
    echo "  internsctl [command] [options]"
    echo
    echo "COMMANDS:"
    echo "  cpu getinfo         Display CPU information."
    echo "  memory getinfo      Display memory information."
    echo "  user create <username>    Create a new user."
    echo "  user list                 List all regular users."
    echo "  user list --sudo-only    List users with sudo permissions."
    echo "  file getinfo <file-name>  Get information about a file."
    echo
    echo "OPTIONS:"
    echo "  --version, -v    Display the command version."
    echo "  --help, -h       Display this help message."
    echo
}

# Function to display help
display_help() {
    echo "USAGE: internsctl [command] [options]"
    echo
    echo "COMMANDS:"
    echo "  cpu getinfo         Display CPU information."
    echo "  memory getinfo      Display memory information."
    echo "  user create <username>    Create a new user."
    echo "  user list                 List all regular users."
    echo "  user list --sudo-only    List users with sudo permissions."
    echo "  file getinfo <file-name>  Get information about a file."
    echo
    echo "OPTIONS:"
    echo "  --version, -v    Display the command version."
    echo "  --help, -h       Display this help message."
    echo
}

# Function to display version
display_version() {
    echo "internsctl v0.1.0"
}

# Function to get CPU information
#!/bin/bash

# Function to get CPU information
get_cpu_info() {
    if command -v lscpu &> /dev/null; then
        # If lscpu is available, use it
        lscpu
    elif command -v wmic &> /dev/null; then
        # If lscpu is not available, try using wmic on Windows
        wmic cpu get caption,description,manufacturer,numberOfCores,numberOfLogicalProcessors
    else
        echo "Error: Unable to find a suitable command to retrieve CPU information."
    fi
}

# Function to get memory information
get_memory_info() {
    if command -v free &> /dev/null; then
        # If free is available, use it
        free
    elif command -v systeminfo &> /dev/null; then
        # If free is not available, try using systeminfo on Windows
        systeminfo | grep "Total Physical Memory"
    else
        echo "Error: Unable to find a suitable command to retrieve memory information."
    fi
}

# Function to create a new user
create_user() {
    username=$1
    if command -v useradd &> /dev/null; then
        # If useradd is available (Linux)
        sudo useradd -m $username
        sudo passwd $username
    elif command -v net &> /dev/null; then
        # If useradd is not available, try using net on Windows
        if net user $username &> /dev/null; then
            echo "Error: User '$username' already exists."
        else
            net user $username /add
            net user $username *
            echo "User '$username' created successfully."
        fi
    else
        echo "Error: Unable to find a suitable command to create a new user."
    fi
}

# Function to list users
list_users() {
    if command -v getent &> /dev/null; then
        # If getent is available (Linux)
        getent passwd | cut -d: -f1
    elif command -v net &> /dev/null; then
        # If getent is not available, try using net on Windows
        net user | awk -F" " '/User/{print $1}'
    else
        echo "Error: Unable to find a suitable command to list users."
    fi
}
# Function to get file information
get_file_info() {
    file=$1
    size=$(stat -c%s $file)
    permissions=$(stat -c%a $file)
    owner=$(stat -c%U $file)
    last_modified=$(stat -c%y $file)
    
    echo "File: $file"
    echo "Access: $permissions"
    echo "Size(B): $size"
    echo "Owner: $owner"
    echo "Modify: $last_modified"
}

# Main script logic
case "$1" in
    "cpu")
        case "$2" in
            "getinfo")
                get_cpu_info
                ;;
            *)
                display_help
                ;;
        esac
        ;;
    "memory")
        case "$2" in
            "getinfo")
                get_memory_info
                ;;
            *)
                display_help
                ;;
        esac
        ;;
    "user")
        case "$2" in
            "create")
                create_user $3
                ;;
            "list")
                list_users $3
                ;;
            *)
                display_help
                ;;
        esac
        ;;
    "file")
        case "$2" in
            "getinfo")
                shift 2
                get_file_info "$@"
                ;;
            *)
                display_help
                ;;
        esac
        ;;
    "--version" | "-v")
        display_version
        ;;
    "--help" | "-h")
        display_manual
        ;;
    *)
        display_help
        ;;
esac
