---
name: create-release
description: Use when the user asks to create a new release, cut a release, bump the version, publish a version, or tag a release. Handles changelog generation, git tagging, and GitHub release creation.
allowed-tools: Bash(git:*), Bash(gh:*), Bash(npm:*), Bash(jq:*), Read, Grep, Glob, Edit, Write
user-invocable: true
---

# Create Release

Creates a new versioned release: updates CHANGELOG.md, creates a git tag, and publishes a GitHub release.

## When to Use

- User says "create a release", "cut a release", "new release"
- User says "bump the version", "publish a version"
- User says "tag a release", "release v1.2.3"

## Workflow

### Step 1: Detect Project Context

Determine the repo's GitHub remote and discover which `package.json` files contain a `version` field:

```bash
# Get GitHub owner/repo from remote
GITHUB_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "Repo: $GITHUB_REPO"

# Find all package.json files with a "version" field
find . -name "package.json" -not -path "*/node_modules/*" -exec grep -l '"version"' {} \;
```

### Step 2: Determine Version Bump

Analyze commits since the last release tag to determine the version increment.

```bash
# Find latest release tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
echo "Latest tag: $LATEST_TAG"

# List commits since last tag (or all commits if no tag)
if [ "$LATEST_TAG" = "none" ]; then
  git --no-pager log --oneline
else
  git --no-pager log --oneline "$LATEST_TAG"..HEAD
fi
```

**Version rules (Semantic Versioning):**

| Commit pattern | Bump | Example |
|---|---|---|
| Breaking changes, major rewrites, API incompatibilities | **major** | 1.0.0 → 2.0.0 |
| New features (`feat`), new capabilities | **minor** | 1.0.0 → 1.1.0 |
| Bug fixes (`fix`), chores, refactors, docs only | **patch** | 1.0.0 → 1.0.1 |

**Present your analysis to the user:** Show the commits, your recommended bump level, and the resulting version number. Ask the user to confirm before proceeding.

### Step 3: Categorize Changes

Group all commits since the last tag into Keep a Changelog categories:

| Category | Commit types |
|---|---|
| **Added** | `feat` commits, new capabilities |
| **Changed** | `refactor`, behavior modifications |
| **Fixed** | `fix` commits, bug corrections |
| **Removed** | Deleted features or deprecated code |
| **Security** | Security-related fixes |
| **Infrastructure** | `chore(infra)`, deployment, CI/CD changes |

**Rules:**
- Write entries in imperative mood ("Add X" not "Added X")
- Group related commits into single entries when they form one logical change
- Skip noise commits (merge commits, formatting-only, typo fixes) unless they are the only changes
- Use sub-headings (####) for feature areas when there are 5+ entries in a category

### Step 4: Update CHANGELOG.md

Read the current CHANGELOG.md (create one if it doesn't exist) and insert the new release section at the top, below the header.

**Format:**
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- Description of new feature

### Changed
- Description of change

### Fixed
- Description of fix
```

Also update the reference link at the bottom of the file:
```markdown
[X.Y.Z]: https://github.com/<GITHUB_REPO>/releases/tag/vX.Y.Z
```

### Step 5: Update package.json Versions

Update the `version` field in **all** `package.json` files discovered in Step 1 that should track the release version. Typically the root `package.json` and any app-level `package.json` files.

```bash
# For each relevant package.json:
npm version X.Y.Z --no-git-tag-version
# Or in subdirectories:
cd <app-dir> && npm version X.Y.Z --no-git-tag-version && cd -
```

### Step 6: Commit, Tag, and Push

```bash
# Stage the changelog and all bumped package.json files
git add CHANGELOG.md package.json <other-package-jsons>
git commit -m "chore(release): vX.Y.Z"

# Create annotated tag
git tag -a vX.Y.Z -m "Release vX.Y.Z"

# Push commit and tag
git push origin HEAD
git push origin vX.Y.Z
```

### Step 7: Create GitHub Release

Extract the changelog section for this version and use it as the release body.

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z" \
  --notes "$(cat <<'EOF'
<paste changelog section here>
EOF
)"
```

If there is a previous release, add `--latest` to mark this as the latest release.

### Step 8: Create Pull Request to Main

Create a PR from the current branch to the main/production branch so the release can be merged.

```bash
# Detect default branch
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)

gh pr create \
  --base "$DEFAULT_BRANCH" \
  --title "vX.Y.Z" \
  --body "$(cat <<'EOF'
## Release vX.Y.Z

<paste changelog section here>
EOF
)"
```

## Output

After completion, display:
1. The version number created
2. Link to the GitHub release
3. Link to the pull request
4. Summary of changes included

### Pending Migrations

Check if there are database migration files included in this release. Look for common migration directories:

```bash
git diff $LATEST_TAG..vX.Y.Z --name-only | grep -iE '(migrations?|migrate)/' || echo "No migrations found"
```

If any migrations are found, list them as a **TODO** reminder at the end of the output:

> **TODO: Apply database migrations before/after deploying vX.Y.Z**
> - `<migration_name>` — <brief description from folder/file name>
> - Run the project's migration deploy command on the target environment
