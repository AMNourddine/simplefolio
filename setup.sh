#!/bin/bash
# Setup script to install Node.js dependencies from requirements.txt
set -euo pipefail

if ! command -v npm >/dev/null 2>&1; then
  echo "Error: npm is not installed." >&2
  exit 1
fi

if [ ! -f requirements.txt ]; then
  echo "requirements.txt not found." >&2
  exit 1
fi

regular_packages=()
dev_packages=()
section="regular"

while IFS= read -r line; do
  # Strip carriage returns (for Windows users) and trim whitespace
  line="$(echo "$line" | tr -d '\r' | sed 's/^\s*//;s/\s*$//')"
  # Skip empty lines
  [ -z "$line" ] && continue
  # Detect start of dev section
  if [[ "$line" =~ ^# ]]; then
    if [[ "$line" == "# Development dependencies"* ]]; then
      section="dev"
    fi
    continue
  fi
  if [ "$section" = "regular" ]; then
    regular_packages+=("$line")
  else
    dev_packages+=("$line")
  fi
done < requirements.txt

if [ ${#regular_packages[@]} -gt 0 ]; then
  echo "Installing regular dependencies: ${regular_packages[*]}"
  npm install "${regular_packages[@]}"
fi

if [ ${#dev_packages[@]} -gt 0 ]; then
  echo "Installing dev dependencies: ${dev_packages[*]}"
  npm install -D "${dev_packages[@]}"
fi

# Update browserslist database to avoid version warnings
npx update-browserslist-db@latest

echo "Setup completed."
