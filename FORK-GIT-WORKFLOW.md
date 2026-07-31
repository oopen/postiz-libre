# Project Management — postiz-libre

> Survival guide for maintaining a clean fork, syncable with upstream, and productive.

---

## 🗺️ Branch Architecture (Current Situation)

```
upstream/main (gitroomhq/postiz-app)
        │
        │  ← regular sync
        ▼
    main (oopen/postiz-libre)  ← CLEAN, upstream mirror
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
| `just up` | Start everything (Docker infra + app servers) |
| `just stop` | Stop everything |
| `just app-logs` | Tail app server logs (backend + frontend) |
| `just restart` | Reboot everything |
| `just reset` | Destroy containers + volumes, then fresh start |
| `just purge` | TOTAL PURGE: containers + volumes + images |
| `just build` | Production build in Docker |
| `just build-purge` | Clean build volumes only |
| `just push [branch]` | Build + push branch to origin (default: dev) |
| `just ports` | Show Docker port map |

> **Note for AI assistants**: These commands are for the human maintainer.
> AI is FORBIDDEN from executing any git write operation (commit, push, merge).

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
#    compare : oopen/postiz-libre:feat/unlock-ai-vendor-lockin
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
| `FORK-ROADMAP.md` | `dev` | ❌ No |
| `FORK-GIT-WORKFLOW.md` | `dev` | ❌ No |
| `.github/workflows/release-libre.yml` | `dev` | ❌ No |
| `libraries/.../openai.service.ts` (patched) | `feat/unlock-ai-vendor-lockin` | ✅ Yes |
| `docker-compose.dev.yaml` | `feat/compose-improvements` | ✅ Yes |

---

## 🏷️ Release

Releases are cut from `dev`, never from `main`.

### Versioning

```
v{upstream major}.{upstream minor}.{upstream patch}-libre{-n}

v2.22.1-libre        ← first release (based on upstream v2.22.1)
v2.22.1-libre-1      ← second release (upstream unchanged)
v2.23.0-libre        ← after sync to upstream v2.23.0
```

Docker tags are published automatically by CI (semver):
`v2.22.1-libre` (exact), `v2.22-libre` (latest minor), `v2-libre` (latest major), `latest`.

### Release checklist

```bash
# 1. Find the upstream version our dev branch is based on
UPSTREAM_TAG=$(git tag --merged $(git merge-base dev upstream/main) --sort=-v:refname | grep -E '^v[0-9]' | head -1)

# 2. Tag
git tag -a ${UPSTREAM_TAG}-libre -m "Release ${UPSTREAM_TAG}-libre — description"

# 3. Push (CI builds and pushes Docker image automatically)
git push origin dev --tags
```

---

## 🐳 Docker image

```bash
# Pull the latest image
docker pull ghcr.io/oopen/postiz-libre:latest

# Pull a specific tag
docker pull ghcr.io/oopen/postiz-libre:dev
docker pull ghcr.io/oopen/postiz-libre:v0.1.0-libre

# Build locally
docker build -f Dockerfile.dev --target prod -t postiz-libre:local .
```

Images are built automatically on push to `dev` and on `v*-libre` tags.
Available at [github.com/oopen/postiz-libre/pkgs/container/postiz-libre](https://github.com/oopen/postiz-libre/pkgs/container/postiz-libre).

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

*Document for postiz-libre — July 2026*
