# Copilot Configuration Assistant - Usage Guide

## Overview

The **Copilot Configuration Assistant** is an automated system for the HUMAN AI FRAMEWORK that verifies and maintains JSON configuration files, synchronizes them to backup storage, maintains audit logs, and enforces governance policies. It ensures schema compliance, access control, and configuration integrity across all deployments.

## Architecture

```
HUMAN_AI_FRAMEWORK/
├── config/
│   ├── json/           # Authoritative JSON configurations
│   └── ports.json      # Port configuration for deployments
├── audit/
│   └── logs.json       # Audit trail of all operations
├── docs/
│   └── copilot-usage.md    # This document
├── verify_jsons.py     # JSON schema validation script
├── copilot.py          # Main automation orchestrator
└── .github/
    └── workflows/
        └── copilot-check.yml   # CI/CD pipeline configuration
```

## Responsibilities

### 1. **Initialization**
- Reads `SPACE_NAME` environment variable
- Locates configuration directory (`config/json/`)
- Sets up paths for audit logs and backups

### 2. **JSON Verification**
- Executes `verify_jsons.py` against all JSON files
- Validates against defined schemas
- Aborts on failure and sends notifications

### 3. **Port Configuration**
- Reads approved port from `config/ports.json`
- Validates port configuration
- Injects into deployment manifests (docker-compose.yml, Kubernetes)

### 4. **Backup Synchronization**
- Copies validated JSON files to backup storage
- Verifies integrity using SHA-256 checksums
- Supports local and cloud storage (S3, Azure Blob, etc.)

### 5. **Audit Logging**
- Appends timestamped entries to `audit/logs.json`
- Records: action, outcome, trigger source
- Maintains complete audit trail

### 6. **Governance Enforcement**
- Restricts writes to approved directories only
- Manual runs require "DevOps" group membership
- Escalates unauthorized access attempts

### 7. **Notifications**
- Success: "Configuration verified, backup completed, audit logged."
- Failure: Detailed diagnostics via webhook or stdout

### 8. **CI/CD Integration**
- Runs automatically on commits to `main`
- Triggers on Pull Requests
- Blocks merges on validation failures

### 9. **Documentation**
- Maintains up-to-date usage instructions
- Provides troubleshooting guides
- Documents all configuration changes

---

## Usage

### Automatic Execution (CI/CD)

The Copilot runs automatically on every commit to the `main` branch or when a Pull Request is opened that modifies configuration files.

**Triggers:**
- Push to `main` branch (paths: `config/**`, `verify_jsons.py`, `copilot.py`)
- Pull Request to `main` branch (same paths)
- Manual dispatch via GitHub Actions

**What happens:**
1. Checkout repository
2. Install Python dependencies
3. Run Copilot verification
4. Upload audit logs as artifacts
5. Upload backups as artifacts
6. Comment on PR with results
7. Block merge if verification fails

### Manual Execution

#### Local Development

```bash
# Set required environment variables
export SPACE_NAME="HUMAN_AI_FRAMEWORK"
export TRIGGER_SOURCE="manual"
export USER_GROUP="DevOps"
export BACKUP_PATH="/tmp/backups/HUMAN_AI_FRAMEWORK"

# Install dependencies
pip install -r requirements.txt

# Run Copilot
python copilot.py
```

#### GitHub Actions (Manual Dispatch)

1. Navigate to **Actions** tab in GitHub
2. Select **Copilot Configuration Check** workflow
3. Click **Run workflow**
4. Enter user group (must be "DevOps" for manual runs)
5. Click **Run workflow** button

**Requirements:**
- Must be a repository collaborator
- `USER_GROUP` must be set to "DevOps"
- Will fail if unauthorized

### Verification Only

To run only JSON verification without full Copilot workflow:

```bash
python verify_jsons.py
```

---

## Configuration Files

### `config/ports.json`

Defines the approved port configuration for deployments.

**Schema:**
```json
{
  "approved_port": 8080,           // Required: Port number (1024-65535)
  "protocol": "tcp",               // Required: "tcp" or "udp"
  "description": "Description",    // Optional: Human-readable description
  "service_name": "app",           // Optional: Service identifier
  "last_updated": "2025-10-17",   // Optional: Last update date
  "updated_by": "DevOps"          // Optional: Who made the update
}
```

**Example:**
```json
{
  "approved_port": 8080,
  "protocol": "tcp",
  "description": "Primary application port for HUMAN AI FRAMEWORK",
  "service_name": "app",
  "last_updated": "2025-10-17",
  "updated_by": "DevOps"
}
```

### `config/json/*.json`

All JSON configuration files in this directory will be validated.

**Common schemas:**
- Port configurations
- Service settings
- Feature flags
- Environment variables

### `audit/logs.json`

Audit trail of all Copilot operations.

**Structure:**
```json
{
  "metadata": {
    "created": "2025-10-17T00:00:00",
    "space_name": "HUMAN_AI_FRAMEWORK",
    "version": "1.0"
  },
  "audit_log": [
    {
      "timestamp": "2025-10-17T12:00:00",
      "action": "verify",
      "outcome": "success",
      "trigger_source": "CI pipeline",
      "details": "All JSON files validated"
    }
  ]
}
```

---

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SPACE_NAME` | No | `HUMAN_AI_FRAMEWORK` | Name of the space/project |
| `TRIGGER_SOURCE` | No | `manual` | Source of trigger (`manual`, `CI pipeline`) |
| `USER_GROUP` | No | `unknown` | User group for authorization |
| `BACKUP_PATH` | No | `/tmp/backups/HUMAN_AI_FRAMEWORK` | Backup storage location |
| `WEBHOOK_URL` | No | None | Webhook URL for notifications |
| `CONFIG_DIR` | No | `config/json` | Configuration directory path |

---

## Log Interpretation

### Success Output

```
🚀 Starting Copilot Assistant
============================================================
🤖 Copilot Assistant initialized for HUMAN_AI_FRAMEWORK
   Config directory: config/json
   Trigger source: CI pipeline

🔐 Step 6: Enforcing governance policies...
✅ Write operations restricted to: config, audit
✅ User group authorized: CI

🔍 Step 2: Running JSON verification...
✅ ports.json: Valid
✅ JSON verification passed

⚙️  Step 3: Configuring ports...
✅ Port configuration loaded: 8080/tcp

💾 Step 4: Backing up configuration files...
✅ Backed up: ports.json
✅ Backup completed to: /tmp/backups/HUMAN_AI_FRAMEWORK

📢 Notification (success):
✅ Configuration verified, backup completed, audit logged.

============================================================
✅ Copilot Assistant completed successfully
============================================================
```

### Failure Output

```
🚀 Starting Copilot Assistant
============================================================
🔍 Step 2: Running JSON verification...
❌ ports.json: Schema validation failed - 'approved_port' is a required property

❌ JSON verification failed

📢 Notification (failure):
❌ Copilot Failure:
[Detailed error message]
```

### Audit Log Entries

- **verify/success**: JSON validation passed
- **verify/failure**: JSON validation failed
- **backup/success**: Backup completed with checksums
- **backup/failure**: Backup operation failed
- **governance_check/failure**: Unauthorized access attempt

---

## Troubleshooting

### Issue: JSON Validation Fails

**Symptoms:**
- `❌ JSON verification failed`
- Schema validation errors in output

**Solutions:**
1. Check JSON syntax: `python -m json.tool config/json/yourfile.json`
2. Review error message for missing required fields
3. Validate against schema in `verify_jsons.py`
4. Ensure all required properties are present

### Issue: Unauthorized Manual Run

**Symptoms:**
- `❌ Unauthorized manual run attempt`
- Exit code 1

**Solutions:**
1. Set `USER_GROUP=DevOps` environment variable
2. Ensure you have DevOps group membership
3. Use CI/CD pipeline instead of manual execution

### Issue: Backup Checksum Mismatch

**Symptoms:**
- `❌ Checksum mismatch: filename.json`

**Solutions:**
1. Check disk space on backup location
2. Verify file permissions
3. Check for filesystem issues
4. Retry the operation

### Issue: Import Errors

**Symptoms:**
- `ModuleNotFoundError: No module named 'jsonschema'`

**Solutions:**
```bash
pip install -r requirements.txt
```

---

## Adding New Configuration Files

1. **Create JSON file** in `config/json/` directory
2. **Define schema** in `verify_jsons.py` if needed
3. **Test locally:**
   ```bash
   python verify_jsons.py
   ```
4. **Commit and push** - Copilot will run automatically
5. **Review audit logs** in `audit/logs.json`

---

## Security Considerations

1. **Access Control**: Manual runs require DevOps group membership
2. **Write Restrictions**: Only approved directories can be modified
3. **Audit Trail**: All operations are logged with timestamps
4. **Integrity Checks**: SHA-256 checksums verify backup integrity
5. **Webhook Secrets**: Store `WEBHOOK_URL` in GitHub Secrets

---

## CI/CD Pipeline Details

### Workflow File
`.github/workflows/copilot-check.yml`

### Artifacts Generated
- **audit-logs**: Retained for 90 days
- **config-backup**: Retained for 30 days

### Secrets Required
- `WEBHOOK_URL` (optional): For Slack/Teams notifications

### Status Checks
- Blocks PR merges on failure
- Comments on PRs with results
- Uploads logs and backups as artifacts

---

## Maintenance

### Regular Tasks

1. **Review audit logs** weekly
2. **Verify backups** monthly
3. **Update schemas** when adding new config types
4. **Rotate backup storage** per retention policy
5. **Update documentation** when responsibilities change

### Updating Copilot

When modifying Copilot functionality:

1. Update relevant scripts (`copilot.py`, `verify_jsons.py`)
2. Update this documentation
3. Test locally before committing
4. Update version in `audit/logs.json` metadata
5. Notify team of changes

---

## Contact & Support

**DevOps Team:**
- Review audit logs: `cat audit/logs.json | python -m json.tool`
- View workflow runs: GitHub Actions tab
- Manual intervention: Set `USER_GROUP=DevOps` and run locally

**Escalation:**
- Governance violations are logged and escalated automatically
- Security alerts trigger immediate notifications
- Failed verifications block deployments

---

## Version History

- **v1.0** (2025-10-17): Initial implementation
  - JSON verification
  - Port configuration
  - Backup synchronization
  - Audit logging
  - Governance enforcement
  - CI/CD integration
  - Documentation

---

## Appendix: Schema Definitions

### Port Configuration Schema

```python
{
    "type": "object",
    "properties": {
        "approved_port": {"type": "integer", "minimum": 1024, "maximum": 65535},
        "protocol": {"type": "string", "enum": ["tcp", "udp"]},
        "description": {"type": "string"}
    },
    "required": ["approved_port"]
}
```

To add custom schemas, modify `get_basic_schema()` in `verify_jsons.py`.

---

**Last Updated:** October 17, 2025  
**Maintained By:** DevOps Team  
**Space:** HUMAN_AI_FRAMEWORK
