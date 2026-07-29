# Governance — postiz-app-libre

> Why this fork exists: upstream governance failures documented through issues,
> pull requests, deleted comments, and systematic community blocking.

---

## 1. ISSUES REGISTER

### Issue #256 — Support custom openAI endpoints for AI selfhosters
| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/gitroomhq/postiz-app/issues/256 |
| **Status** | Closed |
| **Upstream response** | Closed on the pretext that CopilotKit did not support it. This pretext is obsolete today. No reopening proposed. |

### Issue #445 — Add variables like OPENAI_BASE_URL and OPENAI_MODEL to use other AI model providers
| Attribute | Detail |
|-----------|--------|
| **Status** | Open |
| **Upstream response** | No action. Referenced as related in #1648 but without treatment. |

### Issue #498 — Consider Adding Optional OpenAI Configuration Options
| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/gitroomhq/postiz-app/issues/498 |
| **Status** | Open |
| **Date** | December 26, 2024 |
| **Description** | Initial and structured request to add `OPENAI_BASE_URL`, `SMART_LLM`, and `FAST_LLM`. Provides a complete code example using OpenRouter. |
| **Upstream response** | No significant action to date (over 7 months). No assignment or milestone. |
| **Deleted comments** | 2 comments deleted: Azadbangladeshi-com (Jan 6, 2025), iaskgithub (Jan 13, 2025) |

### Issue #592 — Feat Request: Different OpenAI API Support
| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/gitroomhq/postiz-app/issues/592 |
| **Status** | Closed as duplicate of #498 |
| **Date** | February 6, 2025 |
| **Upstream response** | Closed toward #498, but #498 never resolved. Pattern: close duplicates to create the illusion of management. |

### Issue #779 — add AI/ML API as AI provider
| Attribute | Detail |
|-----------|--------|
| **Status** | Open |
| **Upstream response** | No action. |

### Issue #1074 — Support ENV Variables for Custom OpenAI Base URL & Model
| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/gitroomhq/postiz-app/issues/1074 |
| **Status** | Open |
| **Date** | November 21, 2025 |
| **Description** | Very detailed and argued request. Mentions Ollama, LM Studio, OpenRouter, vLLM. Heavily upvoted by the community (massive 👍). |
| **Upstream response** | No action. Over 8 months without response. Most popular issue on this subject. |

### Issue #192 — Feature: Ollama and other LLM support through Litellm project
| Attribute | Detail |
|-----------|--------|
| **Status** | Open |
| **Upstream response** | No action. |

### Issue #1648 — Native Google Gemini (AI Studio) & Vertex AI support
| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/gitroomhq/postiz-app/issues/1648 |
| **Status** | Open |
| **Date** | June 28, 2026 |
| **Description** | Contributor implemented end-to-end and tested on self-hosted instance. Explicitly mentions Vertex AI requires specific handling. |
| **Upstream response** | No action (1 month). Even when a contributor does the complete work, the team refuses to merge or comment. |

---

## 2. PULL REQUESTS REGISTER

### PR #415 — feat: add openai compatible baseURL endpoint
| Attribute | Detail |
|-----------|--------|
| **Status** | Not merged |

### PR #1075 — feat: add support for custom OpenAI configurations
| Attribute | Detail |
|-----------|--------|
| **Status** | Open |
| **Upstream response** | No merge identified. |

### PR #1167 — feat: add openai compatible baseURL endpoint
| Attribute | Detail |
|-----------|--------|
| **Status** | Closed without merge |

### PR #1449 — AI multi provider
| Attribute | Detail |
|-----------|--------|
| **Status** | Closed |
| **Upstream response** | Auto-closed by a spam bot. Closure is technical, not on merit. No reopening by the team. |

---

## 3. DELETED / HIDDEN COMMENTS

| Author | Issue | Action | Date |
|--------|-------|--------|------|
| Azadbangladeshi-com | #498 | Deleted | Jan 6, 2025 |
| iaskgithub | #498 | Deleted | Jan 13, 2025 |
| *(anonymized)* | #544 | Deleted | Jan 12, 2025 |
| iaskgithub | #544 | Deleted | Jan 13, 2025 |
| MShanteer | #1186 | Deleted | June 10, 2025 |
| crawlchat | #1222 | Deleted | Feb 16, 2025 |
| @rusenask | #1222 | Hidden as "off-topic" | Mar 4, 2025 |
| macdesire | #1212 | Hidden as "spam" | — |

**iaskgithub targeted on at least 2 different issues on the same day.** This is not legitimate spam moderation — it is cleaning up an insistent contributor.

---

## 4. GOVERNANCE PATTERN ANALYSIS

### 4.1 The Technical Lock-in
- **Target file**: `libraries/nestjs-libraries/src/openai/openai.service.ts`
- **Lines 7-9**: `const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY || 'sk-proj-' });`
- **Absence**: `baseURL` not configurable, models hardcoded (`gpt-4.1`, `chatgpt-image-latest`)
- **Impact**: Total lock-in on commercial OpenAI. Impossible to use Ollama (local), OpenRouter (aggregator), Groq (fast), Gemini (Google), Anthropic (Claude), or any OpenAI-compatible endpoint.

### 4.2 The Community Blocking Strategy
| Tactic | Proof | Objective |
|--------|-------|-----------|
| **Ignore** | #498 open since Dec 2024 without response | Let requests rot |
| **Close as duplicate** | #592 closed toward #498, but #498 never resolved | Create illusion of management without action |
| **Obsolete technical pretext** | #256 closed because "CopilotKit doesn't support" | Justify rejection without foundation |
| **Spam bot** | #1449 auto-closed | Avoid having to justify rejection |
| **Comment deletion** | #498: 2 comments deleted | Stifle mobilization |
| **User targeting** | iaskgithub deleted on 2 issues | Intimidate insistent contributors |
| **Indifference despite completed work** | #1648: complete implementation provided, ignored | Show that even free contribution is unwelcome |

### 4.3 The Underlying Economic Model
Postiz is distributed under MIT license but managed as a **private SaaS product**:
- The hosted (paid) offering depends on OpenAI integration
- Allowing AI independence would reduce the perceived value of the SaaS offering
- Competent self-hosters are potential lost customers
- Open-source serves as a **marketing funnel**, not shared governance

---

## 5. QUANTITATIVE SYNTHESIS

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

## 6. THE FORK SOLUTION

Repository: https://github.com/oopen/postiz-app-libre

Features are developed on isolated `feat/*` branches and merged into `dev` for integration.

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

## 7. REFERENCES

- Full audit: [`FORK-README.md`](./FORK-README.md)
- Git workflow: [`FORK-GIT-WORKFLOW.md`](./FORK-GIT-WORKFLOW.md)
