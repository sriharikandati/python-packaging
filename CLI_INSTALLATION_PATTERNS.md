# How Popular CLIs Handle Installation

A reference guide showing real-world installation patterns from popular CLI tools.

## Table of Contents
- [Rust & Cargo (rustup)](#rust--cargo-rustup)
- [Node Version Manager (nvm)](#node-version-manager-nvm)
- [Homebrew](#homebrew)
- [Poetry (Python)](#poetry-python)
- [deno](#deno)
- [kubectl](#kubectl)
- [GitHub CLI (gh)](#github-cli-gh)
- [Oh My Zsh](#oh-my-zsh)
- [Starship Prompt](#starship-prompt)
- [Comparison Table](#comparison-table)

---

## Rust & Cargo (rustup)

### Installation Command
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### What Happens
1. Downloads shell script from `sh.rustup.rs`
2. Detects operating system and CPU architecture
3. Downloads appropriate rustup binary
4. Installs to `~/.cargo/bin`
5. Adds cargo bin to PATH in shell profile
6. Offers customization options (default profile, etc.)

### Key Features
- ✅ Strict HTTPS and TLS 1.2 requirement
- ✅ Interactive installation (can customize)
- ✅ Multiple toolchain management
- ✅ Automatic PATH configuration
- ✅ Self-updating capability (`rustup update`)

### Implementation Details
```bash
# install.sh excerpt (simplified)
get_architecture() {
    local _ostype="$(uname -s)"
    local _cputype="$(uname -m)"
    
    case "$_ostype" in
        Darwin)
            _ostype=apple-darwin
            ;;
        Linux)
            _ostype=unknown-linux-gnu
            ;;
    esac
    
    echo "${_cputype}-${_ostype}"
}

ARCH=$(get_architecture)
DOWNLOAD_URL="https://static.rust-lang.org/rustup/dist/${ARCH}/rustup-init"
```

**File hosted at**: CloudFront CDN (AWS)

---

## Node Version Manager (nvm)

### Installation Command
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

### What Happens
1. Clones nvm repository to `~/.nvm`
2. Adds initialization script to shell profile (~/.bashrc, ~/.zshrc, ~/.profile)
3. Sets up environment variables
4. Downloads completions

### Key Features
- ✅ Hosted on GitHub (free)
- ✅ Version-specific URLs
- ✅ Supports multiple shells (bash, zsh, fish)
- ✅ No sudo required

### Implementation Details
```bash
# install.sh excerpt
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Clone repository
git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
cd "$NVM_DIR"
git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`

# Add to shell profile
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
```

**File hosted at**: GitHub Raw (free)

---

## Homebrew

### Installation Command
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### What Happens
1. Checks for macOS/Linux
2. Requests sudo password (needs root for `/usr/local`)
3. Installs Xcode Command Line Tools (if needed)
4. Creates directory structure
5. Downloads and installs Homebrew
6. Adds to PATH

### Key Features
- ✅ Command substitution pattern `$(curl ...)`
- ✅ Comprehensive pre-flight checks
- ✅ Interactive (shows what it will do first)
- ✅ Detailed logging

### Implementation Details
```bash
# Key difference: uses command substitution, not pipe
# This allows the script to be stored in a variable and inspected

# install.sh excerpt
abort() {
  printf "%s\n" "$@"
  exit 1
}

# Fail fast with a concise message
if ! [[ "$OSTYPE" =~ ^darwin|linux ]]; then
  abort "Homebrew is only supported on macOS and Linux."
fi

# Check for sudo access
if [[ -z "${HAVE_SUDO_ACCESS-}" ]]; then
  sudo -v
fi
```

**File hosted at**: GitHub Raw (free)

---

## Poetry (Python)

### Installation Command
```bash
curl -sSL https://install.python-poetry.org | python3 -
```

### What Happens
1. Downloads Python script (not bash!)
2. Pipes to Python interpreter
3. Creates isolated environment in `~/.local/share/pypoetry`
4. Downloads Poetry wheel
5. Installs with pip
6. Creates wrapper script in `~/.local/bin`

### Key Features
- ✅ Python script instead of shell script
- ✅ Uses venv for isolation
- ✅ Self-contained installation
- ✅ Cross-platform (works on Windows too)

### Implementation Details
```python
# install.py excerpt (simplified)
def install_poetry(version):
    # Create virtual environment
    venv_dir = DATA_DIR / "venv"
    venv.create(venv_dir, with_pip=True)
    
    # Install poetry in venv
    pip = venv_dir / "bin" / "pip"
    subprocess.run([pip, "install", f"poetry=={version}"])
    
    # Create wrapper script
    wrapper = BIN_DIR / "poetry"
    wrapper.write_text(f"#!/usr/bin/env bash\n{venv_dir}/bin/poetry \"$@\"")
    wrapper.chmod(0o755)
```

**File hosted at**: Custom domain (install.python-poetry.org)

---

## Deno

### Installation Command

**Unix/macOS:**
```bash
curl -fsSL https://deno.land/install.sh | sh
```

**Windows (PowerShell):**
```powershell
irm https://deno.land/install.ps1 | iex
```

### What Happens
1. Detects OS and architecture
2. Downloads latest release from GitHub
3. Extracts binary to `~/.deno/bin`
4. Adds to PATH in shell profile

### Key Features
- ✅ Separate scripts for Unix and Windows
- ✅ Downloads pre-built binaries (no compilation)
- ✅ Single executable (no dependencies)
- ✅ Version management built-in

### Implementation Details
```bash
# install.sh excerpt
deno_uri="https://github.com/denoland/deno/releases/latest/download/deno-${target}.zip"
deno_install="${DENO_INSTALL:-$HOME/.deno}"
bin_dir="$deno_install/bin"
exe="$bin_dir/deno"

# Download and extract
curl --fail --location --progress-bar --output "$exe.zip" "$deno_uri"
unzip -d "$bin_dir" -o "$exe.zip"
chmod +x "$exe"
rm "$exe.zip"
```

**File hosted at**: Custom domain (deno.land)

---

## kubectl

### Installation Command (Multiple Options)

**Curl:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

**Homebrew:**
```bash
brew install kubectl
```

### What Happens
1. Fetches latest version number
2. Downloads binary directly
3. Makes executable
4. Moves to /usr/local/bin

### Key Features
- ✅ Multiple installation methods
- ✅ Direct binary download (no script)
- ✅ Checksum verification available
- ✅ Official package manager support

### Implementation Details
```bash
# Get latest version
curl -L -s https://dl.k8s.io/release/stable.txt
# Returns: v1.29.0

# Download specific version
VERSION="v1.29.0"
OS="darwin"  # or linux
ARCH="amd64"  # or arm64
URL="https://dl.k8s.io/release/${VERSION}/bin/${OS}/${ARCH}/kubectl"

# Optional: Verify checksum
curl -LO "${URL}.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
```

**File hosted at**: Google Cloud CDN

---

## GitHub CLI (gh)

### Installation Command

**macOS:**
```bash
brew install gh
```

**Linux (Debian/Ubuntu):**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

### What Happens
- **macOS**: Uses Homebrew (standard package manager)
- **Linux**: Adds GitHub's package repository, then uses apt

### Key Features
- ✅ Native package managers (no custom script)
- ✅ GPG-signed packages
- ✅ Automatic updates via package manager
- ✅ Proper OS integration

**File hosted at**: cli.github.com (GitHub's infrastructure)

---

## Oh My Zsh

### Installation Command
```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### What Happens
1. Backs up existing ~/.zshrc
2. Clones oh-my-zsh repository to ~/.oh-my-zsh
3. Creates new .zshrc from template
4. Changes default shell to zsh (if not already)

### Key Features
- ✅ Backs up existing configuration
- ✅ Interactive prompts
- ✅ Preserves user customizations
- ✅ Automatic shell switching

### Implementation Details
```bash
# install.sh excerpt
main() {
  # Clone repository
  command_exists git || {
    echo "Error: git is not installed"
    exit 1
  }
  
  # Backup existing .zshrc
  if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.pre-oh-my-zsh
  fi
  
  # Clone repo
  git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
  
  # Copy template
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
  
  # Change shell
  chsh -s $(which zsh)
}
```

**File hosted at**: GitHub Raw

---

## Starship Prompt

### Installation Command
```bash
curl -sS https://starship.rs/install.sh | sh
```

### What Happens
1. Detects OS and architecture
2. Downloads pre-built binary from GitHub releases
3. Asks for installation location (default: /usr/local/bin)
4. Extracts and installs binary
5. Provides shell-specific init instructions

### Key Features
- ✅ Interactive installation path selection
- ✅ Downloads from GitHub Releases
- ✅ Handles multiple architectures
- ✅ Provides post-install instructions

### Implementation Details
```bash
# install.sh excerpt
get_architecture() {
  local arch="$(uname -m)"
  case "$arch" in
    x86_64) arch="x86_64" ;;
    aarch64|arm64) arch="aarch64" ;;
    *) echo "Unsupported architecture: $arch" && exit 1 ;;
  esac
  echo "$arch"
}

download_url="https://github.com/starship/starship/releases/latest/download/starship-${arch}-${platform}.tar.gz"
```

**File hosted at**: Custom domain (starship.rs) → GitHub Releases

---

## Comparison Table

| Tool | Method | Security | Hosting | Self-Update |
|------|--------|----------|---------|-------------|
| **Rust** | curl \| sh | HTTPS + TLS 1.2 | CloudFront | ✅ `rustup update` |
| **nvm** | curl \| bash | HTTPS | GitHub Raw | ✅ via script |
| **Homebrew** | bash -c "$(...)" | HTTPS | GitHub Raw | ✅ `brew update` |
| **Poetry** | curl \| python3 | HTTPS | Custom domain | ✅ built-in |
| **Deno** | curl \| sh | HTTPS | Custom domain | ✅ `deno upgrade` |
| **kubectl** | Direct download | HTTPS + checksum | GCS CDN | ❌ manual |
| **gh** | Package manager | GPG signed | APT/Brew | ✅ via pkg mgr |
| **Oh My Zsh** | sh -c "$(...)" | HTTPS | GitHub Raw | ✅ via script |
| **Starship** | curl \| sh | HTTPS | GitHub Releases | ❌ manual |

---

## Key Patterns

### 1. Single-Line Installers
```bash
curl -sSL URL | bash          # Most common
curl -fsSL URL | sh            # Alternative
/bin/bash -c "$(curl -L URL)"  # Command substitution
curl URL | python3 -           # Python script
```

### 2. Architecture Detection
```bash
uname -s  # OS: Darwin, Linux, etc.
uname -m  # CPU: x86_64, arm64, etc.
```

### 3. Common Install Locations
- `~/.local/bin` - User-level, no sudo
- `/usr/local/bin` - System-level, requires sudo
- `~/.{tool}` - Tool-specific directory

### 4. PATH Management
```bash
# Add to shell profile
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

### 5. Self-Update Patterns
```bash
# Built-in update command
rustup update
brew update && brew upgrade
gh upgrade

# Script re-run
curl -sSL install-url.sh | bash
```

---

## Best Practices Summary

1. **Use HTTPS** - Always
2. **Verify checksums** - When possible
3. **Detect platform** - OS + Architecture
4. **Minimal privileges** - Prefer `--user` installations
5. **Idempotent** - Can run multiple times safely
6. **Informative** - Show what's happening
7. **Reversible** - Provide uninstall instructions
8. **Self-contained** - Minimize dependencies

---

## Our Implementation

Based on these patterns, our `install.sh` implements:

✅ Error handling (`set -e`)  
✅ Platform detection  
✅ Dependency checking (Python, pip)  
✅ Colored output for UX  
✅ Smart installation (pipx → pip fallback)  
✅ PATH verification  
✅ Installation verification  
✅ Usage instructions  
✅ Uninstall documentation  

**Usage:**
```bash
curl -sSL https://raw.githubusercontent.com/yourusername/sampleproject/main/install.sh | bash
```

---

## Resources

- [Rust Install Documentation](https://www.rust-lang.org/tools/install)
- [Homebrew Installation](https://brew.sh)
- [Poetry Installation](https://python-poetry.org/docs/#installation)
- [Deno Installation](https://deno.land/manual/getting_started/installation)
- [GitHub Actions for Binary Releases](https://docs.github.com/en/actions/publishing-packages/publishing-binary-packages)

---

**Next**: See [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for implementation details and security considerations.
