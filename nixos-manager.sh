#!/usr/bin/env bash

# NixOS Configuration Manager - Interactive TUI
# Usage: ./nixos-manager.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
FLAKE_DIR="$HOME/.nix-config"
AVAILABLE_HOSTS=("nix-os" "vm-nix-os" "nix-server")

# Helper functions
print_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════╗"
    echo "║    NixOS Configuration Manager         ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

press_any_key() {
    echo ""
    read -n 1 -s -r -p "Press any key to continue..."
}

# Main menu
show_main_menu() {
    print_header
    echo -e "${BOLD}Main Menu:${NC}"
    echo ""
    echo "  1) Build & Switch Configuration"
    echo "  2) Update Flake Inputs"
    echo "  3) Check Flake"
    echo "  4) Garbage Collection"
    echo "  5) Show System Info"
    echo "  6) Format Nix Files"
    echo "  0) Exit"
    echo ""
    echo -n "Select option: "
}

# Build menu
build_menu() {
    print_header
    echo -e "${BOLD}Build Configuration:${NC}"
    echo ""
    echo "Available hosts:"
    for i in "${!AVAILABLE_HOSTS[@]}"; do
        echo "  $((i+1))) ${AVAILABLE_HOSTS[$i]}"
    done
    echo "  t) Test configuration (no switch)"
    echo "  0) Back to main menu"
    echo ""
    echo -n "Select host: "
}

# Build configuration
build_config() {
    local host=$1
    local mode=${2:-"switch"}
    
    print_header
    echo -e "${BOLD}Building configuration: ${CYAN}$host${NC} ${BOLD}(mode: $mode)${NC}"
    echo ""
    
    cd "$FLAKE_DIR" || exit 1
    
    print_info "Running nixos-rebuild $mode --flake .#$host"
    echo ""
    
    if sudo nixos-rebuild "$mode" --flake ".#$host"; then
        echo ""
        print_success "Configuration built successfully!"
    else
        echo ""
        print_error "Build failed!"
    fi
    
    press_any_key
}

# Update flake inputs
update_flake() {
    print_header
    echo -e "${BOLD}Update Flake Inputs${NC}"
    echo ""
    echo "  1) Update all inputs"
    echo "  2) Update specific input"
    echo "  0) Back to main menu"
    echo ""
    echo -n "Select option: "
    
    read -r option
    
    case $option in
        1)
            print_header
            echo -e "${BOLD}Updating all flake inputs...${NC}"
            echo ""
            
            cd "$FLAKE_DIR" || exit 1
            
            if nix flake update; then
                echo ""
                print_success "All inputs updated successfully!"
                echo ""
                print_info "Updated inputs:"
                nix flake metadata --json | grep -o '"lastModified":[^,]*' | head -5
            else
                echo ""
                print_error "Update failed!"
            fi
            
            press_any_key
            ;;
        2)
            print_header
            echo -e "${BOLD}Available inputs:${NC}"
            echo ""
            cd "$FLAKE_DIR" || exit 1
            nix flake metadata --json | grep -o '"[^"]*":{"locked"' | cut -d'"' -f2
            echo ""
            echo -n "Enter input name to update: "
            read -r input_name
            
            if [ -n "$input_name" ]; then
                print_header
                echo -e "${BOLD}Updating input: ${CYAN}$input_name${NC}"
                echo ""
                
                if nix flake lock --update-input "$input_name"; then
                    echo ""
                    print_success "Input $input_name updated successfully!"
                else
                    echo ""
                    print_error "Update failed!"
                fi
                
                press_any_key
            fi
            ;;
        0)
            return
            ;;
        *)
            print_error "Invalid option"
            sleep 1
            update_flake
            ;;
    esac
}

# Check flake
check_flake() {
    print_header
    echo -e "${BOLD}Checking Flake Configuration${NC}"
    echo ""
    
    cd "$FLAKE_DIR" || exit 1
    
    print_info "Running nix flake check..."
    echo ""
    
    if nix flake check; then
        echo ""
        print_success "Flake check passed!"
    else
        echo ""
        print_error "Flake check failed!"
    fi
    
    press_any_key
}

# Garbage collection
garbage_collection() {
    print_header
    echo -e "${BOLD}Garbage Collection${NC}"
    echo ""
    echo "  1) Delete generations older than 7 days"
    echo "  2) Delete generations older than 30 days"
    echo "  3) Delete specific generation"
    echo "  4) Clean all old generations (keep current)"
    echo "  5) Show current generations"
    echo "  0) Back to main menu"
    echo ""
    echo -n "Select option: "
    
    read -r option
    
    case $option in
        1)
            print_header
            echo -e "${BOLD}Deleting generations older than 7 days...${NC}"
            echo ""
            
            sudo nix-collect-garbage --delete-older-than 7d
            nix-collect-garbage --delete-older-than 7d
            
            echo ""
            print_success "Cleanup completed!"
            press_any_key
            ;;
        2)
            print_header
            echo -e "${BOLD}Deleting generations older than 30 days...${NC}"
            echo ""
            
            sudo nix-collect-garbage --delete-older-than 30d
            nix-collect-garbage --delete-older-than 30d
            
            echo ""
            print_success "Cleanup completed!"
            press_any_key
            ;;
        3)
            print_header
            echo -e "${BOLD}Current generations:${NC}"
            echo ""
            sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
            echo ""
            echo -n "Enter generation number to delete: "
            read -r gen_num
            
            if [ -n "$gen_num" ]; then
                sudo nix-env --delete-generations "$gen_num" --profile /nix/var/nix/profiles/system
                print_success "Generation $gen_num deleted!"
                press_any_key
            fi
            ;;
        4)
            print_header
            echo -e "${BOLD}Cleaning all old generations...${NC}"
            echo ""
            
            print_warning "This will delete ALL generations except the current one!"
            echo -n "Are you sure? (y/N): "
            read -r confirm
            
            if [[ $confirm =~ ^[Yy]$ ]]; then
                sudo nix-collect-garbage -d
                nix-collect-garbage -d
                echo ""
                print_success "All old generations cleaned!"
            else
                print_info "Cancelled"
            fi
            
            press_any_key
            ;;
        5)
            print_header
            echo -e "${BOLD}Current Generations:${NC}"
            echo ""
            echo -e "${CYAN}System:${NC}"
            sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
            echo ""
            echo -e "${CYAN}User:${NC}"
            nix-env --list-generations
            
            press_any_key
            ;;
        0)
            return
            ;;
        *)
            print_error "Invalid option"
            sleep 1
            garbage_collection
            ;;
    esac
}

# Show system info
show_system_info() {
    print_header
    echo -e "${BOLD}System Information${NC}"
    echo ""
    
    echo -e "${CYAN}NixOS Version:${NC}"
    nixos-version
    echo ""
    
    echo -e "${CYAN}Flake Info:${NC}"
    cd "$FLAKE_DIR" || exit 1
    nix flake metadata
    echo ""
    
    echo -e "${CYAN}Current Generation:${NC}"
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n 1
    echo ""
    
    echo -e "${CYAN}Store Size:${NC}"
    du -sh /nix/store 2>/dev/null || echo "Unable to calculate"
    echo ""
    
    press_any_key
}

# Format Nix files
format_nix_files() {
    print_header
    echo -e "${BOLD}Format Nix Files${NC}"
    echo ""
    
    cd "$FLAKE_DIR" || exit 1
    
    print_info "Formatting all .nix files..."
    echo ""
    
    if nix fmt; then
        echo ""
        print_success "All files formatted successfully!"
    else
        echo ""
        print_error "Formatting failed!"
    fi
    
    press_any_key
}

# Handle build menu selection
handle_build_menu() {
    build_menu
    read -r choice
    
    case $choice in
        0)
            return
            ;;
        t)
            build_menu
            echo ""
            echo -n "Select host to test: "
            read -r host_choice
            
            if [[ $host_choice =~ ^[1-9]$ ]] && [ "$host_choice" -le "${#AVAILABLE_HOSTS[@]}" ]; then
                local host="${AVAILABLE_HOSTS[$((host_choice-1))]}"
                build_config "$host" "test"
            else
                print_error "Invalid host selection"
                sleep 1
                handle_build_menu
            fi
            ;;
        *)
            if [[ $choice =~ ^[1-9]$ ]] && [ "$choice" -le "${#AVAILABLE_HOSTS[@]}" ]; then
                local host="${AVAILABLE_HOSTS[$((choice-1))]}"
                build_config "$host" "switch"
            else
                print_error "Invalid option"
                sleep 1
                handle_build_menu
            fi
            ;;
    esac
}

# Main loop
main() {
    # Check if running from correct directory
    if [ ! -f "$FLAKE_DIR/flake.nix" ]; then
        print_error "Flake not found at $FLAKE_DIR"
        echo "Please update FLAKE_DIR in the script or run from the correct directory"
        exit 1
    fi
    
    while true; do
        show_main_menu
        read -r option
        
        case $option in
            1)
                handle_build_menu
                ;;
            2)
                update_flake
                ;;
            3)
                check_flake
                ;;
            4)
                garbage_collection
                ;;
            5)
                show_system_info
                ;;
            6)
                format_nix_files
                ;;
            0)
                print_header
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option"
                sleep 1
                ;;
        esac
    done
}

# Run main function
main
