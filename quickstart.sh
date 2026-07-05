#!/bin/bash
# Quick setup for Ethical Hacking Academy

echo "🛡️  ETHICAL HACKING ACADEMY - QUICK SETUP"
echo "=========================================="
echo ""

# Check Termux
if ! command -v termux-setup-storage &> /dev/null; then
    echo "❌ This script is designed for Termux!"
    exit 1
fi

# Install essential packages
echo "📦 Installing essential packages..."
pkg update -y
pkg install -y \
    git \
    wget \
    curl \
    python \
    python2 \
    nmap \
    sqlmap \
    hydra \
    john \
    nano \
    tar \
    jq \
    termux-api

# Install additional tools
echo ""
echo "🔧 Installing additional tools..."

# theHarvester
pip install theHarvester 2>/dev/null || git clone https://github.com/laramies/theHarvester.git ~/theHarvester

# dirsearch
git clone https://github.com/maurosoria/dirsearch.git ~/dirsearch 2>/dev/null

# nuclei (if available)
if [ ! -f "$PREFIX/bin/nuclei" ]; then
    echo "⚠️  Nuclei requires manual install (Go needed)"
fi

# Create desktop shortcut (if supported)
echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 Next steps:"
echo "1. Run: ./ethacademy.sh"
echo "2. Start with Step 1: Reconnaissance"
echo ""
echo "📚 Remember: Only test systems you own or have permission to test!"
