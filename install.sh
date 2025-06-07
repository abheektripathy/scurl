#!/bin/bash

# Smart Curl Installation Script
# Usage: curl -sSL https://your-domain.com/install-scurl.sh | bash

set -e

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="scurl"
SCRIPT_URL="https://raw.githubusercontent.com/yourusername/smart-curl/main/scurl"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_error() {
    echo -e "${RED}❌ Error:${NC} $1" >&2
}

print_success() {
    echo -e "${GREEN}✅ Success:${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ️  Info:${NC} $1"
}

# Check if running as root for system-wide install
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        print_info "Installing system-wide to $INSTALL_DIR"
    else
        # Try to install to user's local bin
        if [[ -d "$HOME/.local/bin" ]]; then
            INSTALL_DIR="$HOME/.local/bin"
        elif [[ -d "$HOME/bin" ]]; then
            INSTALL_DIR="$HOME/bin"
        else
            mkdir -p "$HOME/.local/bin"
            INSTALL_DIR="$HOME/.local/bin"
        fi
        print_info "Installing to user directory: $INSTALL_DIR"
        
        # Check if the directory is in PATH
        if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
            print_info "Adding $INSTALL_DIR to PATH in your shell profile"
            
            # Detect shell and add to appropriate profile
            if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
                print_info "Added to ~/.zshrc"
            elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
                print_info "Added to ~/.bashrc"
            else
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
                print_info "Added to ~/.profile"
            fi
        fi
    fi
}

# Download and install the script
install_scurl() {
    local temp_file=$(mktemp)
    
    print_info "Downloading Smart Curl..."
    
    # For this example, we'll embed the script directly
    # In practice, you'd download from your repository
    cat > "$temp_file" << 'EOF'
#!/bin/bash

# Smart Curl - Intelligent curl wrapper with typo detection and correction
# Version: 1.0
# Usage: scurl [curl options and arguments]

SCRIPT_NAME="Smart Curl"
VERSION="1.0"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}❌ Error:${NC} $1" >&2
}

print_success() {
    echo -e "${GREEN}✅ Success:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  Warning:${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️  Info:${NC} $1"
}

print_suggestion() {
    echo -e "${GREEN}💡 Suggestion:${NC} $1"
}

# Common curl option corrections
declare -A OPTION_CORRECTIONS=(
    ["-H"]="--header"
    ["-h"]="--header"
    ["--Head"]="--header"
    ["--Header"]="--header"
    ["-X"]="--request"
    ["-x"]="--request"
    ["--Request"]="--request"
    ["-d"]="--data"
    ["-D"]="--data"
    ["--Data"]="--data"
    ["-u"]="--user"
    ["-U"]="--user"
    ["--User"]="--user"
    ["-o"]="--output"
    ["-O"]="--output"
    ["--Output"]="--output"
    ["-L"]="--location"
    ["-l"]="--location"
    ["--Location"]="--location"
    ["-s"]="--silent"
    ["-S"]="--silent"
    ["--Silent"]="--silent"
    ["-v"]="--verbose"
    ["-V"]="--verbose"
    ["--Verbose"]="--verbose"
    ["-k"]="--insecure"
    ["-K"]="--insecure"
    ["--Insecure"]="--insecure"
    ["-i"]="--include"
    ["-I"]="--include"
    ["--Include"]="--include"
)

# Common HTTP methods
declare -A HTTP_METHODS=(
    ["get"]="GET"
    ["Get"]="GET"
    ["post"]="POST"
    ["Post"]="POST"
    ["put"]="PUT"
    ["Put"]="PUT"
    ["delete"]="DELETE"
    ["Delete"]="DELETE"
    ["patch"]="PATCH"
    ["Patch"]="PATCH"
    ["head"]="HEAD"
    ["Head"]="HEAD"
    ["options"]="OPTIONS"
    ["Options"]="OPTIONS"
)

# Function to check for common typos in options
check_option_typos() {
    local args=("$@")
    local corrected_args=()
    local corrections_made=false
    
    for arg in "${args[@]}"; do
        if [[ "$arg" =~ ^- ]]; then
            # Check if it's a known correction
            if [[ -n "${OPTION_CORRECTIONS[$arg]}" ]]; then
                print_warning "Correcting '$arg' to '${OPTION_CORRECTIONS[$arg]}'"
                corrected_args+=("${OPTION_CORRECTIONS[$arg]}")
                corrections_made=true
            else
                corrected_args+=("$arg")
            fi
        else
            corrected_args+=("$arg")
        fi
    done
    
    if $corrections_made; then
        echo "${corrected_args[@]}"
        return 0
    else
        echo "$@"
        return 1
    fi
}

# Function to check HTTP method corrections
check_http_method() {
    local args=("$@")
    local corrected_args=()
    local corrections_made=false
    local i=0
    
    while [ $i -lt ${#args[@]} ]; do
        if [[ "${args[$i]}" == "-X" ]] || [[ "${args[$i]}" == "--request" ]]; then
            corrected_args+=("${args[$i]}")
            ((i++))
            if [ $i -lt ${#args[@]} ]; then
                local method="${args[$i]}"
                if [[ -n "${HTTP_METHODS[$method]}" ]]; then
                    print_warning "Correcting HTTP method '$method' to '${HTTP_METHODS[$method]}'"
                    corrected_args+=("${HTTP_METHODS[$method]}")
                    corrections_made=true
                else
                    corrected_args+=("$method")
                fi
            fi
        else
            corrected_args+=("${args[$i]}")
        fi
        ((i++))
    done
    
    if $corrections_made; then
        echo "${corrected_args[@]}"
        return 0
    else
        echo "$@"
        return 1
    fi
}

# Function to check for missing quotes in JSON data
check_json_quotes() {
    local args=("$@")
    local corrected_args=()
    local corrections_made=false
    local i=0
    
    while [ $i -lt ${#args[@]} ]; do
        if [[ "${args[$i]}" == "-d" ]] || [[ "${args[$i]}" == "--data" ]]; then
            corrected_args+=("${args[$i]}")
            ((i++))
            if [ $i -lt ${#args[@]} ]; then
                local data="${args[$i]}"
                # Check if it looks like JSON but isn't quoted
                if [[ "$data" =~ ^\{.*\}$ ]] && [[ "$data" != \"*\" ]] && [[ "$data" != \'*\' ]]; then
                    print_warning "JSON data should be quoted. Adding quotes around: $data"
                    corrected_args+=("\"$data\"")
                    corrections_made=true
                else
                    corrected_args+=("$data")
                fi
            fi
        else
            corrected_args+=("${args[$i]}")
        fi
        ((i++))
    done
    
    if $corrections_made; then
        echo "${corrected_args[@]}"
        return 0
    else
        echo "$@"
        return 1
    fi
}

# Function to validate URL format
check_url_format() {
    local args=("$@")
    local url=""
    local has_corrections=false
    
    # Find the URL (usually the last argument without dashes)
    for arg in "${args[@]}"; do
        if [[ ! "$arg" =~ ^- ]] && [[ "$arg" =~ ^https?:// ]] || [[ "$arg" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then
            url="$arg"
            break
        fi
    done
    
    if [[ -n "$url" ]]; then
        # Check for common URL issues
        if [[ "$url" =~ ^http:// ]] && [[ ! "$url" =~ localhost ]] && [[ ! "$url" =~ 127\.0\.0\.1 ]]; then
            print_warning "Consider using HTTPS instead of HTTP for security: ${url/http:/https:}"
            has_corrections=true
        fi
        
        # Check for missing protocol
        if [[ ! "$url" =~ ^https?:// ]] && [[ "$url" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then
            print_warning "URL missing protocol. Consider: https://$url"
            has_corrections=true
        fi
    fi
    
    return $([ "$has_corrections" = true ] && echo 0 || echo 1)
}

# Function to check argument order
check_argument_order() {
    local args=("$@")
    local url_found=false
    local options_after_url=false
    
    for arg in "${args[@]}"; do
        if [[ ! "$arg" =~ ^- ]] && [[ "$arg" =~ ^https?:// ]] || [[ "$arg" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then
            url_found=true
        elif [[ "$url_found" == true ]] && [[ "$arg" =~ ^- ]]; then
            options_after_url=true
            break
        fi
    done
    
    if [[ "$options_after_url" == true ]]; then
        print_warning "Options should typically come before the URL for better readability"
        return 0
    fi
    
    return 1
}

# Function to suggest common missing options
suggest_missing_options() {
    local args=("$@")
    local has_suggestions=false
    
    # Check if Content-Type header is missing for POST/PUT/PATCH with data
    local has_data=false
    local has_content_type=false
    local http_method=""
    
    for ((i=0; i<${#args[@]}; i++)); do
        case "${args[$i]}" in
            "-d"|"--data")
                has_data=true
                ;;
            "-X"|"--request")
                if [ $((i+1)) -lt ${#args[@]} ]; then
                    http_method="${args[$((i+1))]}"
                fi
                ;;
            "-H"|"--header")
                if [ $((i+1)) -lt ${#args[@]} ] && [[ "${args[$((i+1))]}" =~ [Cc]ontent-[Tt]ype ]]; then
                    has_content_type=true
                fi
                ;;
        esac
    done
    
    if [[ "$has_data" == true ]] && [[ "$has_content_type" == false ]] && [[ "$http_method" =~ ^(POST|PUT|PATCH)$ ]]; then
        print_suggestion "Consider adding Content-Type header: -H \"Content-Type: application/json\""
        has_suggestions=true
    fi
    
    # Check for missing -L for redirects
    local has_location=false
    for arg in "${args[@]}"; do
        if [[ "$arg" == "-L" ]] || [[ "$arg" == "--location" ]]; then
            has_location=true
            break
        fi
    done
    
    if [[ "$has_location" == false ]]; then
        print_suggestion "Consider adding -L flag to follow redirects"
        has_suggestions=true
    fi
    
    return $([ "$has_suggestions" = true ] && echo 0 || echo 1)
}

# Main function
main() {
    if [[ $# -eq 0 ]]; then
        print_info "$SCRIPT_NAME v$VERSION - Intelligent curl wrapper"
        echo "Usage: scurl [curl options and arguments]"
        echo "This tool will detect common curl mistakes and suggest corrections."
        echo ""
        echo "Examples:"
        echo "  scurl -x POST -d '{\"key\":\"value\"}' https://api.example.com"
        echo "  scurl --Header 'Authorization: Bearer token' https://api.example.com"
        exit 0
    fi
    
    local original_args=("$@")
    local corrected_args=("${original_args[@]}")
    local any_corrections=false
    
    print_info "Analyzing curl command..."
    
    # Apply corrections
    local temp_args
    
    # Check option typos
    temp_args=($(check_option_typos "${corrected_args[@]}"))
    if [ $? -eq 0 ]; then
        corrected_args=("${temp_args[@]}")
        any_corrections=true
    fi
    
    # Check HTTP method corrections
    temp_args=($(check_http_method "${corrected_args[@]}"))
    if [ $? -eq 0 ]; then
        corrected_args=("${temp_args[@]}")
        any_corrections=true
    fi
    
    # Check JSON quotes
    temp_args=($(check_json_quotes "${corrected_args[@]}"))
    if [ $? -eq 0 ]; then
        corrected_args=("${temp_args[@]}")
        any_corrections=true
    fi
    
    # Check URL format (just warnings)
    check_url_format "${corrected_args[@]}"
    
    # Check argument order (just warnings)
    check_argument_order "${corrected_args[@]}"
    
    # Suggest missing options
    suggest_missing_options "${corrected_args[@]}"
    
    # Show corrected command if any corrections were made
    if [ "$any_corrections" = true ]; then
        echo ""
        print_success "Corrected command:"
        echo -e "${GREEN}curl ${corrected_args[*]}${NC}"
        echo ""
        read -p "Execute corrected command? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            curl "${corrected_args[@]}"
        else
            print_info "Command not executed."
        fi
    else
        print_success "No corrections needed. Executing original command..."
        curl "${original_args[@]}"
    fi
}

# Handle help flags
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    print_info "$SCRIPT_NAME v$VERSION"
    echo "A smart wrapper for curl that detects and corrects common mistakes."
    echo ""
    echo "Usage: scurl [curl options and arguments]"
    echo ""
    echo "Features:"
    echo "  • Corrects common option typos (-x → -X, --Head → --header)"
    echo "  • Fixes HTTP method capitalization (post → POST)"
    echo "  • Suggests missing quotes for JSON data"
    echo "  • Warns about HTTP vs HTTPS usage"
    echo "  • Suggests common missing options (Content-Type, -L)"
    echo ""
    echo "Examples:"
    echo "  scurl -x post -d '{key:value}' http://api.example.com"
    echo "  → Corrects to: curl -X POST -d '{\"key\":\"value\"}' https://api.example.com"
    exit 0
fi

# Execute main function
main "$@"
EOF
    
    print_info "Installing to $INSTALL_DIR/$SCRIPT_NAME..."
    
    # Copy to install directory
    cp "$temp_file" "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    # Clean up
    rm "$temp_file"
    
    print_success "Smart Curl installed successfully!"
    print_info "You can now use 'scurl' instead of 'curl'"
    
    # Test installation
    if command -v scurl &> /dev/null; then
        print_success "Installation verified - 'scurl' is available in your PATH"
    else
        print_error "Installation completed but 'scurl' is not in your PATH"
        print_info "You may need to restart your terminal or run: source ~/.bashrc"
    fi
}

# Main installation process
main() {
    print_info "Smart Curl Installation Starting..."
    
    # Check dependencies
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed. Please install curl first."
        exit 1
    fi
    
    # Check permissions and set install directory
    check_permissions
    
    # Install the script
    install_scurl
    
    echo ""
    print_success "Installation complete!"
    echo ""
    echo "Try it out:"
    echo "  scurl --help"
    echo "  scurl -x post -d '{name:john}' httpbin.org/post"
    echo ""
}

# Run main function
main "$@"