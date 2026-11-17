#!/usr/bin/env bash
# Migration script from dotfiles to NixOS
# This script helps extract configuration from the old dotfiles structure

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the dotfiles directory
DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NIX_DIR="${DOTFILES_ROOT}/nix"

if [ ! -d "$NIX_DIR" ]; then
    log_error "NixOS directory not found at $NIX_DIR"
    exit 1
fi

log_info "Starting migration from dotfiles to NixOS"
log_info "Dotfiles root: $DOTFILES_ROOT"
log_info "NixOS directory: $NIX_DIR"

# Step 1: Extract packages from packages.csv
log_step1() {
    log_info "Step 1: Extracting packages from packages.csv"
    
    PACKAGES_CSV="$DOTFILES_ROOT/setup/packages.csv"
    if [ ! -f "$PACKAGES_CSV" ]; then
        log_warning "packages.csv not found, skipping"
        return
    fi
    
    # Create packages list
    PACKAGES_FILE="$NIX_DIR/extracted-packages.txt"
    echo "# Extracted packages from packages.csv" > "$PACKAGES_FILE"
    echo "# Format: package_name (manager:package)" >> "$PACKAGES_FILE"
    echo "" >> "$PACKAGES_FILE"
    
    # Extract packages (skip comments and headers)
    grep -v '^#' "$PACKAGES_CSV" | grep -v '^Program' | while IFS=, read -r program predicate manager1 manager2 manager3 rest; do
        if [ -n "$program" ]; then
            echo "$program" >> "$PACKAGES_FILE"
        fi
    done
    
    log_success "Extracted $(wc -l < "$PACKAGES_FILE") packages to $PACKAGES_FILE"
}

# Step 2: Extract shell aliases
log_step2() {
    log_info "Step 2: Extracting shell aliases"
    
    ALIASES_FILE="$NIX_DIR/extracted-aliases.nix"
    echo "# Extracted shell aliases" > "$ALIASES_FILE"
    echo "# Add these to modules/home/shell.nix" >> "$ALIASES_FILE"
    echo "" >> "$ALIASES_FILE"
    echo "shellAliases = {" >> "$ALIASES_FILE"
    
    # Extract from shenv
    SHEENV="$DOTFILES_ROOT/core/shell/shenv"
    if [ -f "$SHEENV" ]; then
        grep -oP 'alias\s+\K[^=]+=[^"'"'"']+' "$SHEENV" 2>/dev/null | while IFS='=' read -r alias_name alias_value; do
            echo "  \"$alias_name\" = \"$alias_value\";" >> "$ALIASES_FILE"
        done
    fi
    
    # Extract from user aliases
    ALIASES_DIR="$DOTFILES_ROOT/core/shell/aliases"
    if [ -d "$ALIASES_DIR" ]; then
        find "$ALIASES_DIR" -name '*.aliases' -o -name 'aliases.*' | while read -r alias_file; do
            grep -oP '^alias\s+\K[^=]+=[^"'"'"']+' "$alias_file" 2>/dev/null | while IFS='=' read -r alias_name alias_value; do
                echo "  \"$alias_name\" = \"$alias_value\";" >> "$ALIASES_FILE"
            done
        done
    fi
    
    echo "};" >> "$ALIASES_FILE"
    
    log_success "Extracted aliases to $ALIASES_FILE"
}

# Step 3: Extract environment variables
log_step3() {
    log_info "Step 3: Extracting environment variables"
    
    ENV_FILE="$NIX_DIR/extracted-env.nix"
    echo "# Extracted environment variables" > "$ENV_FILE"
    echo "# Add these to modules/home/shell.nix or hosts/atan/home.nix" >> "$ENV_FILE"
    echo "" >> "$ENV_FILE"
    echo "sessionVariables = {" >> "$ENV_FILE"
    
    # Extract from profile
    PROFILE="$DOTFILES_ROOT/core/shell/profile"
    if [ -f "$PROFILE" ]; then
        grep -oP '^export\s+\K[A-Z_]+=' "$PROFILE" 2>/dev/null | while read -r var_name; do
            echo "  \"$var_name\" = \"TODO\";" >> "$ENV_FILE"
        done
    fi
    
    # Extract from xdgenv
    XDGENV="$DOTFILES_ROOT/core/shell/xdgenv"
    if [ -f "$XDGENV" ]; then
        grep -oP '^export\s+\KXDG_[A-Z_]+=' "$XDGENV" 2>/dev/null | while read -r var_name; do
            echo "  \"$var_name\" = \"TODO\";" >> "$ENV_FILE"
        done
    fi
    
    echo "};" >> "$ENV_FILE"
    
    log_success "Extracted environment variables to $ENV_FILE"
}

# Step 4: Extract dotfiles paths
log_step4() {
    log_info "Step 4: Extracting dotfile paths"
    
    DOTFILES_FILE="$NIX_DIR/extracted-dotfiles.nix"
    echo "# Extracted dotfile paths" > "$DOTFILES_FILE"
    echo "# Add these to modules/home/dotfiles.nix" >> "$DOTFILES_FILE"
    echo "" >> "$DOTFILES_FILE"
    
    # Find all link directives in .module.sh files
    find "$DOTFILES_ROOT/prog" -name '*.module.sh' -o -name '*.config.sh' | while read -r module_file; do
        log_info "Processing $module_file"
        
        # Extract link directives
        grep -oP '^\s*link\s+.*' "$module_file" 2>/dev/null | while read -r line; do
            echo "# From $(basename "$(dirname "$module_file")")" >> "$DOTFILES_FILE"
            echo "# $line" >> "$DOTFILES_FILE"
            echo "" >> "$DOTFILES_FILE"
        done
    done
    
    log_success "Extracted dotfile paths to $DOTFILES_FILE"
}

# Step 5: Generate NixOS module from extracted data
log_step5() {
    log_info "Step 5: Generating NixOS module from extracted data"
    
    GENERATED="$NIX_DIR/modules/home/extracted.nix"
    echo "# Auto-generated from dotfiles migration" > "$GENERATED"
    echo "# Review and customize this file" >> "$GENERATED"
    echo "" >> "$GENERATED"
    echo "{ config, pkgs, lib, ... }:" >> "$GENERATED"
    echo "" >> "$GENERATED"
    echo "{" >> "$GENERATED"
    echo "  # Packages from extracted-packages.txt" >> "$GENERATED"
    echo "  home.packages = with pkgs; [" >> "$GENERATED"
    
    # Add packages from extracted list
    if [ -f "$NIX_DIR/extracted-packages.txt" ]; then
        grep -v '^#' "$NIX_DIR/extracted-packages.txt" | grep -v '^$' | while read -r package; do
            echo "    $package" >> "$GENERATED"
        done
    fi
    
    echo "  ];" >> "$GENERATED"
    echo "" >> "$GENERATED"
    echo "  # Shell aliases from extracted-aliases.nix" >> "$GENERATED"
    echo "  programs.zsh.shellAliases = {" >> "$GENERATED"
    
    # Add aliases
    if [ -f "$NIX_DIR/extracted-aliases.nix" ]; then
        grep -A1000 'shellAliases = {' "$NIX_DIR/extracted-aliases.nix" | tail -n +2 | head -n -1 >> "$GENERATED"
    fi
    
    echo "  };" >> "$GENERATED"
    echo "" >> "$GENERATED"
    echo "  # Environment variables from extracted-env.nix" >> "$GENERATED"
    echo "  home.sessionVariables = {" >> "$GENERATED"
    
    # Add env vars
    if [ -f "$NIX_DIR/extracted-env.nix" ]; then
        grep -A1000 'sessionVariables = {' "$NIX_DIR/extracted-env.nix" | tail -n +2 | head -n -1 >> "$GENERATED"
    fi
    
    echo "  };" >> "$GENERATED"
    echo "}" >> "$GENERATED"
    
    log_success "Generated NixOS module at $GENERATED"
}

# Main migration
main() {
    log_step1
    log_step2
    log_step3
    log_step4
    log_step5
    
    log_success "Migration complete!"
    log_info "Review the extracted files in $NIX_DIR"
    log_info "Next steps:"
    log_info "  1. Review extracted-packages.txt and add to home.nix"
    log_info "  2. Review extracted-aliases.nix and add to shell.nix"
    log_info "  3. Review extracted-env.nix and add to shell.nix"
    log_info "  4. Review extracted-dotfiles.nix and add to dotfiles.nix"
    log_info "  5. Update hardware-configuration.nix for your system"
    log_info "  6. Run: sudo nixos-rebuild switch --flake $NIX_DIR#atan"
}

# Run main
main
