#!/usr/bin/env bash

# GIFme Setup Script
# Helps set up GIFme for smooth monthly usage

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="${SCRIPT_DIR}/.gifme.conf"
readonly EXAMPLE_CONFIG="${SCRIPT_DIR}/.gifme.conf.example"

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() {
    echo -e "${BLUE}[SETUP]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

echo "🎬 GIFme Setup Wizard"
echo "===================="
echo ""

# Check if config already exists
if [ -f "$CONFIG_FILE" ]; then
    log_warning "Configuration file already exists: .gifme.conf"
    echo -n "Do you want to overwrite it? (y/N): "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "Setup cancelled. Existing configuration preserved."
        exit 0
    fi
fi

# Copy example config
if [ -f "$EXAMPLE_CONFIG" ]; then
    cp "$EXAMPLE_CONFIG" "$CONFIG_FILE"
    log_success "Created configuration file from example"
else
    # Create a basic config if example doesn't exist
    cat > "$CONFIG_FILE" << EOF
# GIFme Configuration File
# Customize as needed

# GIPHY API Key (required)
GIPHY_API_KEY_DEV=your_api_key_here

# Tag for GIF search (optional)
GIPHY_TAG=programming

# GIF rating filter (g, pg, pg-13, r)
GIPHY_RATING=g

# Backup retention days
BACKUP_RETENTION_DAYS=30
EOF
    log_success "Created basic configuration file"
fi

echo ""
log_info "Next steps:"
echo "1. Get your GIPHY API key from: https://developers.giphy.com/docs/api#quick-start-guide"
echo "2. Edit .gifme.conf and replace 'your_api_key_here' with your actual API key"
echo "3. Customize the GIPHY_TAG if desired (e.g., 'programming', 'cats', 'office')"
echo "4. Test the script: ./readme-gifme.sh"
echo ""

log_info "For monthly automation, add this to your crontab:"
echo "0 9 1 * * cd $SCRIPT_DIR && ./readme-gifme.sh"
echo ""
echo "To edit crontab: crontab -e"
echo ""

log_success "Setup complete! Happy GIF-ing! 🎉"