# How to Push to GitHub

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `k3s-rancher-harvester-deployment` (or your choice)
3. Description: `Fully automated Rancher management server deployment on Harvester HCI using K3s, MetalLB, and cloud-init. Built with Claude Code.`
4. Choose: **Public** (or Private)
5. **DO NOT** initialize with README (we already have one)
6. Click "Create repository"

## Step 2: Initialize and Push

```bash
# Navigate to the directory
cd /home/user/Documents/code/harvester/k3s_rancher_deployment

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Automated Rancher deployment on Harvester

- Complete K3s + Rancher + MetalLB deployment
- Cloud-init automation (11m 25s deployment time)
- Live migration support
- Comprehensive documentation
- Security guidelines with sanitized credentials
- Built with Claude Code by Anthropic"

# Add your GitHub repository as remote
# Replace YOUR_USERNAME with your GitHub username
git remote add origin https://github.com/YOUR_USERNAME/k3s-rancher-harvester-deployment.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Configure GitHub Repository

After pushing, go to your repository settings:

### Add Topics
Settings → Topics → Add:
```
harvester k3s rancher metallb kubernetes infrastructure-as-code
cloud-init automation claude-code anthropic hci virtualization
```

### Add Description
Should already be there, but verify:
```
Fully automated Rancher management server deployment on Harvester HCI
using K3s, MetalLB, and cloud-init. Built with Claude Code.
```

### Optional: Add Website
If you have documentation hosted elsewhere, add the URL

### Optional: Enable Discussions
Settings → General → Features → Discussions (check)

## Step 4: Verify

1. Check that all files are present
2. Verify README displays correctly
3. Ensure no credentials are visible
4. Test example file has placeholders only

## Alternative: Using SSH

If you prefer SSH (recommended for frequent pushes):

```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to GitHub: https://github.com/settings/keys

# Use SSH URL instead
git remote add origin git@github.com:YOUR_USERNAME/k3s-rancher-harvester-deployment.git
git push -u origin main
```

## Quick Copy-Paste Commands

```bash
cd /home/user/Documents/code/harvester/k3s_rancher_deployment
git init
git add .
git commit -m "Initial commit: Automated Rancher deployment on Harvester

- Complete K3s + Rancher + MetalLB deployment
- Cloud-init automation (11m 25s deployment time)
- Live migration support
- Comprehensive documentation
- Built with Claude Code by Anthropic"

# STOP HERE and create your GitHub repo first!
# Then replace YOUR_USERNAME and run:

git remote add origin https://github.com/YOUR_USERNAME/k3s-rancher-harvester-deployment.git
git branch -M main
git push -u origin main
```

## Troubleshooting

**Authentication Error:**
```bash
# Use personal access token instead of password
# Generate at: https://github.com/settings/tokens
```

**Repository exists:**
```bash
git remote remove origin
git remote add origin <new-url>
```

**Need to update:**
```bash
git add .
git commit -m "Update: description of changes"
git push
```
