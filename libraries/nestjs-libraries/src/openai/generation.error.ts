import { HttpException } from '@nestjs/common';
import { mapApiError } from './error-display';

// e.g. "400 Your request was rejected by the safety system, safety_violations=[sexual]"
const SAFETY_VIOLATIONS_REGEX = /safety_violations=\[([^\]]*)\]/i;

// Match genuine content-safety rejections by message, NOT by a bare 400 status:
// a 400 can just as easily be an invalid-parameter error, which must not be
// reported to the user as a safety violation.
const SAFETY_MESSAGE_REGEX =
  /safety system|safety_violations|content[ _]policy|rejected as a result of our safety|moderation/i;

/**
 * Normalizes errors thrown by AI generation providers (OpenAI image/chat,
 * LangChain DALL-E, Fal, Veo3, HeyGen, ElevenLabs, ...) into a clean
 * HttpException so a provider rejection (most notably an OpenAI safety
 * violation) returns a proper response instead of crashing the backend.
 *
 * When the provider reports a content-safety rejection, the flagged
 * category/categories are surfaced back to the user.
 */
export function generationError(err: any): HttpException {
  // Preserve errors we already raised intentionally (e.g. SubscriptionException).
  if (err instanceof HttpException) {
    return err;
  }

  const message: string =
    err?.error?.message || err?.message || String(err || '');

  // Check safety violations first (before generic LLM error mapping).
  if (SAFETY_MESSAGE_REGEX.test(message)) {
    const categories = message.match(SAFETY_VIOLATIONS_REGEX)?.[1]?.trim();
    const detail = categories ? ` Flagged categories: ${categories}.` : '';
    return new HttpException(
      `Your request was rejected by the AI safety system.${detail} Please adjust your prompt and try again.`,
      422
    );
  }

  // Map other errors (rate-limit, quota, context, schema, etc.) using
  // the centralized error-display utility.
  const mapped = mapApiError(err);
  const statusMap: Record<string, number> = {
    rate_limit: 429, quota: 402, context_length: 400, guardrail: 400,
    schema: 400, bad_request: 400, auth: 401, server: 500, connection: 503,
  };
  return new HttpException(mapped.message, statusMap[mapped.code] || 500);
}
