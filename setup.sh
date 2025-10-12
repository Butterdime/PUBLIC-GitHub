#!/usr/bin/env bash
set -e

# 1. Generate or overwrite deploy key
ssh-keygen -t ed25519 -C "deploy@yourserver" -f ~/.ssh/public-github-deploy -N ""

# 2. Show public key for GitHub
echo "Add this public key to GitHub Deploy Keys:"
cat ~/.ssh/public-github-deploy.pub

# 3. Configure SSH for this key
mkdir -p ~/.ssh
cat <<KEYCONF >> ~/.ssh/config
Host github.com-PUBLIC-GitHub
  HostName github.com
  User git
  IdentityFile ~/.ssh/public-github-deploy
KEYCONF
chmod 600 ~/.ssh/config

# 4. Create project files
cat <<EOL > requirements.txt
Flask
Flask-SQLAlchemy
python-dotenv
EOL

cat <<EOL > .env.example
DATABASE_URL=sqlite:///tasks.db
PORT=5000
FLASK_APP=app.py
FLASK_ENV=development
EOL

cat <<EOL > Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["flask", "run", "--host=0.0.0.0"]
EOL

# 5. Create CI workflow
mkdir -p .github/workflows
cat <<EOL > .github/workflows/ci.yml
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
          pip install Flask Flask-SQLAlchemy python-dotenv

      - name: Start Flask app
        run: |
          env FLASK_APP=app.py nohup python -m flask run --host=0.0.0.0 --port=5000 > flask.log 2>&1 &
          sleep 10

      - name: Health check
        run: |
          curl --retry 5 --retry-delay 2 --retry-connrefused --fail http://localhost:5000/health
EOL

chmod +x setup.sh
