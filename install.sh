#!/bin/bash
#
# Installation script for sampleproject
# Usage: curl -sSL https://your-domain.com/install.sh | bash
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for colored output
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Banner
echo ""
echo "╔════════════════════════════════════════╗"
echo "║   Sample Project Installer             ║"
echo "║   Version 0.1.0                        ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Check if Python is installed
info "Checking for Python installation..."
if ! command -v python3 &> /dev/null; then
    error "Python 3 is not installed. Please install Python 3.7 or higher."
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
info "Found Python $PYTHON_VERSION"

# Check Python version (must be >= 3.7)
PYTHON_MAJOR=$(python3 -c 'import sys; print(sys.version_info.major)')
PYTHON_MINOR=$(python3 -c 'import sys; print(sys.version_info.minor)')

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 7 ]); then
    error "Python 3.7 or higher is required. You have Python $PYTHON_VERSION"
    exit 1
fi

success "Python version check passed"

# Check if pip is installed
info "Checking for pip..."
if ! command -v pip3 &> /dev/null; then
    error "pip3 is not installed. Please install pip."
    exit 1
fi

success "pip3 found"

# Determine installation method
info "Checking for pipx (recommended for CLI tools)..."
if command -v pipx &> /dev/null; then
    INSTALL_METHOD="pipx"
    info "Using pipx for isolated installation"
else
    warning "pipx not found. Using pip (you can install pipx with: python3 -m pip install --user pipx)"
    INSTALL_METHOD="pip"
    info "Using pip for installation"
fi

# Install the package
echo ""
info "Installing sampleproject..."

if [ "$INSTALL_METHOD" = "pipx" ]; then
    # Install with pipx (isolated environment)
    if pipx install sampleproject; then
        success "sampleproject installed successfully with pipx!"
    else
        error "Installation failed with pipx. Trying with pip..."
        INSTALL_METHOD="pip"
    fi
fi

if [ "$INSTALL_METHOD" = "pip" ]; then
    # Install with pip
    # Using --user to avoid requiring sudo
    if python3 -m pip install --user sampleproject; then
        success "sampleproject installed successfully with pip!"
        
        # Check if user's local bin is in PATH
        USER_BIN="$HOME/.local/bin"
        if [[ ":$PATH:" != *":$USER_BIN:"* ]]; then
            warning "Warning: $USER_BIN is not in your PATH"
            echo ""
            echo "Add the following line to your ~/.bashrc or ~/.zshrc:"
            echo ""
            echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
            echo ""
        fi
    else
        error "Installation failed. Please check the error messages above."
        exit 1
    fi
fi

# Verify installation
echo ""
info "Verifying installation..."

if command -v sampleproject &> /dev/null; then
    success "Installation verified! Testing the command..."
    echo ""
    echo "Output of 'sampleproject':"
    echo "─────────────────────────────"
    sampleproject
    echo "─────────────────────────────"
    echo ""
    success "🎉 Installation complete! You can now use 'sampleproject' from anywhere."
else
    warning "Command 'sampleproject' not found in PATH."
    echo ""
    echo "You may need to:"
    echo "  1. Restart your terminal, or"
    echo "  2. Run: source ~/.bashrc (or source ~/.zshrc)"
    echo "  3. Add ~/.local/bin to your PATH"
fi

# Usage instructions
echo ""
info "Usage examples:"
echo "  sampleproject              # Prints 'Hello world'"
echo "  sampleproject YourName     # Prints 'Hello YourName'"
echo ""

# Uninstall instructions
info "To uninstall, run:"
if [ "$INSTALL_METHOD" = "pipx" ]; then
    echo "  pipx uninstall sampleproject"
else
    echo "  pip3 uninstall sampleproject"
fi

echo ""
success "Thank you for installing sampleproject! 🚀"
echo ""
