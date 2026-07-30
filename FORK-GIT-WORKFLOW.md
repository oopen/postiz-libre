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
       dev  ← ← ← FORK INTEGRATION BRANCH (created)
```

| Branch | Role | Golden Rule |
|--------|------|-------------|
| **`main`** | **Upstream mirror** | No fork-specific commits. Only sync + fast-forward. |
| **`dev`** | **Fork integration** | All fork features merged here. Reference branch for development. |
| **`feat/*`** | **Isolated feature** | One branch = one feature. Rebased on `main` before upstream PR. |

---

## 🧰 Dev Commands (justfile)

All dev lifecycle and pushes go through `just`. Never `git push origin dev` directly.

| Command | Does |
|---------|------|
| `just up` | Start Docker infrastructure + app servers |
| `just stop` | Stop app servers + freeze Docker containers |
| `just app-start` | Start backend + frontend app servers |
| `just app-stop` | Stop all app servers (cross-terminal) |
| `just app-clean` | Stop servers + remove build artifacts |
| `just build` | Clean + production build all 3 apps |
| `just push` | Build + push `dev` to origin |
| `just push feat/xxx` | Build + push any branch |
| `just ports` | Show Docker port map |
| `just restart` | Reboot everything |
| `just reset` | Destroy containers + volumes |

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

# Push (use just push — it builds before pushing)
just push
```

---

### C. Rebase a feature on `main` for upstream PR

```bash
# Switch to feature
git checkout feat/unlock-ai-vendor-lockin

# Rebase on main (synced with upstream)
git rebase main

# Push
just push feat/unlock-ai-vendor-lockin

# Open PR via GitHub:
#    base : gitroomhq/postiz-app:main
#    compare : oopen/postiz-app-libre:feat/unlock-ai-vendor-lockin
```

> **Important**: The upstream PR contains ONLY the feature commits. No FORK-README.md, no fork docs.

---

### D. Merge a completed feature into `dev`

```bash
git checkout dev
git merge feat/unlock-ai-vendor-lockin --no-ff
just push
```

---

## 📁 Where Files Live

| File | Branch | Appears in upstream PR? |
|------|--------|------------------------|
| `FORK-README.md` | `dev` | ❌ No |
| `FORK-CHANGELOG.md` | `dev` | ❌ No |
| `FORK-GIT-WORKFLOW.md` | `dev` | ❌ No |
| `.github/workflows/release-libre.yml` | `dev` | ❌ No |
| `libraries/.../openai.service.ts` (patched) | `feat/unlock-ai-vendor-lockin` | ✅ Yes |
| `docker-compose.dev.yaml` | `feat/compose-improvements` | ✅ Yes |

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
just push
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
