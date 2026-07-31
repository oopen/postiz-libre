# Comprehensive Synthesis
## OpenAI Lock-in, Community Governance, and Selective Moderation
### Project Postiz (gitroomhq/postiz-app) — July 2026

> **Community Fork**: [postiz-libre](https://github.com/oopen/postiz-libre)  
> A liberation fork. Features merged into `dev` branch for downstream users.

---

## 1. CONTEXT

Postiz is an open-source multi-platform social media scheduling and publishing tool,  
developed by Gitroom (formerly GitroomHQ). The code is AGPL-3.0-licensed and available on GitHub.  
However, the upstream team manages the repository as a private SaaS product, passively  
blocking any evolution that would reduce dependency on OpenAI or facilitate independent  
self-hosting.

The core technical problem: the Node.js `openai` SDK is instantiated with `apiKey` only,  
without `baseURL`. Models (`gpt-4.1`, `chatgpt-image-latest`) are hardcoded. Result:  
it is impossible to use OpenRouter, Ollama, Groq, Gemini, Anthropic, or any OpenAI-compatible  
endpoint without modifying the source code on every update.

---

For the full issues, PRs, and deleted comments register, see [UPSTREAM-ISSUES.md](UPSTREAM-ISSUES.md).

---

## 2. GOVERNANCE PATTERN ANALYSIS

### 2.1 The Technical Lock-in
- **Target file**: `libraries/nestjs-libraries/src/openai/openai.service.ts`
- **Lines 7-9**: `const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY || 'sk-proj-' });`
- **Absence**: `baseURL` not configurable, models hardcoded (`gpt-4.1`, `chatgpt-image-latest`)
- **Impact**: Total lock-in on commercial OpenAI. Impossible to use Ollama (local), OpenRouter (aggregator), Groq (fast), Gemini (Google), Anthropic (Claude), or any OpenAI-compatible endpoint.

### 2.2 The Community Blocking Strategy
| Tactic | Proof | Objective |
|--------|-------|-----------|
| **Ignore** | #498 open since Dec 2024 without response | Let requests rot |
| **Close as duplicate** | #592 closed toward #498, but #498 never resolved | Create illusion of management without action |
| **Obsolete technical pretext** | #256 closed because "CopilotKit doesn't support" | Justify rejection without foundation |
| **Spam bot** | #1449 auto-closed | Avoid having to justify rejection |
| **Comment deletion** | #498: 2 comments deleted | Stifle mobilization |
| **User targeting** | iaskgithub deleted on 2 issues | Intimidate insistent contributors |
| **Indifference despite completed work** | #1648: complete implementation provided, ignored | Show that even free contribution is unwelcome |

### 2.3 The Underlying Economic Model
Postiz is distributed under AGPL-3.0 but managed as a **private SaaS product**:
- The hosted (paid) offering depends on OpenAI integration
- Allowing AI independence would reduce the perceived value of the SaaS offering
- Competent self-hosters are potential lost customers
- Open-source serves as a **marketing funnel**, not shared governance

---

## 3. QUANTITATIVE SYNTHESIS

| Category | Count | Resolved / Merged |
|----------|-------|-------------------|
| **Open issues** | 6 | **0** |
| **Closed issues** | 2 | **0** (closed without solution) |
| **Total issues** | 8 | **0** |
| **Open PRs** | 2 | **0** |
| **Closed PRs** | 2 | **0** (including 1 by spam bot) |
| **Total PRs** | 4 | **0** |
| **Deleted comments** | 6+ | — |
| **Hidden comments** | 2+ | — |
| **Total time without response** | **> 7 months** (since #498, Dec 2024) | — |

---

## 4. THE FORK SOLUTION: postiz-libre

Given the documented upstream obstruction, the community fork is the only viable path:

**Repository**: https://github.com/oopen/postiz-libre  
**Branches**: `feat/unlock-ai-vendor-lockin`, `feat/compose-improvements` → merged into `dev`

### What the fork fixes
- ✅ `OPENAI_BASE_URL` environment variable with fallback to `https://api.openai.com/v1`
- ✅ `OPENAI_MODEL` configurable via environment
- ✅ `OPENAI_IMAGE_BASE_URL`, `OPENAI_IMAGE_API_KEY`, `OPENAI_IMAGE_MODEL` — separate image generation endpoint
- ✅ `OPENAI_CLASSIFIER_BASE_URL`, `OPENAI_CLASSIFIER_API_KEY`, `OPENAI_CLASSIFIER_MODEL` — separate content classifier endpoint
- ✅ `OPENAI_MAX_TOKENS` — configurable token limit
- ✅ Support for OpenRouter, Ollama, Groq, Gemini, Anthropic, and any OpenAI-compatible endpoint
- ✅ Full backward compatibility when env vars are absent
- ✅ No new npm dependencies
- ✅ Preserved Zod response parsing

### Governance commitments
- No unilateral veto
- No features hidden behind a paywall
- Transparent review process (< 7 days)
- Systematic credit to contributors
- No comment deletion without public justification

---

## 5. Contributing Philosophy

This fork exists only because upstream consistently ignores or blocks community contributions.
Our rule is simple: **upstream first, fork second**.

1. **Submit your feature to upstream first.** Open a PR on `gitroomhq/postiz-app`. Give them a fair chance to review and merge.
2. **If your PR is ignored, closed without reason, or left to rot** — bring it here. Open an issue on this fork referencing your upstream PR.
3. **We will review and merge.** No shadow-banning, no bot-closing, no silent ignoring.

This fork is not a competitor. It is a safety net for contributions that upstream refuses to catch.

---

## 6. CONCLUSION

The gitroomhq/postiz-app repository practices **facade governance**:
- AGPL-3.0 license on paper
- Active technical lock-in on AI
- Systematic blocking of community contributions
- Selective moderation to suppress dissent
- Zero issues resolved, zero PRs merged on this critical subject

This pattern fully justifies the **local fork approach** (features developed independently on `feat/*`, merged into `dev`)  
rather than waiting for an upstream merge. The team has no intention of unlocking Postiz —  
it directly contradicts their SaaS business model.

The [postiz-libre](https://github.com/oopen/postiz-libre) fork exists to correct this  
structural failure and restore genuine open-source governance.
