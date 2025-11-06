#!/usr/bin/env bash

# GIFme: Enhanced README Generator with Animated GIFs
# Improved for smooth monthly usage and better error handling

set -euo pipefail  # Exit on any error, undefined variables, or pipe failures

# Colors for better user experience
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="${SCRIPT_DIR}/.gifme.conf"

# Load configuration file if it exists
if [ -f "$CONFIG_FILE" ]; then
    # Source the config file safely
    set +u  # Temporarily allow undefined variables
    source "$CONFIG_FILE"
    set -u
    log_info "Loaded configuration from .gifme.conf"
fi

# Configuration with defaults
api_key="${GIPHY_API_KEY_DEV:-}"
tag="${GIPHY_TAG:-}"
rating="${GIPHY_RATING:-g}"
backup_retention_days="${BACKUP_RETENTION_DAYS:-30}"
custom_readme="${README_FILE:-}"

readonly TEMP_DIR="${TMPDIR:-/tmp}/gifme-$$"
readonly RESPONSE_FILE="${TEMP_DIR}/giphy_response.json"
readonly README_FILE="${custom_readme:-${SCRIPT_DIR}/README.md}"
readonly BACKUP_FILE="${README_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log_info "Cleaned up temporary files"
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    log_info "Cleaning up old backups (older than $backup_retention_days days)..."
    
    local backup_dir
    backup_dir="$(dirname "$README_FILE")"
    local backup_pattern
    backup_pattern="$(basename "$README_FILE").backup.*"
    
    local cleaned_count=0
    while IFS= read -r -d '' backup_file; do
        rm -f "$backup_file"
        log_info "Removed old backup: $(basename "$backup_file")"
        ((cleaned_count++))
    done < <(find "$backup_dir" -name "$backup_pattern" -type f -mtime +"$backup_retention_days" -print0 2>/dev/null || true)
    
    if [ $cleaned_count -gt 0 ]; then
        log_success "Cleaned up $cleaned_count old backup(s)"
    else
        log_info "No old backups to clean up"
    fi
}

# Show help
show_help() {
    cat << EOF
GIFme: Enhanced README Generator with Animated GIFs

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
    -c, --config    Show configuration information
    -v, --version   Show version information
    -d, --dry-run   Simulate run without making changes

CONFIGURATION:
    Create a .gifme.conf file in the script directory with:
    
    GIPHY_API_KEY_DEV=your_api_key_here
    GIPHY_TAG=your_preferred_tag
    GIPHY_RATING=g
    README_FILE=/custom/path/to/README.md
    BACKUP_RETENTION_DAYS=30

ENVIRONMENT VARIABLES:
    GIPHY_API_KEY_DEV    Your GIPHY API key (required)
    GIPHY_TAG           Tag for GIF search (optional)
    GIPHY_RATING        GIF rating filter (g, pg, pg-13, r)
    README_FILE         Custom README file path
    BACKUP_RETENTION_DAYS  Days to keep backup files

EXAMPLES:
    # Basic usage (requires API key in config or environment)
    $0
    
    # With environment variables
    GIPHY_API_KEY_DEV=your_key GIPHY_TAG=coding $0
    
    # Set up monthly cron job
    echo "0 9 1 * * cd /path/to/gifme && ./readme-gifme.sh" | crontab -

For more information, visit: https://github.com/jeacovy/gifme-readme
EOF
}

# Show configuration status
show_config() {
    log_info "Current configuration:"
    echo "  Script directory: $SCRIPT_DIR"
    echo "  Config file: $CONFIG_FILE $([ -f "$CONFIG_FILE" ] && echo "(found)" || echo "(not found)")"
    echo "  README file: $README_FILE"
    echo "  API key: $([ -n "$api_key" ] && echo "configured" || echo "NOT SET")"
    echo "  Tag: ${tag:-"(random)"}"
    echo "  Rating: $rating"
    echo "  Backup retention: $backup_retention_days days"
    echo ""
    
    if [ ! -f "$CONFIG_FILE" ]; then
        log_info "To create a config file, copy .gifme.conf.example to .gifme.conf and edit it"
    fi
}

# Error handler
error_handler() {
    local exit_code=$?
    log_error "Script failed with exit code $exit_code"
    cleanup
    exit $exit_code
}

# Set up error handling and cleanup
trap cleanup EXIT
trap error_handler ERR

# Dependency checks
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_deps+=("curl")
    fi
    
    if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
        missing_deps+=("python")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_error "Please install them before running this script"
        exit 1
    fi
    
    log_success "All dependencies found"
}

# Validate configuration
validate_config() {
    log_info "Validating configuration..."
    
    if [ -z "$api_key" ]; then
        log_error "GIPHY API Key is required."
        log_error "Set the GIPHY_API_KEY_DEV environment variable or update the script."
        log_error "Get your API key from: https://developers.giphy.com/docs/api#quick-start-guide"
        exit 1
    fi
    
    if [ -z "$tag" ]; then
        log_warning "Tag is empty. GIPHY will pull a random GIF."
    else
        log_info "Using tag: '$tag'"
    fi
    
    log_success "Configuration validated"
}

# Create temporary directory
setup_temp_dir() {
    mkdir -p "$TEMP_DIR"
    log_info "Created temporary directory: $TEMP_DIR"
}

# Fetch GIF from GIPHY API
fetch_gif_id() {
    log_info "Fetching GIF from GIPHY API..."
    
    local giphy_endpoint="https://api.giphy.com/v1/gifs/random?api_key=${api_key}&tag=${tag}&rating=${rating}"
    
    # Use curl with proper error handling
    if ! curl -sS --fail --max-time 30 --retry 3 --retry-delay 2 "$giphy_endpoint" > "$RESPONSE_FILE"; then
        log_error "Failed to fetch GIF from GIPHY API"
        log_error "Please check your internet connection and API key"
        exit 1
    fi
    
    # Extract GIF ID using python with better error handling
    local python_cmd="python3"
    if ! command -v python3 >/dev/null 2>&1; then
        python_cmd="python"
    fi
    
    local gif_id
    if ! gif_id=$($python_cmd -c "
import sys, json
try:
    with open('$RESPONSE_FILE', 'r') as f:
        data = json.load(f)
    print(data['data']['id'])
except (KeyError, FileNotFoundError, json.JSONDecodeError) as e:
    print('', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null); then
        log_error "Failed to parse GIPHY API response"
        log_error "Please check your API key and try again"
        exit 1
    fi
    
    if [ -z "$gif_id" ]; then
        log_error "Empty GIF ID received from GIPHY API"
        log_error "Please verify your API key is correct"
        exit 1
    fi
    
    log_success "Successfully fetched GIF ID: $gif_id"
    echo "$gif_id"
}

# Create backup of README
backup_readme() {
    if [ -f "$README_FILE" ]; then
        cp "$README_FILE" "$BACKUP_FILE"
        log_info "Created backup: $(basename "$BACKUP_FILE")"
    fi
}

# Update README with new GIF
update_readme() {
    local gif_id="$1"
    local git_url="![READme//GIFme](https://media.giphy.com/media/${gif_id}/giphy.gif)"
    
    log_info "Updating README with new GIF..."
    
    # Create README if it doesn't exist
    if [ ! -f "$README_FILE" ]; then
        log_info "Creating new README file"
        touch "$README_FILE"
    fi
    
    # Create temporary file for the new README content
    local temp_readme="${TEMP_DIR}/new_readme.md"
    
    if [ -s "$README_FILE" ]; then
        # Remove existing GIPHY GIF lines if present
        grep -v "media.giphy.com" "$README_FILE" > "$temp_readme" || true
        
        # Add new GIF at the top
        {
            echo "$git_url"
            if [ -s "$temp_readme" ] && [ "$(head -n 1 "$temp_readme")" != "" ]; then
                echo ""
            fi
            cat "$temp_readme"
        } > "${temp_readme}.final"
    else
        # Empty or new file
        echo "$git_url" > "${temp_readme}.final"
    fi
    
    # Replace the original README
    mv "${temp_readme}.final" "$README_FILE"
    
    log_success "README updated successfully!"
}

# Display the updated README
show_readme() {
    log_info "Updated README content:"
    echo ""
    cat "$README_FILE"
}

# Main function
main() {
    local dry_run=false
    
    # Handle command line arguments
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--config)
            show_config
            exit 0
            ;;
        -v|--version)
            echo "GIFme v2.0.0 - Enhanced README Generator"
            exit 0
            ;;
        -d|--dry-run)
            dry_run=true
            log_info "Running in dry-run mode (no changes will be made)"
            ;;
        -*)
            log_error "Unknown option: $1"
            log_error "Use --help for usage information"
            exit 1
            ;;
    esac
    
    log_info "Starting GIFme README update..."
    
    check_dependencies
    validate_config
    setup_temp_dir
    
    if [ "$dry_run" = false ]; then
        backup_readme
        cleanup_old_backups
    else
        log_info "[DRY RUN] Would create backup: $(basename "$BACKUP_FILE")"
        log_info "[DRY RUN] Would clean up old backups (older than $backup_retention_days days)"
    fi
    
    local gif_id
    gif_id=$(fetch_gif_id)
    
    if [ "$dry_run" = false ]; then
        update_readme "$gif_id"
        show_readme
        log_success "GIFme update completed successfully!"
        log_info "Backup saved as: $(basename "$BACKUP_FILE")"
    else
        log_info "[DRY RUN] Would update README with GIF ID: $gif_id"
        log_info "[DRY RUN] Would add: ![READme//GIFme](https://media.giphy.com/media/${gif_id}/giphy.gif)"
        log_success "Dry run completed successfully!"
    fi
}

# Run main function
main "$@"