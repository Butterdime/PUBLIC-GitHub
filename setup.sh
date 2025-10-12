#!/usr/bin/env bash
set -e

# 1. requirements.txt
cat <<EOF > requirements.txt
Flask
Flask-SQLAlchemy
python-dotenv
Flask-Migrate
EOF

# 2. .env.example
cat <<EOF > .env.example
DATABASE_URL=sqlite:///tasks.db
PORT=5000
FLASK_APP=app.py
FLASK_ENV=development
EOF

# 3. Dockerfile
cat <<EOF > Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["flask", "run", "--host=0.0.0.0"]
EOF

# 4. GitHub Actions workflow
mkdir -p .github/workflows
cat <<EOF > .github/workflows/ci.yml
name: CI
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
jobs:
  test:
    runs-on: ubuntu-latest
    env:
      FLASK_APP: app.py
      FLASK_ENV: testing
      DATABASE_URL: sqlite:///test_tasks.db
      PORT: 5000
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: Initialize migrations
        run: |
          flask db init || echo "Already initialized"
          flask db migrate --message "CI" || echo "No changes"
          flask db upgrade
      - name: Run health check
        run: |
          nohup flask run --host=0.0.0.0 --port=5000 &
          sleep 5
          curl --fail http://localhost:5000/health
EOF

# 5. Make the script executable locally after cloning
