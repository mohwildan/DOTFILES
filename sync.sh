#!/usr/bin/env bash
# ==============================================================================
# 🚀 DOTFILES AUTO-SYNC ENGINE
# Automatically scans for secrets, pulls updates, commits, and pushes to Git.
# ==============================================================================

set -euo pipefail

DOTFILES_DIR="${HOME}/.dotfiles"
cd "${DOTFILES_DIR}"

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}==> Starting Dotfiles Sync...${NC}"

# Parse optional arguments
DRY_RUN=false
CHECK_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            echo -e "${YELLOW}[DRY-RUN MODE ENABLED - No changes will be committed or pushed]${NC}"
            ;;
        --check)
            CHECK_ONLY=true
            ;;
    esac
done

# ------------------------------------------------------------------------------
# 1. 🛡️ PRE-COMMIT SECRET & LEAK SCANNER
# ------------------------------------------------------------------------------
echo -e "${BLUE}==> [1/4] Scanning for accidental secrets and sensitive data...${NC}"

SECRET_PATTERNS=(
    "sk-[a-zA-Z0-9]{20,}"                        # OpenAI, DeepSeek, generic SK keys
    "ghp_[a-zA-Z0-9]{36}"                        # GitHub Personal Access Tokens
    "github_pat_[a-zA-Z0-9_]{80,}"               # GitHub Fine-grained PATs
    "sk-ant-[a-zA-Z0-9_\-]{20,}"                 # Anthropic keys
    "-----BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----" # Private keys
    "AKIA[0-9A-Z]{16}"                           # AWS Access Keys
)

LEAK_FOUND=false

# Check tracked and untracked files excluding .git and example templates
for pattern in "${SECRET_PATTERNS[@]}"; do
    # Search tracked files and unstaged changes, excluding examples, templates, and git internal files
    MATCHES=$(git grep -EI "$pattern" -- ':(exclude)*.example' ':(exclude)warp/settings.toml' 2>/dev/null || true)
    if [ -n "$MATCHES" ]; then
        echo -e "${RED}${BOLD}❌ SECURITY ALERT: Potential secret detected!${NC}"
        echo "$MATCHES"
        LEAK_FOUND=true
    fi
done

if [ "$LEAK_FOUND" = true ]; then
    echo -e "${RED}${BOLD}ABORTING SYNC: Please remove the secrets above and put them in ~/.zshrc.local instead!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Secret scan passed: No unencrypted credentials found.${NC}"

if [ "$CHECK_ONLY" = true ]; then
    exit 0
fi

# ------------------------------------------------------------------------------
# 2. 📥 PULL UPSTREAM CHANGES (IF REMOTE CONFIGURED)
# ------------------------------------------------------------------------------
echo -e "${BLUE}==> [2/4] Checking remote status...${NC}"

HAS_REMOTE=false
if git remote | grep -q "^origin$"; then
    HAS_REMOTE=true
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    echo -e "Fetching latest updates from origin/${CURRENT_BRANCH}..."
    if [ "$DRY_RUN" = false ]; then
        git pull --rebase origin "$CURRENT_BRANCH" 2>/dev/null || {
            echo -e "${YELLOW}Warning: Could not rebase from remote (may be offline or first push). Continuing...${NC}"
        }
    fi
else
    echo -e "${YELLOW}Notice: No remote 'origin' configured yet. Syncing locally.${NC}"
fi

# ------------------------------------------------------------------------------
# 3. 📝 STAGE AND COMMIT
# ------------------------------------------------------------------------------
echo -e "${BLUE}==> [3/4] Staging changes...${NC}"

# Check for modifications
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${GREEN}✓ Everything is up to date. No changes to commit.${NC}"
    exit 0
fi

git status --short

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Dry-run complete. Above changes would be staged and committed.${NC}"
    exit 0
fi

git add -A

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname -s)
COMMIT_MSG="chore(dotfiles): sync configs ${TIMESTAMP} from ${HOSTNAME}"

git commit -m "$COMMIT_MSG"
echo -e "${GREEN}✓ Committed: ${COMMIT_MSG}${NC}"

# ------------------------------------------------------------------------------
# 4. 📤 PUSH TO REMOTE
# ------------------------------------------------------------------------------
echo -e "${BLUE}==> [4/4] Pushing to Git...${NC}"

if [ "$HAS_REMOTE" = true ]; then
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    git push -u origin "$CURRENT_BRANCH"
    echo -e "${GREEN}${BOLD}✓ Successfully pushed dotfiles to origin/${CURRENT_BRANCH}!${NC}"
else
    echo -e "${YELLOW}Local commit saved. To push to GitHub, add a remote:${NC}"
    echo -e "  git -C ~/.dotfiles remote add origin git@github.com:mohwildan/dotfiles.git"
fi

echo -e "${GREEN}${BOLD}🎉 Dotfiles sync complete!${NC}"
