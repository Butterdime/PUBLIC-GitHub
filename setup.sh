#!/usr/bin/env bash
set -e

echo "=========================================="
echo "Copilot Configuration Assistant - Setup"
echo "HUMAN AI FRAMEWORK"
echo "=========================================="
echo ""

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "✓ Python version: $PYTHON_VERSION"

# Install dependencies
echo ""
echo "📦 Installing Python dependencies..."
pip install -q -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✓ Dependencies installed successfully"
else
    echo "✗ Failed to install dependencies"
    exit 1
fi

# Verify installation
echo ""
echo "🔍 Verifying installation..."

python3 -c "import jsonschema; import requests; print('✓ All packages available')" 2>&1

# Create backup directory
echo ""
echo "📁 Creating backup directory..."
mkdir -p /tmp/backups/HUMAN_AI_FRAMEWORK
echo "✓ Backup directory created: /tmp/backups/HUMAN_AI_FRAMEWORK"

# Set permissions
echo ""
echo "🔐 Setting file permissions..."
chmod +x verify_jsons.py
chmod +x copilot.py
echo "✓ Scripts are now executable"

# Test JSON verification
echo ""
echo "🧪 Testing JSON verification..."
python3 verify_jsons.py

if [ $? -eq 0 ]; then
    echo "✓ JSON verification test passed"
else
    echo "✗ JSON verification test failed"
    exit 1
fi

# Display environment setup
echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "📋 Environment Variables (optional):"
echo "   export SPACE_NAME='HUMAN_AI_FRAMEWORK'"
echo "   export USER_GROUP='DevOps'"
echo "   export TRIGGER_SOURCE='manual'"
echo "   export BACKUP_PATH='/tmp/backups/HUMAN_AI_FRAMEWORK'"
echo "   export WEBHOOK_URL='https://your-webhook-url'"
echo ""
echo "🚀 Quick Commands:"
echo "   Verify JSON:    python3 verify_jsons.py"
echo "   Run Copilot:    export USER_GROUP=DevOps && python3 copilot.py"
echo "   View Logs:      cat audit/logs.json | python3 -m json.tool"
echo ""
echo "📚 Documentation:"
echo "   Full Guide:     docs/copilot-usage.md"
echo "   README:         README.md"
echo ""
echo "=========================================="
