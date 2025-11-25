# GitHub Pages Deployment Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement automated deployment to GitHub Pages triggered by GitHub releases using official GitHub Actions.

**Architecture:** Two-job workflow - first job runs tests and builds the Flutter web app, second job deploys the artifact to GitHub Pages using official actions. Requires repository Pages settings configured to use "GitHub Actions" as source.

**Tech Stack:** GitHub Actions, Flutter stable channel, official `actions/upload-pages-artifact@v3` and `actions/deploy-pages@v4`

---

## Task 1: Create GitHub Actions Workflow File

**Files:**
- Create: `.github/workflows/deploy-pages.yml`

**Step 1: Create .github/workflows directory**

Run:
```bash
mkdir -p .github/workflows
```

Expected: Directory created successfully

**Step 2: Create the workflow file**

Create `.github/workflows/deploy-pages.yml` with the following content:

```yaml
name: Deploy to GitHub Pages

on:
  release:
    types: [published]

permissions:
  contents: read
  pages: write
  id-token: write

# Allow only one concurrent deployment
concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Build web app
        run: flutter build web --base-href /mythical-cats/

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: 'build/web'

  deploy:
    needs: build
    runs-on: ubuntu-latest

    permissions:
      pages: write
      id-token: write

    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

**Step 3: Verify file syntax**

Run:
```bash
cat .github/workflows/deploy-pages.yml
```

Expected: File contents display correctly, no YAML syntax errors visible

**Step 4: Commit the workflow file**

Run:
```bash
git add .github/workflows/deploy-pages.yml
git commit -m "feat: add GitHub Pages deployment workflow

Automated deployment triggered by GitHub releases:
- Runs tests before building
- Builds Flutter web with correct base-href
- Deploys using official GitHub Pages actions

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

Expected: Commit created successfully

---

## Task 2: Update Documentation

**Files:**
- Modify: `CLAUDE.md` (add deployment instructions)
- Modify: `README.md` (add deployment section if needed)

**Step 1: Read current CLAUDE.md to find appropriate section**

Run:
```bash
grep -n "## Development Commands" CLAUDE.md
```

Expected: Line number of Development Commands section

**Step 2: Add deployment section to CLAUDE.md**

Add the following section after the "Building" subsection in the "Development Commands" section:

```markdown
### Deployment to GitHub Pages
```bash
# Deployment is automated via GitHub Actions on release creation

# Option 1: Create release via GitHub UI
# 1. Go to repository → Releases → "Create a new release"
# 2. Click "Choose a tag" → type new tag (e.g., v1.0.1)
# 3. Add release title and notes
# 4. Click "Publish release"
# 5. Workflow triggers automatically

# Option 2: Create release via GitHub CLI
gh release create v1.0.1 --title "Release 1.0.1" --notes "Description of changes"

# Monitor deployment progress
# Visit repository Actions tab - typically takes 3-5 minutes

# Repository Settings (one-time setup)
# Settings → Pages → Source: "GitHub Actions"
```

**Deployment Workflow:**
- Triggers: On published release (not drafts)
- Validation: Runs all tests - deployment fails if tests fail
- Build: `flutter build web --base-href /mythical-cats/`
- Deploy: Uses official GitHub Pages actions
- Live URL: https://atkins.github.io/mythical-cats/

**Troubleshooting:**
- If deployment fails, check Actions tab for error details
- Tests must pass before deployment proceeds
- Ensure repository Pages source is set to "GitHub Actions"
```

**Step 3: Verify CLAUDE.md syntax**

Run:
```bash
grep -A 5 "### Deployment to GitHub Pages" CLAUDE.md
```

Expected: New section displays correctly

**Step 4: Commit documentation update**

Run:
```bash
git add CLAUDE.md
git commit -m "docs: add GitHub Pages deployment instructions

Documents automated deployment workflow:
- How to create releases (UI and CLI)
- Workflow behavior and validation
- Troubleshooting tips

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

Expected: Commit created successfully

---

## Task 3: Repository Configuration Instructions

**Files:**
- Create: `docs/DEPLOYMENT.md` (deployment guide)

**Step 1: Create deployment guide**

Create `docs/DEPLOYMENT.md`:

```markdown
# Deployment Guide

## GitHub Pages Configuration

### One-Time Setup

1. **Configure Pages Source**
   - Go to repository Settings → Pages
   - Under "Source", select "GitHub Actions"
   - Save the setting

2. **Verify Workflow Permissions**
   - Go to repository Settings → Actions → General
   - Under "Workflow permissions", ensure "Read and write permissions" is selected
   - Ensure "Allow GitHub Actions to create and approve pull requests" is checked

### Creating a Release

#### Via GitHub UI

1. Navigate to your repository on GitHub
2. Click "Releases" in the right sidebar
3. Click "Create a new release"
4. Click "Choose a tag"
5. Type a new tag name (e.g., `v1.0.1`)
6. Click "Create new tag"
7. Add a release title (e.g., "Release 1.0.1")
8. Add release notes describing the changes
9. Click "Publish release"

#### Via GitHub CLI

```bash
# Create and publish a release
gh release create v1.0.1 --title "Release 1.0.1" --notes "Bug fixes and improvements"

# Create from a specific commit
gh release create v1.0.1 --title "Release 1.0.1" --target abc123 --notes "Hotfix"
```

### Monitoring Deployment

1. After publishing a release, go to the "Actions" tab
2. You should see a workflow run named "Deploy to GitHub Pages"
3. Click on the run to see detailed progress
4. Typical deployment time: 3-5 minutes

**Workflow Steps:**
1. Checkout code
2. Setup Flutter
3. Install dependencies
4. **Run tests** (deployment stops if tests fail)
5. Build web app
6. Upload artifact
7. Deploy to Pages

### Verifying Deployment

After the workflow completes successfully:

1. Visit https://atkins.github.io/mythical-cats/
2. Verify the new features/fixes are live
3. Check browser console for any errors

### Troubleshooting

#### Tests Fail

If tests fail, the workflow stops before building:
- Check the test output in the Actions log
- Fix the failing tests locally
- Create a new release after fixing

#### Build Fails

If `flutter build web` fails:
- Check for analyzer errors: `flutter analyze`
- Verify all dependencies are correct
- Check the full build log in Actions

#### Deployment Fails

If upload/deploy steps fail:
- Verify Pages source is set to "GitHub Actions"
- Check workflow permissions in repository settings
- Ensure you have admin access to the repository

#### Site Shows 404 or Blank Page

- Verify `base-href` is correct: `/mythical-cats/`
- Check browser console for asset loading errors
- Verify all assets are included in build output

### Rollback

To rollback to a previous version:

```bash
# Find the previous good release
gh release list

# Create a new release from that tag
git checkout v1.0.0  # previous version
gh release create v1.0.0-hotfix --target v1.0.0 --notes "Rollback to v1.0.0"
```

### Local Testing Before Release

Before creating a release, test the build locally:

```bash
# Build with production settings
flutter build web --base-href /mythical-cats/

# Serve locally (requires a static file server)
cd build/web
python3 -m http.server 8000

# Visit http://localhost:8000/mythical-cats/
```

## Best Practices

1. **Always test locally** before creating a release
2. **Run full test suite** before release: `flutter test`
3. **Use semantic versioning** for tags: v1.0.0, v1.0.1, v1.1.0
4. **Write clear release notes** describing what changed
5. **Monitor the deployment** in Actions tab after publishing
6. **Test the live site** after deployment completes

## Automation Details

The workflow is defined in `.github/workflows/deploy-pages.yml`:
- **Trigger:** Published releases only (not drafts)
- **Concurrency:** Only one deployment at a time
- **Permissions:** Minimal required (contents:read, pages:write, id-token:write)
- **Two jobs:** build (test + build) → deploy (publish to Pages)
```

**Step 2: Commit deployment guide**

Run:
```bash
git add docs/DEPLOYMENT.md
git commit -m "docs: add comprehensive deployment guide

Includes:
- One-time GitHub Pages setup instructions
- Release creation (UI and CLI)
- Deployment monitoring
- Troubleshooting common issues
- Rollback procedures
- Best practices

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

Expected: Commit created successfully

---

## Task 4: Verification and Final Checks

**Step 1: Verify all files are committed**

Run:
```bash
git status
```

Expected: "working tree clean" or only untracked files

**Step 2: Review commit history**

Run:
```bash
git log --oneline -3
```

Expected: Shows 3 commits (workflow, CLAUDE.md, DEPLOYMENT.md)

**Step 3: Verify workflow file syntax**

Run:
```bash
# Check YAML syntax
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/deploy-pages.yml'))" && echo "YAML syntax valid" || echo "YAML syntax error"
```

Expected: "YAML syntax valid"

**Step 4: Push to remote branch**

Run:
```bash
git push -u origin feature/github-pages-deployment
```

Expected: Branch pushed successfully

**Step 5: Document next steps**

The implementation is complete. Next steps for the user:

1. **Create Pull Request** to merge this feature branch into main
2. **After merging:** Configure repository Pages settings
   - Go to repository Settings → Pages
   - Set Source to "GitHub Actions"
3. **Create first release** to test the deployment:
   ```bash
   gh release create v1.0.0 --title "Initial Release" --notes "First automated deployment"
   ```
4. **Monitor deployment** in Actions tab
5. **Verify live site** at https://atkins.github.io/mythical-cats/

---

## Post-Implementation Notes

**Files Created:**
- `.github/workflows/deploy-pages.yml` - GitHub Actions workflow
- `docs/DEPLOYMENT.md` - Comprehensive deployment guide

**Files Modified:**
- `CLAUDE.md` - Added deployment commands section

**Testing Strategy:**
- Workflow syntax validated
- Cannot test actual deployment until:
  1. Branch is merged to main
  2. Repository Pages source is configured
  3. A release is created

**Manual Steps Required:**
1. Merge PR to main branch
2. Configure repository Settings → Pages → Source: "GitHub Actions"
3. Create a release to trigger first deployment

**Verification Checklist:**
- [ ] Workflow file has correct YAML syntax
- [ ] All file paths are correct
- [ ] Documentation is clear and complete
- [ ] Commits have descriptive messages
- [ ] Branch is pushed to remote
