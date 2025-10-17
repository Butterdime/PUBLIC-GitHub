# HUMAN AI FRAMEWORK - Copilot Configuration Assistant

[![Copilot Check](https://img.shields.io/badge/Copilot-Automated-blue)](/.github/workflows/copilot-check.yml)
[![Python](https://img.shields.io/badge/Python-3.11-green)](https://www.python.org/)

Automated configuration management system for the HUMAN AI FRAMEWORK with JSON verification, backup synchronization, audit logging, and governance enforcement.

## 🎯 Quick Start

### Prerequisites
```bash
pip install -r requirements.txt
```

### Run Copilot
```bash
# Set DevOps authorization
export USER_GROUP=DevOps

# Run the full Copilot system
python copilot.py
```

### Verify JSON Only
```bash
python verify_jsons.py
```

## 📁 Project Structure

```
HUMAN_AI_FRAMEWORK/
├── app.py                      # Flask application
├── copilot.py                  # Main Copilot orchestrator
├── verify_jsons.py             # JSON schema validator
├── requirements.txt            # Python dependencies
├── docker-compose.yml          # Docker configuration
├── Dockerfile                  # Container image
├── setup.sh                    # Setup script
│
├── config/                     # Configuration files
│   ├── ports.json             # Port configuration
│   └── json/                  # JSON configurations
│       ├── service.json       # Service settings
│       └── logging.json       # Logging configuration
│
├── audit/                      # Audit trails
│   └── logs.json              # Operation logs
│
├── docs/                       # Documentation
│   └── copilot-usage.md       # Complete usage guide
│
└── .github/                    # CI/CD
    └── workflows/
        └── copilot-check.yml  # Automation pipeline
```

## 🤖 Copilot Responsibilities

### 1️⃣ Initialization
- Reads `SPACE_NAME` environment variable
- Locates authoritative JSON directory

### 2️⃣ Verification
- Executes `verify_jsons.py` against all JSON files
- Validates against schemas
- Aborts on failure with notifications

### 3️⃣ Port Configuration
- Reads approved port from `config/ports.json`
- Validates port configuration
- Injects into deployment manifests

### 4️⃣ Backup Synchronization
- Copies validated JSON files to backup
- Verifies integrity using SHA-256 checksums
- Supports local and cloud storage

### 5️⃣ Audit Logging
- Appends timestamped entries to `audit/logs.json`
- Records action, outcome, trigger source
- Maintains complete audit trail

### 6️⃣ Governance Enforcement
- Restricts writes to approved directories
- Requires "DevOps" group for manual runs
- Escalates unauthorized access attempts

### 7️⃣ Notifications
- **Success:** "Configuration verified, backup completed, audit logged."
- **Failure:** Detailed diagnostics

### 8️⃣ CI/CD Integration
- Runs on commits to `main`
- Triggers on Pull Requests
- Blocks merges on failure

### 9️⃣ Documentation
- Maintains `docs/copilot-usage.md`
- Provides troubleshooting guides
- Documents configuration changes

## 🚀 Usage Examples

### Automatic (CI/CD)
Copilot runs automatically on:
- Push to `main` branch
- Pull Requests
- Manual GitHub Actions dispatch

### Manual Local Run
```bash
export SPACE_NAME="HUMAN_AI_FRAMEWORK"
export USER_GROUP="DevOps"
export TRIGGER_SOURCE="manual"
python copilot.py
```

### Verification Only
```bash
python verify_jsons.py
```

## 📊 Sample Output

```
🚀 Starting Copilot Assistant
============================================================
🤖 Copilot Assistant initialized for HUMAN_AI_FRAMEWORK
   Config directory: config/json
   Trigger source: manual

🔐 Step 6: Enforcing governance policies...
✅ Write operations restricted to: config, audit
✅ User group authorized: DevOps

🔍 Step 2: Running JSON verification...
✅ logging.json: Valid
✅ service.json: Valid
✅ JSON verification passed

⚙️  Step 3: Configuring ports...
✅ Port configuration loaded: 8080/tcp

💾 Step 4: Backing up configuration files...
✅ Backed up: logging.json
✅ Backed up: service.json
✅ Backup completed

📢 Notification (success):
✅ Configuration verified, backup completed, audit logged.

============================================================
✅ Copilot Assistant completed successfully
============================================================
```

## 🔧 Configuration Files

### `config/ports.json`
```json
{
  "approved_port": 8080,
  "protocol": "tcp",
  "description": "Primary application port"
}
```

### `config/json/service.json`
Service configuration including features, limits, and integrations.

### `config/json/logging.json`
Logging configuration with output targets and formats.

## 📝 Audit Logs

View audit trail:
```bash
cat audit/logs.json | python -m json.tool
```

Sample entry:
```json
{
  "timestamp": "2025-10-17T12:00:00",
  "action": "verify",
  "outcome": "success",
  "trigger_source": "CI pipeline",
  "details": "All JSON files validated"
}
```

## 🔐 Security & Governance

- **Access Control:** Manual runs require DevOps group
- **Write Restrictions:** Only approved directories modifiable
- **Audit Trail:** All operations logged with timestamps
- **Integrity Checks:** SHA-256 checksums for backups
- **Unauthorized Access:** Automatically escalated

## 📚 Documentation

Comprehensive usage guide available at:
- [`docs/copilot-usage.md`](/docs/copilot-usage.md)

Topics covered:
- Architecture overview
- Manual trigger steps
- Log interpretation
- Troubleshooting
- Security considerations
- CI/CD pipeline details

## 🛠️ Development

### Testing
```bash
# Install dependencies
pip install -r requirements.txt

# Test JSON verification
python verify_jsons.py

# Test full Copilot (requires DevOps auth)
export USER_GROUP=DevOps
python copilot.py

# View audit logs
cat audit/logs.json | python -m json.tool
```

### Adding New Configuration Files

1. Create JSON file in `config/json/`
2. Define schema in `verify_jsons.py` (if needed)
3. Test locally: `python verify_jsons.py`
4. Commit and push - Copilot runs automatically

## 🔄 CI/CD Pipeline

GitHub Actions workflow runs on:
- Commits to `main` branch
- Pull Requests
- Manual dispatch

**Artifacts:**
- Audit logs (90-day retention)
- Config backups (30-day retention)

**Status Checks:**
- Blocks merges on failure
- Comments on PRs with results

## 📦 Dependencies

- `Flask` - Web framework
- `Flask-SQLAlchemy` - Database ORM
- `python-dotenv` - Environment variables
- `jsonschema` - JSON validation
- `requests` - HTTP notifications

## 🐳 Docker Support

```bash
# Build image
docker-compose build

# Run container
docker-compose up

# Health check
curl http://localhost:8080/health
```

## 📞 Support

- **Review Audit Logs:** `cat audit/logs.json | python -m json.tool`
- **View Workflow Runs:** GitHub Actions tab
- **Manual Intervention:** Set `USER_GROUP=DevOps` and run locally

## 📄 License

This project is part of the HUMAN AI FRAMEWORK.

---

**Last Updated:** October 17, 2025  
**Version:** 1.0  
**Maintained By:** DevOps Team
