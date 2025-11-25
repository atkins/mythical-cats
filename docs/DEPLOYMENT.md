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
