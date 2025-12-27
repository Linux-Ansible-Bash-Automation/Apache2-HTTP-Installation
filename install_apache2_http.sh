#!/bin/bash

set -o nounset 
set -o pipefail

# Initialize variables to avoid 'nounset' errors before they are assigned in functions
ANSIBLE_REMOTE_USER=""
BECOME_METHOD=""         # Used as extra-var 'play become method' (remote)

# --- Dynamically Generate User List ---
options_user=()
for i in {1..5}; do
    user_name=$(printf "aduser%02d" "$i")
    options_user+=("$user_name")
done 
options_user+=("sandeep")
options_user+=("ansible")
options_user+=("other")

# Function to choose the REMOTE become method (passed as an extra var)
choose_become_method() {
    echo "--- Select Remote Become Method (for tasks on target hosts) ---"
    options_become=("sudo" "dzdo")
    PS3="Select the remote become method (enter number):"
    
    select opt_become in "${options_become[@]}"; do
        case $opt_become in
            sudo|dzdo)
                BECOME_METHOD=$opt_become 
                break
                ;;
            *)
                echo "Invalid option $REPLY. Try again."
                ;;
        esac
    done
}


# Function to choose user (remains the same)
choose_user() {
    echo "--- Select Remote Ansible User ---"
    PS3="Select the remote Ansible user (enter number): "
    
    select opt_user in "${options_user[@]}"; do
    if [ "$opt_user" = "other" ]; then
        read -r -p "Enter custom username: " CUSTOM_USER
        if [ -n "$CUSTOM_USER" ]; then
            ANSIBLE REMOTEL USER=$CUSTOM_USER
            break
        else
            echo "Custom username cannot be empty."
        fi
        elif [ -n "$opt_user" ]; then
            ANSIBLE_REMOTE_USER=$opt_user 
            break
        else
            echo "Invalid option $REPLY. Try again."
        fi
    done
}

# Call the functions to get inputs in desired order
choose_user
choose_become_method # Ask for remote second

ansible-playbook -i hosts --ask-pass --become --ask-become-pass install_apache2_http.yml --extra-vars "play_become_method=$BECOME_METHOD"