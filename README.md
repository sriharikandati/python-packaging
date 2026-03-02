# Sample Project - Hello World CLI

A simple Python CLI application that demonstrates how to create a command-line tool that can be installed and used from any directory.

## Features

- 📦 Installable Python package
- 🖥️ Command-line interface
- 🚀 Accessible from any directory after installation

## What Does It Do?

This project provides a simple CLI command `sampleproject` that:
- Prints "Hello world" when run without arguments
- Prints "Hello {username}" when run with a username argument

## Quick Start

### 🚀 One-Line Installation (Curl Method)

```bash
curl -sSL https://raw.githubusercontent.com/yourusername/sampleproject/main/install.sh | bash
```

> **Note**: For production use, review [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for security best practices and alternative installation methods.

### 📦 Traditional Installation (Recommended)

Already installed! The package was installed with:
```bash
pip install -e .
```

Try it now:
```bash
sampleproject
sampleproject YourName
```

## Project Structure

```
sample/
├── sampleproject/          # Main package directory
│   ├── __init__.py        # Package initialization
│   └── cli.py             # CLI implementation
├── setup.py               # Package setup configuration
├── pyproject.toml         # Modern Python packaging configuration
└── README.md              # This file
```

## How It Works

### 1. Package Structure
The project uses Python's packaging system to create an installable package:
- **sampleproject/**: The main package directory containing the code
- **__init__.py**: Makes the directory a Python package and defines the version
- **cli.py**: Contains the `main()` function that handles command-line arguments

### 2. Entry Points
The magic happens in the `setup.py` and `pyproject.toml` files:

```python
entry_points={
    "console_scripts": [
        "sampleproject=sampleproject.cli:main",
    ],
}
```

This creates a command-line script called `sampleproject` that calls the `main()` function from `sampleproject.cli` module.

### 3. CLI Logic
The CLI uses `sys.argv` to read command-line arguments:
- `sys.argv[0]` is the script name
- `sys.argv[1:]` contains the user-provided arguments

## Installation Methods

### Method 1: One-Line Curl Installation 🌐

Inspired by tools like Rust, Homebrew, and Poetry:

```bash
curl -sSL https://raw.githubusercontent.com/yourusername/sampleproject/main/install.sh | bash
```

**What this does:**
- ✅ Checks for Python 3.7+
- ✅ Prefers `pipx` for isolated installation
- ✅ Falls back to `pip --user` if needed
- ✅ Verifies installation
- ✅ Provides usage instructions

📖 **Learn more**: See [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for:
- How curl-based installation works
- Security considerations
- Hosting options for install.sh
- Real-world examples (Rust, npm, Homebrew)

### Method 2: Local Development Installation 💻

Development mode creates a link to your source code (changes are immediately reflected):

```bash
cd /Users/username/Documents/packaging/python\ project/sample
pip install -e .
```

### Method 3: Regular pip Installation 📦

```bash
cd /Users/username/Documents/packaging/python\ project/sample
pip install .
```

### Method 4: pipx (Recommended for CLI tools) ⚡

Install in an isolated environment:

```bash
pipx install /Users/username/Documents/packaging/python\ project/sample
```

### Method 5: Standalone Binary 🔨

For users without Python installed:

```bash
# Build the binary first
pip install pyinstaller
pyinstaller --onefile --name sampleproject sampleproject/cli.py

# Install the binary
chmod +x dist/sampleproject
sudo cp dist/sampleproject /usr/local/bin/
```

📖 **Learn more**: See [BINARY_BUILD_GUIDE.md](BINARY_BUILD_GUIDE.md) for:
- PyInstaller, PyOxidizer, Nuitka comparisons
- Cross-platform building
- GitHub Actions CI/CD
- Size optimization techniques

## Usage

After installation, you can use the `sampleproject` command from any directory:

### Print "Hello world"
```bash
sampleproject
```
**Output:** `Hello world`

### Print "Hello" with a username
```bash
sampleproject John
```
**Output:** `Hello John`

```bash
sampleproject Alice
```
**Output:** `Hello Alice`

## Uninstallation

To remove the package:

```bash
pip uninstall sampleproject
```

## Implementation Details

### How Python Packages Work

1. **Package Discovery**: `setuptools.find_packages()` automatically finds Python packages in your project
2. **Entry Points**: The `console_scripts` entry point creates an executable script in your Python environment's `bin/` directory
3. **PATH Integration**: When you install with pip, the script is added to your system PATH, making it accessible from anywhere

### What Happens During Installation?

1. Python reads `setup.py` and/or `pyproject.toml`
2. Copies the `sampleproject` package to your Python's `site-packages` directory
3. Creates an executable script (e.g., `/usr/local/bin/sampleproject` on Unix-like systems)
4. The executable script calls `sampleproject.cli:main` when you run `sampleproject` in terminal

### Development Mode (`pip install -e .`)

- Creates a symbolic link to your source code instead of copying it
- Changes to your code are immediately available without reinstalling
- Perfect for development and testing
- The `-e` stands for "editable"

## Customization

### Change the Command Name
Edit the entry point in `setup.py` or `pyproject.toml`:
```python
"my-custom-command=sampleproject.cli:main"
```

### Add More Functionality
Edit [sampleproject/cli.py](sampleproject/cli.py) to add more command-line options using libraries like:
- `argparse` - For complex argument parsing
- `click` - For creating beautiful command-line interfaces
- `typer` - For modern CLI applications with type hints

### Add Dependencies
In `setup.py`, add an `install_requires` list:
```python
install_requires=[
    "click>=8.0.0",
    "requests>=2.25.0",
],
```

## Requirements

- Python 3.7 or higher
- pip (Python package installer)

## License

MIT License - Feel free to use this project as a template for your own CLI applications!

## Troubleshooting

### Command not found after installation
- Ensure your Python scripts directory is in your PATH
- Try running: `python -m sampleproject.cli` as an alternative
- Check the installation with: `pip show sampleproject`

### Permission denied
- On Unix-like systems, you might need: `pip install --user .`
- Or use a virtual environment (recommended)

## Next Steps

Consider these improvements for your project:
1. Add unit tests using `pytest`
2. Add more command-line arguments and options
3. Package and publish to PyPI for others to use
4. Add a LICENSE file
5. Create a virtual environment for isolated development
6. Add GitHub Actions for CI/CD

## Virtual Environment (Recommended)

For a cleaner development environment:

```bash
# Create virtual environment
python -m venv venv

# Activate it
source venv/bin/activate  # On macOS/Linux
# or
venv\Scripts\activate  # On Windows

# Install in development mode
pip install -e .

# Use the command
sampleproject
sampleproject YourName
```

---

**Happy Coding! 🎉**
