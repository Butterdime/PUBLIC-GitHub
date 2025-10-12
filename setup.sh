#!/usr/bin/env bash
set -e

# Check that GH_PAT is set in the environment
if [[ -z "${GH_PAT}" ]]; then
  echo "Error: GH_PAT environment variable is not set. Export GH_PAT before running this script." >&2
  exit 1
fi

echo "Using GH_PAT for HTTPS authentication..."

# 1. Copy and populate .env file with Perplexity API credentials
cp .env.example .env
read -p "Enter your Perplexity API key: " PERPLEXITY_API_KEY
read -p "Enter your Perplexity API secret: " PERPLEXITY_API_SECRET
# Replace placeholders with entered credentials (macOS sed uses a slightly different syntax)
sed -i "" "s|PERPLEXITY_API_KEY=|PERPLEXITY_API_KEY=${PERPLEXITY_API_KEY}|" .env
sed -i "" "s|PERPLEXITY_API_SECRET=|PERPLEXITY_API_SECRET=${PERPLEXITY_API_SECRET}|" .env

echo ".env populated with Perplexity credentials."

# 2. Create requirements.txt
cat > requirements.txt <<EOF
Flask
Flask-SQLAlchemy
python-dotenv
streamlit
EOF

# 3. Create Dockerfile
cat > Dockerfile <<EOF
# Dockerfile for building and running the Flask and Streamlit app
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
CMD ["python", "app.py"]
EOF

# 4. Create GitHub Actions CI workflow
mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<EOF
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    env:
      GH_PAT: \${{ secrets.GH_PAT }}
      PERPLEXITY_API_KEY: \${{ secrets.PERPLEXITY_API_KEY }}
      PERPLEXITY_API_SECRET: \${{ secrets.PERPLEXITY_API_SECRET }}
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python 3.11
        uses: actions/setup-python@v4
        with:
          python-version: 3.11
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run flask app in background
        run: FLASK_ENV=testing nohup python app.py &
      - name: Health check
        run: |
          for i in \$(seq 1 5); do
            if curl --silent --fail http://localhost:5000/health; then
              echo "Service is healthy"
              exit 0
            fi
            sleep 2
          done
          echo "Health check failed" >&2
          exit 1
      - name: Trigger Streamlit redeploy
        run: |
          git remote set-url origin "https://x-access-token:\${GH_PAT}@github.com/Butterdime/PUBLIC-GitHub.git"
          git add .
          git commit -m "CI: update scaffolding" || echo "No changes to commit"
          git push origin main
EOF

# 5. Commit and push changes via HTTPS using GH_PAT
git add requirements.txt Dockerfile .github/workflows/ci.yml .env
git commit -m "Bootstrap project: scaffold files and CI configured"

# Set HTTPS remote URL with PAT for authentication
git remote set-url origin "https://x-access-token:${GH_PAT}@github.com/Butterdime/PUBLIC-GitHub.git"

echo "Pushing changes to origin/main using GH_PAT..."

git push origin main

echo "Bootstrap complete. Changes pushed successfully."
