"""Setup configuration for sampleproject."""

from setuptools import setup, find_packages

# Read the README for long description
with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="sampleproject",
    version="0.1.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="A simple Hello World CLI application",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/sampleproject",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.7",
    entry_points={
        "console_scripts": [
            "sampleproject=sampleproject.cli:main",
        ],
    },
)
