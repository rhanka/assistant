#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../api"
npx prisma generate
echo "Prisma client generated."
