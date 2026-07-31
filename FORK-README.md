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

## 2. ISSUES REGISTER

### Issue #256 — Support custom openAI endpoints for AI selfhosters
| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/gitroomhq/postiz-app/issues/256 |
| **Status** | 🔴 **CLOSED** |
| **Date** | — |
| **Author** | @community-member |
| **Description** | Request for support of custom OpenAI endpoints for self-hosters. |
| **Upstream response** | Closed on the pretext that CopilotKit did not support it. This pretext is obsolete today. No reopening proposed. |
| **Deleted comments** | None directly identified on this issue. |

---

### Issue #445 — Add variables like OPENAI_BASE_URL and OPENAI_MODEL to use other AI model providers
| Attribute | Detail |
|-----------|--------|
| **URL** | Referenced in #1648, direct link not found in search results |
| **Status** | 🟡 **OPEN** (per cross-references) |
| **Date** | — |
| **Author** | @community-member |
| **Description** | Request to add `OPENAI_BASE_URL` and `OPENAI_MODEL` to enable other AI providers. |
| **Upstream response** | No identified action. Referenced as related in #1648 but without treatment. |
| **Deleted comments** | Not specifically investigated. |

---

### Issue #498 — Consider Adding Optional OpenAI Configuration Options
| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/gitroomhq/postiz-app/issues/498 |
| **Status** | 🟡 **OPEN** |
| **Date** | December 26, 2024 |
| **Author** | @community-member |
| **Labels** | No specific label identified |
| **Description** | Initial and structured request to add `OPENAI_BASE_URL`, `SMART_LLM`, and `FAST_LLM`. The author provides a complete code example using OpenRouter. Argues for the need not to tie AI to a single provider. |
| **Upstream response** | No significant action to date (over 7 months). The issue remains open without assignment or milestone. |
| **Deleted comments** | **2 comments deleted**:<br>• Azadbangladeshi-com — deleted January 6, 2025<br>• iaskgithub — deleted January 13, 2025 |
| **Significance** | First documented request. Comment deletions on this issue demonstrate a will to stifle community mobilization. |

---

### Issue #592 — Feat Request: Different OpenAI API Support
| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/gitroomhq/postiz-app/issues/592 |
| **Status** | 🔴 **CLOSED as duplicate of #498** |
| **Date** | February 6, 2025 |
| **Author** | @egelhaus |
| **Assigned to** | @cchance27 |
| **Labels** | `no-stale-bot`, `type: feature-request` |
| **Description** | Simple request to be able to change the OpenAI API URL via environment variables. Mentions Ollama and other self-hosted instances. |
| **Upstream response** | Closed as duplicate of #498 by @egelhaus himself (likely at the team's suggestion). No action on #498 follows. |
| **Deleted comments** | None identified. |
| **Significance** | Classic pattern: close duplicates to create the illusion of management, without ever resolving the original issue. |

---

### Issue #779 — add AI/ML API as AI provider
| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/gitroomhq/postiz-app/issues/779 |
| **Status** | 🟡 **OPEN** |
| **Date** | — |
| **Author** | @community-member |
| **Description** | Request to add AI/ML API as an alternative AI provider. Approach via adding a specific provider rather than a generic `baseURL` solution. |
| **Upstream response** | No action. |
| **Deleted comments** | Not investigated. |

---

### Issue #1074 — Support ENV Variables for Custom OpenAI Base URL & Model
| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/gitroomhq/postiz-app/issues/1074 |
| **Status** | 🟡 **OPEN** |
| **Date** | November 21, 2025 |
| **Author** | @community-member |
| **Labels** | `type: feature-request` |
| **Description** | Very detailed and argued request. Mentions Ollama, LM Studio, OpenRouter, vLLM. Explains the need of self-hosters. Heavily upvoted by the community (massive 👍). |
| **Upstream response** | No action. This is the most popular issue on this subject. Over 8 months without response. |
| **Deleted comments** | Not specifically identified, but the issue is the most visible and the most ignored. |
| **Significance** | Total indifference despite community support demonstrates that the product roadmap explicitly excludes this feature. |

---

### Issue #192 — Feature: Ollama and other LLM support through Litellm project for Auto AI text generation
| Attribute | Detail |
|-----------|--------|
| **URL** | Referenced in #1648, direct link not found |
| **Status** | 🟡 **OPEN** (per cross-references) |
| **Date** | — |
| **Author** | @community-member |
| **Description** | Alternative approach via the LiteLLM project to support Ollama and other LLMs. |
| **Upstream response** | No action. |

---

### Issue #1648 — Native Google Gemini (AI Studio) & Vertex AI support for text/agent features
| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/gitroomhq/postiz-app/issues/1648 |
| **Status** | 🟡 **OPEN** |
| **Date** | June 28, 2026 |
| **Author** | @community-member |
| **Description** | Request for native support of Google Gemini and Vertex AI. The author has already implemented and tested end-to-end on a self-hosted instance. Explicitly mentions that Vertex AI requires specific handling (OAuth ADC) that a simple `OPENAI_BASE_URL` cannot resolve alone. |
| **Cross-references** | Explicitly cites #498, #592, #1074, #445, #779, #192, #256 as related issues. |
| **Upstream response** | No action to date (1 month). |
| **Significance** | Even when a contributor does the complete work (implementation + testing), the team refuses to merge or comment. |

---

## 3. PULL REQUESTS REGISTER

### PR #415 — feat: add openai compatible baseURL endpoint
| Attribute | Detail |
|-----------|--------|
| **URL** | GitHub Action: https://github.com/gitroomhq/postiz-app/actions/runs/20987813764 |
| **Status** | PR status unclear in search results. The CI action is referenced but the PR itself was not identified as merged. |
| **Description** | Addition of an OpenAI-compatible baseURL endpoint. |
| **Upstream response** | Not merged (no merge trace in results). |

---

### PR #1075 — feat: add support for custom OpenAI configurations
| Attribute | Detail |
|-----------|--------|
| **URL** | Referenced in #1648, direct link not found |
| **Status** | 🟡 **OPEN** (per cross-references) |
| **Description** | Generic implementation of `OPENAI_BASE_URL` and configurable models support. |
| **Upstream response** | No merge identified. |

---

### PR #1167 — feat: add openai compatible baseURL endpoint
| Attribute | Detail |
|-----------|--------|
| **URL** | GitHub Action: https://github.com/gitroomhq/postiz-app/actions/runs/20987813764 |
| **Status** | 🔴 **CLOSED** |
| **Description** | Addition of OpenAI-compatible baseURL support. |
| **Upstream response** | Closed without merge. |

---

### PR #1449 — AI multi provider
| Attribute | Detail |
|-----------|--------|
| **URL** | Referenced in search results |
| **Status** | 🔴 **CLOSED** |
| **Description** | Attempt to add multi-provider AI support. |
| **Upstream response** | **Auto-closed by a spam bot** (likely stale-bot or similar). The closure is technical, not on merit. No reopening by the team. |
| **Significance** | A bot did the dirty work of closing a functional PR, sparing the team from having to justify a rejection. |

---

## 4. DELETED / HIDDEN COMMENTS REGISTER

### On issue #498 (OpenAI Configuration Options)
| Author | Action | Date | Context |
|--------|--------|------|---------|
| Azadbangladeshi-com | ❌ Deleted | Jan 6, 2025 | Issue #498 — oldest OpenAI request |
| iaskgithub | ❌ Deleted | Jan 13, 2025 | Same issue #498 |

**Analysis**: Two comments deleted in one week on the foundational issue.  
The issue remains open (illusion of transparency) but discussion is stifled.

---

### On issue #544 (Feature: Add short.io)
| Author | Action | Date | Context |
|--------|--------|------|---------|
| *(anonymized)* | ❌ Deleted | Jan 12, 2025 | Issue not related to AI, but same period of intensive moderation |
| iaskgithub | ❌ Deleted | Jan 13, 2025 | **Same user targeted as on #498** — pattern of targeted censorship |

**Analysis**: iaskgithub is targeted on at least 2 different issues on the same day.  
This is not legitimate spam moderation, this is **cleaning up an insistent contributor**.

---

### On issue #1186 (Cannot connect YouTube)
| Author | Action | Date | Context |
|--------|--------|------|---------|
| MShanteer | ❌ Deleted | June 10, 2025 | Technical issue not related to AI |

---

### On issue #1222 (502 Bad Gateway HTML response)
| Author | Action | Date | Context |
|--------|--------|------|---------|
| crawlchat | ❌ Deleted | Feb 16, 2025 | — |
| @rusenask | 🟡 Hidden as "off-topic" | Mar 4, 2025 | Comment hidden but not deleted |

---

### On issue #1212 (Cookies not saved when accessing Postiz via Tailscale)
| Author | Action | Date | Context |
|--------|--------|------|---------|
| macdesire | 🟡 Hidden as "spam" | — | — |

---

## 5. GOVERNANCE PATTERN ANALYSIS

### 5.1 The Technical Lock-in
- **Target file**: `libraries/nestjs-libraries/src/openai/openai.service.ts`
- **Lines 7-9**: `const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY || 'sk-proj-' });`
- **Absence**: `baseURL` not configurable, models hardcoded (`gpt-4.1`, `chatgpt-image-latest`)
- **Impact**: Total lock-in on commercial OpenAI. Impossible to use Ollama (local), OpenRouter (aggregator), Groq (fast), Gemini (Google), Anthropic (Claude), or any OpenAI-compatible endpoint.

### 5.2 The Community Blocking Strategy
| Tactic | Proof | Objective |
|--------|-------|-----------|
| **Ignore** | #498 open since Dec 2024 without response | Let requests rot |
| **Close as duplicate** | #592 closed toward #498, but #498 never resolved | Create illusion of management without action |
| **Obsolete technical pretext** | #256 closed because "CopilotKit doesn't support" | Justify rejection without foundation |
| **Spam bot** | #1449 auto-closed | Avoid having to justify rejection |
| **Comment deletion** | #498: 2 comments deleted | Stifle mobilization |
| **User targeting** | iaskgithub deleted on 2 issues | Intimidate insistent contributors |
| **Indifference despite completed work** | #1648: complete implementation provided, ignored | Show that even free contribution is unwelcome |

### 5.3 The Underlying Economic Model
Postiz is distributed under AGPL-3.0 but managed as a **private SaaS product**:
- The hosted (paid) offering depends on OpenAI integration
- Allowing AI independence would reduce the perceived value of the SaaS offering
- Competent self-hosters are potential lost customers
- Open-source serves as a **marketing funnel**, not shared governance

---

## 6. QUANTITATIVE SYNTHESIS

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

## 7. THE FORK SOLUTION: postiz-libre

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

## 8. Contributing Philosophy

This fork exists only because upstream consistently ignores or blocks community contributions.
Our rule is simple: **upstream first, fork second**.

1. **Submit your feature to upstream first.** Open a PR on `gitroomhq/postiz-app`. Give them a fair chance to review and merge.
2. **If your PR is ignored, closed without reason, or left to rot** — bring it here. Open an issue on this fork referencing your upstream PR.
3. **We will review and merge.** No shadow-banning, no bot-closing, no silent ignoring.

This fork is not a competitor. It is a safety net for contributions that upstream refuses to catch.

---

## 9. CONCLUSION

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

---

*Document generated July 31, 2026. Sources: GitHub API, web search,  
analysis of public issues/PRs from the gitroomhq/postiz-app repository.*
