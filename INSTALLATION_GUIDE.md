# How Curl-Based Installation Works

This document explains how popular CLI tools implement installation via `curl` commands and how we've implemented it for sampleproject.

## Table of Contents
1. [How It Works](#how-it-works)
2. [Popular Examples](#popular-examples)
3. [Our Implementation](#our-implementation)
4. [Hosting Options](#hosting-options)
5. [Security Considerations](#security-considerations)
6. [Alternative Methods](#alternative-methods)

---

## How It Works

### The Basic Pattern

```bash
curl -sSL https://example.com/install.sh | bash
```

**Breaking it down:**

1. **`curl`** - Downloads content from a URL
   - `-s` (silent): Don't show progress bar
   - `-S` (show-error): Show errors if they occur
   - `-L` (location): Follow redirects
   - `-f` (fail): Fail silently on server errors

2. **`|` (pipe)** - Sends the downloaded script to the next command

3. **`bash`** - Executes the script in a bash shell

### The Flow

```
┌─────────┐      HTTP GET      ┌──────────┐
│  User   │ ─────────────────> │  Server  │
│Terminal │                     │          │
└─────────┘                     └──────────┘
     │                               │
     │      install.sh script        │
     │ <─────────────────────────────┤
     │                               │
     ▼                               │
┌─────────┐                          │
│  bash   │                          │
│Execute  │                          │
│Script   │                          │
└─────────┘                          │
     │                               │
     ▼                               │
┌─────────────────────────┐          │
│ Downloads & Installs    │          │
│ The Actual Package      │          │
└─────────────────────────┘          │
```

---

## Popular Examples

### 1. **Rust (rustup)**
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**What it does:**
- Downloads a shell script from rustup.rs
- Script detects OS and architecture
- Downloads appropriate Rust toolchain binary
- Installs to `~/.cargo/bin`
- Adds to PATH automatically

**Flags explained:**
- `--proto '=https'`: Only allow HTTPS protocol (security)
- `--tlsv1.2`: Minimum TLS version 1.2 (security)
- `-sSf`: Silent, show errors, fail on server errors

### 2. **Node Version Manager (nvm)**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

**What it does:**
- Downloads install script from GitHub
- Clones nvm repository to `~/.nvm`
- Adds initialization code to shell profile (~/.bashrc, ~/.zshrc)
- Sets up environment variables

**Flags explained:**
- `-o-`: Output to stdout (instead of file)

### 3. **Homebrew**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**What it does:**
- Uses command substitution `$()` to run downloaded script
- Installs Homebrew to `/usr/local` (or `/opt/homebrew` on Apple Silicon)
- May require sudo password for system directories

**Flags explained:**
- `-f`: Fail silently on HTTP errors
- `-s`: Silent mode
- `-S`: Show errors
- `-L`: Follow redirects

### 4. **Poetry (Python)**
```bash
curl -sSL https://install.python-poetry.org | python3 -
```

**What it does:**
- Downloads Python installation script
- Pipes to Python instead of bash
- Installs Poetry in isolated environment
- Adds to PATH

**Key difference:** Pipes to `python3 -` instead of `bash` (the `-` tells Python to read from stdin)

---

## Our Implementation

### Installation Script: `install.sh`

Our implementation for `sampleproject` follows best practices:

```bash
curl -sSL https://raw.githubusercontent.com/yourusername/sampleproject/main/install.sh | bash
```

### Script Features

1. **Error Handling**
   ```bash
   set -e  # Exit immediately on any error
   ```

2. **Dependency Checking**
   - Verifies Python 3.7+ is installed
   - Checks for pip3
   - Detects pipx for isolated installation

3. **Colored Output**
   - Uses ANSI color codes for better UX
   - Info (blue), Success (green), Error (red), Warning (yellow)

4. **Smart Installation**
   - Prefers `pipx` for isolated environments
   - Falls back to `pip --user` to avoid sudo
   - Handles PATH configuration issues

5. **Verification**
   - Tests the installed command
   - Provides troubleshooting steps

### Structure of install.sh

```bash
#!/bin/bash
set -e

# 1. Banner & Welcome
# 2. Check Python installation
# 3. Verify Python version >= 3.7
# 4. Check pip availability
# 5. Determine installation method (pipx vs pip)
# 6. Install the package
# 7. Verify installation & test
# 8. Provide usage instructions
```

---

## Hosting Options

To make `curl | bash` work, you need to host the `install.sh` script on a public URL.

### Option 1: GitHub (Free & Easy)

**Steps:**
1. Push your project to GitHub
2. Access the raw file:
   ```bash
   curl -sSL https://raw.githubusercontent.com/USERNAME/REPO/main/install.sh | bash
   ```

**Pros:**
- Free
- Version control included
- Easy to update
- Supports HTTPS

**Cons:**
- Requires GitHub account
- Subject to GitHub's availability

### Option 2: GitHub Pages

**Steps:**
1. Enable GitHub Pages in your repository settings
2. Create a custom domain (optional)
3. Access via:
   ```bash
   curl -sSL https://username.github.io/sampleproject/install.sh | bash
   ```

**Pros:**
- Custom domain support
- Better branding
- Still free

### Option 3: Your Own Server

**Steps:**
1. Upload `install.sh` to your web server
2. Ensure HTTPS is enabled
3. Set correct MIME type (text/plain or application/x-sh)

**Nginx example:**
```nginx
location /install.sh {
    add_header Content-Type text/plain;
    add_header Access-Control-Allow-Origin *;
}
```

**Pros:**
- Full control
- No external dependencies
- Can track analytics

**Cons:**
- Requires server maintenance
- Need to configure SSL/TLS

### Option 4: CDN Services

Use services like:
- **Cloudflare Pages** (free)
- **Netlify** (free tier)
- **Vercel** (free tier)
- **jsDelivr** (free CDN for GitHub)

**jsDelivr example:**
```bash
curl -sSL https://cdn.jsdelivr.net/gh/USERNAME/REPO@main/install.sh | bash
```

---

## Security Considerations

### ⚠️ Why `curl | bash` Can Be Dangerous

Piping to bash executes code immediately without review:

**Risks:**
1. **Malicious code** could be injected
2. **Man-in-the-middle attacks** if not using HTTPS
3. **Script could be changed** after you review it
4. **No verification** of script integrity

### 🛡️ Security Best Practices

#### 1. **Always Use HTTPS**
```bash
curl --proto '=https' --tlsv1.2 -sSf https://... | bash
```

#### 2. **Let Users Review First**
```bash
# Download first
curl -sSL https://example.com/install.sh -o install.sh

# Review the script
cat install.sh
# or
less install.sh

# Then execute
bash install.sh
```

#### 3. **Provide Checksums**
```bash
# SHA256 checksum verification
curl -sSL https://example.com/install.sh -o install.sh
echo "expected_sha256_hash  install.sh" | sha256sum --check
bash install.sh
```

#### 4. **Use Signed Releases**
```bash
# GPG signature verification
curl -sSL https://example.com/install.sh -o install.sh
curl -sSL https://example.com/install.sh.sig -o install.sh.sig
gpg --verify install.sh.sig install.sh
bash install.sh
```

#### 5. **Pin to Specific Versions**
```bash
# Use version tag instead of 'main' branch
curl -sSL https://raw.githubusercontent.com/user/repo/v1.0.0/install.sh | bash
```

### Our Script Security Features

1. **Exit on error**: `set -e`
2. **User installation**: Uses `--user` flag to avoid sudo
3. **Verification step**: Tests installation before completing
4. **Clear output**: Shows what's happening at each step
5. **Minimal privileges**: Doesn't request root access

---

## Alternative Methods

### Method 1: PyPI + pip (Recommended for Python packages)

```bash
pip install sampleproject
```

**Pros:**
- Standard Python way
- Version management
- Dependency resolution
- Easy uninstall

**Cons:**
- Requires pip knowledge
- PATH issues for users

### Method 2: pipx (Best for Python CLIs)

```bash
pipx install sampleproject
```

**Pros:**
- Isolated environment
- No dependency conflicts
- Automatic PATH setup

**Cons:**
- Requires pipx installation first

### Method 3: Standalone Binary

Use **PyInstaller** or **PyOxidizer** to create a single executable:

```bash
# After building binary
curl -L https://example.com/sampleproject-macos -o sampleproject
chmod +x sampleproject
sudo mv sampleproject /usr/local/bin/
```

**Pros:**
- No Python required on target system
- Fast startup
- Easy distribution

**Cons:**
- Large file size
- Need separate builds for each OS/architecture
- Build complexity

### Method 4: Package Managers

**Homebrew (macOS/Linux):**
```bash
brew install sampleproject
```

**apt (Debian/Ubuntu):**
```bash
apt install sampleproject
```

**Pros:**
- Native to the OS
- Trusted repositories
- Automatic updates

**Cons:**
- Requires package submission/approval
- Maintenance burden

---

## Implementation Checklist

To implement curl-based installation for your project:

- [x] Create `install.sh` script
- [x] Add error handling (`set -e`)
- [x] Check dependencies (Python, pip)
- [x] Add colored output for UX
- [x] Verify installation
- [ ] Host script on public URL (GitHub/Server)
- [ ] Test on different platforms (macOS, Linux)
- [ ] Add checksum verification (optional)
- [ ] Document security considerations
- [ ] Create uninstall script (optional)

---

## Testing Your Installation Script

### Local Test
```bash
# Test the script locally before hosting
bash install.sh
```

### Simulate Remote Installation
```bash
# Start a local HTTP server
python3 -m http.server 8000

# In another terminal
curl -sSL http://localhost:8000/install.sh | bash
```

### Test on Clean System
```bash
# Use Docker for isolated testing
docker run -it --rm ubuntu:latest bash
# Then run your curl installation command
```

---

## Complete Installation Flow

```
User runs: curl -sSL https://url/install.sh | bash
                    │
                    ▼
            ┌───────────────┐
            │ Download      │
            │ install.sh    │
            └───────┬───────┘
                    │
                    ▼
            ┌───────────────┐
            │ Check Python  │
            │ Version       │
            └───────┬───────┘
                    │
                    ▼
            ┌───────────────┐
            │ Check pip     │
            └───────┬───────┘
                    │
                    ▼
            ┌───────────────┐
            │ Install with  │
            │ pipx or pip   │
            └───────┬───────┘
                    │
                    ▼
            ┌───────────────┐
            │ Verify &      │
            │ Test Command  │
            └───────┬───────┘
                    │
                    ▼
            ┌───────────────┐
            │ Success! ✅   │
            └───────────────┘
```

---

## Next Steps

1. **Host your script**: Push to GitHub or your server
2. **Test thoroughly**: Try on different systems
3. **Add to README**: Document the installation method
4. **Consider alternatives**: Provide multiple installation options
5. **Monitor feedback**: Listen to user experiences

---

**Remember:** While `curl | bash` is convenient, always prioritize security and provide alternative installation methods!
