# GitHub Pages Deployment System Design

**Date:** 2025-11-24
**Status:** Approved

## Overview

A GitHub Actions workflow that triggers on release creation, validates the code, builds the Flutter web app, and deploys to GitHub Pages using the official GitHub deployment action.

## Workflow

1. Developer creates a new GitHub release (e.g., v1.0.0) via GitHub UI or CLI
2. Workflow triggers automatically
3. Runs `flutter test` to validate all tests pass
4. Runs `flutter build web --base-href /mythical-cats/`
5. Uses GitHub's official `actions/upload-pages-artifact@v3` and `actions/deploy-pages@v4`
6. Deploys to https://atkins.github.io/mythical-cats/

## Key Benefits

- No third-party actions that can break
- Deployment tied to versioned releases
- Tests catch issues before they go live
- Official GitHub actions are well-maintained and secure

## Technical Implementation

### Workflow File Structure

Single file at `.github/workflows/deploy-pages.yml` with two jobs:

#### Job 1: Build & Test
- Checkout code
- Setup Flutter (stable channel)
- Run `flutter pub get`
- Run `flutter test` (fails workflow if tests fail)
- Run `flutter build web --base-href /mythical-cats/`
- Upload build artifacts using `actions/upload-pages-artifact@v3`

#### Job 2: Deploy
- Depends on Job 1 succeeding
- Uses `actions/deploy-pages@v4` to deploy the uploaded artifact
- Requires special permissions: `pages: write` and `id-token: write`

### GitHub Repository Settings Required

- Pages source must be set to "GitHub Actions" (not "Deploy from branch")
- This is a one-time configuration change in repo settings

### Why Two Jobs?

Separates build validation from deployment. If tests fail, deployment never runs. The official action pattern requires this separation for security and artifact handling.

## Error Handling & Validation

### Test Failures
- If `flutter test` fails, workflow stops immediately
- GitHub Actions marks the workflow as failed
- No deployment happens
- Test output visible in Actions tab for debugging

### Build Failures
- If `flutter build web` fails, workflow stops
- Common causes: analyzer errors, missing dependencies, code generation issues
- Failure is visible in Actions log with full output

### Deployment Failures
- Rare with official action, but possible (permissions, GitHub outages)
- Workflow will show which step failed
- Can re-run the workflow from GitHub UI without creating a new release

### Validation Checks
- Workflow only triggers on published releases (not drafts)
- Built-in retry logic in official deploy action

### Local Testing Before Release
```bash
flutter build web --base-href /mythical-cats/
# Test the build/web output locally
```

## Usage

### Creating a Release & Deploying

#### Option 1: GitHub UI
1. Go to repository → Releases → "Create a new release"
2. Click "Choose a tag" → type new tag (e.g., `v1.0.1`)
3. Add release title and notes
4. Click "Publish release"
5. Workflow triggers automatically, visible in Actions tab

#### Option 2: GitHub CLI
```bash
gh release create v1.0.1 --title "Release 1.0.1" --notes "Bug fixes and improvements"
```

### Monitoring Deployment
- Visit Actions tab to watch progress
- Typically takes 3-5 minutes (setup, test, build, deploy)
- Green checkmark = live at https://atkins.github.io/mythical-cats/

### Rollback Strategy
If a release has issues, create a new release from a previous commit:
```bash
git checkout v1.0.0  # previous good version
gh release create v1.0.0-hotfix --target v1.0.0
```

## Maintenance

- No ongoing maintenance required
- Official GitHub actions auto-update to latest compatible version
- Flutter version locked to stable channel (predictable)
