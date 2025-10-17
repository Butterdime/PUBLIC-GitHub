
# Copilot AI Agent Instructions for HUMAN AI FRAMEWORK

## Project Architecture & Key Components
- `app.py`: Flask web application entrypoint.
- `copilot.py`: Main Copilot orchestrator for config validation, backup, audit, and notifications.
- `verify_jsons.py`: Validates all JSON configs in `config/json/` against schemas.
- `config/ports.json`: Source of approved port for deployment manifests.
- `audit/logs.json`: Append-only audit log for all Copilot actions.
- `docker-compose.yml` & `k8s/deployment.yaml`: Deployment manifests, update ports as needed.

## Developer Workflows
- **Full Copilot Run:**
	```bash
	export SPACE_NAME="HUMAN_AI_FRAMEWORK"
	export USER_GROUP=DevOps
	python copilot.py
	```
- **JSON Verification Only:**
	```bash
	python verify_jsons.py
	```
- **CI/CD:**
	- Copilot runs on push/PR to `main` via GitHub Actions (`.github/workflows/copilot-check.yml`).
	- Blocks merges on failure, posts results to PRs and webhook.

## Conventions & Patterns
- All config changes must be validated by `verify_jsons.py` before backup or deployment.
- Only changed JSON files are synced to S3 (`s3://my-backups/${SPACE_NAME}/`).
- Audit log entries are appended as JSON objects with timestamp, action, and outcome.
- Manual Copilot runs require `USER_GROUP=DevOps` for write operations.
- Ports are injected from `config/ports.json` into deployment manifests using in-place updates.

## Integration Points
- **AWS S3:** For backup of validated JSON configs.
- **Webhook:** For notifications on success/failure (`WEBHOOK_URL` env var).
- **Docker/K8s:** Deployment manifests updated with approved port.

## Example: Audit Log Entry
```json
{
	"timestamp": "2025-10-17T12:00:00",
	"action": "copilot_run",
	"outcome": "success",
	"source": "run_copilot_tasks.sh"
}
```

## Essential Commands
- Make Copilot script executable:
	```bash
	chmod +x run_copilot_tasks.sh
	```
- Run Copilot tasks:
	```bash
	./run_copilot_tasks.sh
	```
- View audit logs:
	```bash
	cat audit/logs.json | python -m json.tool
	```

## Dependencies
- Python 3, AWS CLI, jq
- Python packages: Flask, Flask-SQLAlchemy, python-dotenv, jsonschema, requests

## Documentation
- See `docs/copilot-usage.md` for troubleshooting, architecture, and workflow details.

---
**Last Updated:** October 17, 2025
