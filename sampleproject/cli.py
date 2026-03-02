"""Command-line interface for sampleproject."""

import sys


def main():
    """
    Main entry point for the CLI.
    
    Usage:
        sampleproject          -> prints "Hello world"
        sampleproject username -> prints "Hello username"
    """
    # Get command-line arguments (excluding the script name)
    args = sys.argv[1:]
    
    if len(args) == 0:
        # No arguments provided - print "Hello world"
        print("Hello world")
    elif len(args) == 1:
        # One argument provided - print "Hello {username}"
        username = args[0]
        print(f"Hello {username}")
    else:
        # Too many arguments
        print("Usage: sampleproject [username]")
        sys.exit(1)


if __name__ == "__main__":
    main()
