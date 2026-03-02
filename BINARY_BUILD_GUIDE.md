# Building Standalone Binaries

This guide shows how to create standalone executables for sampleproject that don't require Python to be installed.

## Why Standalone Binaries?

**Advantages:**
- Users don't need Python installed
- Single file distribution
- Faster startup (no import overhead)
- Professional deployment option

**Disadvantages:**
- Larger file size (includes Python interpreter)
- Need separate builds for each OS/architecture
- More complex build process

---

## Method 1: PyInstaller (Recommended)

### Installation

```bash
pip install pyinstaller
```

### Basic Build

```bash
# From your project root
cd /Users/username/Documents/packaging/python\ project/sample

# Create standalone executable
pyinstaller --onefile --name sampleproject sampleproject/cli.py
```

### Options Explained

- `--onefile`: Bundle everything into a single executable
- `--name sampleproject`: Name of the output executable
- `sampleproject/cli.py`: Entry point script

### Advanced Build Script

Create `build_binary.sh`:

```bash
#!/bin/bash
set -e

echo "Building sampleproject binary..."

# Clean previous builds
rm -rf build dist *.spec

# Build for current platform
pyinstaller \
    --onefile \
    --name sampleproject \
    --clean \
    --noconfirm \
    --console \
    --add-data "README.md:." \
    sampleproject/cli.py

echo "Build complete! Binary is in dist/sampleproject"

# Test the binary
echo ""
echo "Testing binary..."
./dist/sampleproject
./dist/sampleproject TestUser

echo ""
echo "✅ Binary works!"
```

### Build Output

After running PyInstaller:
```
dist/
└── sampleproject          # Your standalone executable (macOS/Linux)
    # or
    └── sampleproject.exe  # Windows executable
```

### Installation of Binary

```bash
# Make executable
chmod +x dist/sampleproject

# Copy to system PATH
sudo cp dist/sampleproject /usr/local/bin/

# Now use from anywhere
sampleproject
sampleproject Alice
```

---

## Method 2: PyOxidizer (Modern Alternative)

PyOxidizer creates highly optimized Python applications.

### Installation

```bash
pip install pyoxidizer
```

### Initialize Project

```bash
pyoxidizer init-config-file
```

### Configuration (`pyoxidizer.bzl`)

```python
def make_exe():
    dist = default_python_distribution()
    
    policy = dist.make_python_packaging_policy()
    
    python_config = dist.make_python_interpreter_config()
    python_config.run_command = "from sampleproject.cli import main; main()"
    
    exe = dist.to_python_executable(
        name="sampleproject",
        packaging_policy=policy,
        config=python_config,
    )
    
    exe.add_python_resource(".", "sampleproject")
    
    return exe

def make_install(exe):
    files = FileManifest()
    files.add_python_resource(".", exe)
    return files

register_target("exe", make_exe)
register_target("install", make_install, depends=["exe"], default=True)

resolve_targets()
```

### Build

```bash
pyoxidizer build --release
```

---

## Method 3: Nuitka (Python Compiler)

Nuitka compiles Python to C, then to machine code.

### Installation

```bash
pip install nuitka
```

### Build Command

```bash
python -m nuitka \
    --standalone \
    --onefile \
    --output-filename=sampleproject \
    sampleproject/cli.py
```

### Advantages Over PyInstaller

- Faster execution (compiled code)
- Better optimization
- Smaller binary size (sometimes)

### Disadvantages

- Longer build time
- Requires C compiler
- More complex setup

---

## Cross-Platform Building

### For macOS (ARM64 and Intel)

```bash
# Build universal binary with PyInstaller
pyinstaller \
    --onefile \
    --target-arch universal2 \
    --name sampleproject \
    sampleproject/cli.py
```

### For Windows (from macOS/Linux)

Use Docker:

```bash
# Create Dockerfile
cat > Dockerfile.windows << 'EOF'
FROM python:3.11-windowsservercore
WORKDIR /app
COPY . .
RUN pip install pyinstaller
RUN pyinstaller --onefile --name sampleproject.exe sampleproject/cli.py
EOF

# Build
docker build -f Dockerfile.windows -t sampleproject-windows .
docker run --rm -v $(pwd)/dist:/app/dist sampleproject-windows
```

### For Linux (from macOS)

Use Docker:

```bash
# Create Dockerfile
cat > Dockerfile.linux << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install pyinstaller
RUN pyinstaller --onefile --name sampleproject sampleproject/cli.py
CMD ["cp", "/app/dist/sampleproject", "/output/"]
EOF

# Build
docker build -f Dockerfile.linux -t sampleproject-linux .
docker run --rm -v $(pwd)/dist-linux:/output sampleproject-linux
```

---

## Distribution Strategies

### 1. GitHub Releases

```bash
# Create release with binaries
gh release create v0.1.0 \
    dist/sampleproject-macos-arm64 \
    dist/sampleproject-macos-x86_64 \
    dist/sampleproject-linux-x86_64 \
    dist/sampleproject-windows-x86_64.exe
```

### 2. Installation Script for Binaries

Create `install-binary.sh`:

```bash
#!/bin/bash
set -e

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="x86_64"
        ;;
    arm64|aarch64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

BINARY_URL="https://github.com/USER/sampleproject/releases/latest/download/sampleproject-${OS}-${ARCH}"

echo "Downloading sampleproject for ${OS}-${ARCH}..."
curl -L "$BINARY_URL" -o sampleproject

echo "Installing..."
chmod +x sampleproject
sudo mv sampleproject /usr/local/bin/

echo "✅ Installation complete!"
sampleproject
```

Users install with:
```bash
curl -sSL https://your-domain.com/install-binary.sh | bash
```

### 3. Auto-Update Feature

Add to your CLI:

```python
import requests
import os
import sys

CURRENT_VERSION = "0.1.0"
GITHUB_API = "https://api.github.com/repos/USER/sampleproject/releases/latest"

def check_for_updates():
    try:
        response = requests.get(GITHUB_API)
        latest_version = response.json()["tag_name"].lstrip("v")
        
        if latest_version > CURRENT_VERSION:
            print(f"New version {latest_version} available!")
            print("Run: sampleproject --update")
    except:
        pass  # Silently fail if can't check
```

---

## Complete Build Pipeline

### GitHub Actions Workflow

Create `.github/workflows/build.yml`:

```yaml
name: Build Binaries

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    
    runs-on: ${{ matrix.os }}
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install pyinstaller
        pip install -e .
    
    - name: Build binary
      run: |
        pyinstaller --onefile --name sampleproject sampleproject/cli.py
    
    - name: Upload artifact
      uses: actions/upload-artifact@v3
      with:
        name: sampleproject-${{ runner.os }}
        path: dist/sampleproject*
    
    - name: Create Release
      if: startsWith(github.ref, 'refs/tags/')
      uses: softprops/action-gh-release@v1
      with:
        files: dist/sampleproject*
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Size Optimization

### Reduce Binary Size

1. **Exclude unnecessary modules:**
   ```bash
   pyinstaller --onefile \
       --exclude-module tkinter \
       --exclude-module matplotlib \
       --exclude-module PIL \
       sampleproject/cli.py
   ```

2. **Use UPX compression:**
   ```bash
   # Install UPX first
   # macOS: brew install upx
   # Linux: apt install upx
   
   pyinstaller --onefile --upx-dir /usr/local/bin sampleproject/cli.py
   ```

3. **Strip symbols (Linux/macOS):**
   ```bash
   strip dist/sampleproject
   ```

### Typical Sizes

- PyInstaller (no optimization): 8-15 MB
- PyInstaller (with UPX): 4-8 MB
- Nuitka: 5-10 MB
- PyOxidizer: 15-20 MB

---

## Testing Binaries

### Automated Tests

```bash
#!/bin/bash

echo "Testing binary..."

# Test 1: No arguments
OUTPUT=$(./dist/sampleproject)
if [ "$OUTPUT" != "Hello world" ]; then
    echo "❌ Test 1 failed"
    exit 1
fi
echo "✅ Test 1 passed"

# Test 2: With argument
OUTPUT=$(./dist/sampleproject TestUser)
if [ "$OUTPUT" != "Hello TestUser" ]; then
    echo "❌ Test 2 failed"
    exit 1
fi
echo "✅ Test 2 passed"

echo "All tests passed!"
```

---

## Comparison Table

| Method | Size | Speed | Build Time | Ease |
|--------|------|-------|------------|------|
| PyInstaller | Medium | Fast | Fast | ⭐⭐⭐⭐⭐ |
| PyOxidizer | Large | Fastest | Medium | ⭐⭐⭐ |
| Nuitka | Small | Fastest | Slow | ⭐⭐ |
| cx_Freeze | Medium | Fast | Fast | ⭐⭐⭐⭐ |

---

## Recommendation

**For sampleproject:**
- **Development**: Use `pip install -e .`
- **Simple distribution**: Use PyPI + pip
- **Non-Python users**: Use PyInstaller
- **Professional deployment**: Use PyOxidizer or Nuitka

**Start with PyInstaller** - it's the easiest and most reliable!
