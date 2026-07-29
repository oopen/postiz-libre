# Project Management — postiz-app-libre

> Survival guide for maintaining a clean fork, syncable with upstream, and productive.

---

## 🗺️ Branch Architecture (Current Situation)

```
upstream/main (gitroomhq/postiz-app)
        │
        │  ← regular sync
        ▼
    main (oopen/postiz-app-libre)  ← CLEAN, upstream mirror
        │
        ├── feat/unlock-ai-vendor-lockin
        └── feat/compose-improvements
        │
        ▼
       dev  ← ← ← FORK INTEGRATION BRANCH (to create)
```

| Branch | Role | Golden Rule |
|--------|------|-------------|
| **`main`** | **Upstream mirror** | No fork-specific commits. Only sync + fast-forward. |
| **`dev`** | **Fork integration** | All fork features merged here. Reference branch for development. |
| **`feat/*`** | **Isolated feature** | One branch = one feature. Rebased on `main` before upstream PR. |

---

## 🚀 Initial Setup (One-Time)

### 1. Create `dev` from `main`

```bash
# Switch to main
git checkout main

# Create dev
git checkout -b dev

# Push to GitHub
git push -u origin dev
```

`dev` is now your working branch. It starts from clean `main`.

### 2. Merge your existing features into `dev`

```bash
git checkout dev

# Merge first feature
git merge feat/unlock-ai-vendor-lockin --no-ff

# Merge second feature
git merge feat/compose-improvements --no-ff

# Push
git push origin dev
```

`dev` now contains upstream + your 2 features.

### 3. Commit fork identity files into `dev`

```bash
git checkout dev

# Create the files:
# - README-FORK.md
# - docs/GOVERNANCE.md
# - CHANGELOG-LIBRE.md
# - .github/workflows/release-libre.yml

git add .
git commit -m "docs: add fork identity files (README-FORK, GOVERNANCE, CHANGELOG)"
git push origin dev
```

> **Rule**: These files live only in `dev`. They will never appear in upstream PRs because PRs originate from `feat/*` (rebased on `main`), not from `dev`.

---

## 🔄 Daily Workflow

### A. Sync `main` with upstream

```bash
# Add upstream remote (one-time)
git remote add upstream https://github.com/gitroomhq/postiz-app.git

# Fetch latest changes
git fetch upstream

# Switch to main
git checkout main

# Fast-forward merge (clean, no conflicts)
git merge upstream/main --ff-only

# Push
git push origin main
```

---

### B. Rebase `dev` on fresh `main`

```bash
git checkout dev
git pull origin dev

# Rebase on main (just synced)
git rebase main

# If conflict: resolve, then
git add <resolved-files>
git rebase --continue

# Push (force needed because rebase rewrites history)
git push --force-with-lease origin dev
```

---

### C. Rebase a feature on `main` for upstream PR

```bash
# Switch to feature
git checkout feat/unlock-ai-vendor-lockin

# Rebase on main (synced with upstream)
git rebase main

# Push
git push --force-with-lease origin feat/unlock-ai-vendor-lockin

# Open PR via GitHub:
#    base : gitroomhq/postiz-app:main
#    compare : oopen/postiz-app-libre:feat/unlock-ai-vendor-lockin
```

> **Important**: The upstream PR contains ONLY the feature commits. No README-FORK.md, no fork docs.

---

### D. Merge a completed feature into `dev`

```bash
git checkout dev
git merge feat/unlock-ai-vendor-lockin --no-ff
git push origin dev
```

---

## 📁 Where Files Live

| File | Branch | Appears in upstream PR? |
|------|--------|------------------------|
| `README-FORK.md` | `dev` | ❌ No |
| `docs/GOVERNANCE.md` | `dev` | ❌ No |
| `CHANGELOG-LIBRE.md` | `dev` | ❌ No |
| `.github/workflows/release-libre.yml` | `dev` | ❌ No |
| `libraries/.../openai.service.ts` (patched) | `feat/unlock-ai-vendor-lockin` | ✅ Yes |
| `docker-compose.custom.yaml` | `feat/compose-improvements` | ✅ Yes |

---

## 🏷️ Release

Releases are cut from `dev`, never from `main`.

```bash
git checkout dev
git pull origin dev

# See changes since last release
git log --oneline --no-merges $(git describe --tags --abbrev=0)..dev

# Tag
git tag -a v1.0.0-libre -m "Release v1.0.0-libre
- feat: unlock AI vendor lockin
- feat: compose improvements
- sync: upstream main @ $(git rev-parse --short upstream/main)"

# Build Docker from dev
docker build -t ghcr.io/oopen/postiz-libre:v1.0.0 .
docker tag ghcr.io/oopen/postiz-libre:v1.0.0 ghcr.io/oopen/postiz-libre:latest

# Push
git push origin dev --tags
docker push ghcr.io/oopen/postiz-libre:v1.0.0
docker push ghcr.io/oopen/postiz-libre:latest
```

---

## 🆘 Troubleshooting

### "Cannot fast-forward main onto upstream"

```bash
# You accidentally committed on main
# Save the commit
git checkout main
git log --oneline -3

# Create a temporary branch
git branch temp-save <commit-hash>

# Reset main to upstream
git reset --hard upstream/main
git push --force-with-lease origin main

# Move the commit to dev
git checkout dev
git cherry-pick <commit-hash>
git push origin dev
```

### "Feature rebase creates conflicts"

```bash
git status
# Edit conflicted files
git add <files>
git rebase --continue

# If too broken:
git rebase --abort
```

---

## 📋 Upstream PR Checklist

- [ ] `git fetch upstream` done
- [ ] `main` is up to date (`git merge upstream/main --ff-only`)
- [ ] Feature is rebased on `main`
- [ ] PR contains ONLY the feature commits
- [ ] Tests pass / Docker build OK

## 📋 Libre Release Checklist

- [ ] `main` synced with upstream
- [ ] `dev` rebased on `main`
- [ ] All features merged into `dev`
- [ ] Docker build OK
- [ ] Tag format `vX.Y.Z-libre`

---

*Document for postiz-app-libre — July 2026*
