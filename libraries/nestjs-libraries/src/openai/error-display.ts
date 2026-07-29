interface ErrorData {
  error?: {
    message?: string;
    type?: string;
    code?: string | number;
    metadata?: Record<string, any>;
  };
}

interface MappedError {
  code: string;
  title: string;
  message: string;
  action: string | null;
  url: string | null;
  retryable: boolean;
}

function extractTokens(rawMsg: string, regex: RegExp): string | null {
  const m = rawMsg.match(regex);
  return m?.[1] || null;
}

function extractUrl(rawMsg: string): string | null {
  const m = rawMsg.match(/https:\/\/[^\s)]+/);
  return m?.[0] || null;
}

export function mapApiError(err: any): MappedError {
  const statusCode: number =
    err?.statusCode || err?.status || err?.code || 0;
  const rawMsg: string =
    err?.message ||
    err?.responseBody ||
    String(err || '');
  const data: ErrorData = (err?.data as ErrorData) || {};
  const detailCode: string = String(data?.error?.code || '');
  const isRetryable: boolean = err?.isRetryable ?? false;

  // 402 quota / credits
  if (statusCode === 402 || detailCode === 'insufficient_quota') {
    const requested = extractTokens(rawMsg, /requested (?:up to |about )?(\d+) tokens/) || 'unknown';
    const afforded = extractTokens(rawMsg, /only afford (\d+)/) || '0';
    return {
      code: 'quota',
      title: 'Quota Exceeded (402)',
      message: `API quota exceeded. You requested ${requested} tokens, you have ${afforded} remaining.`,
      action: 'Provider Settings',
      url: extractUrl(rawMsg),
      retryable: false,
    };
  }

  // 429 rate limit
  if (statusCode === 429 || /rate.limit/i.test(rawMsg)) {
    return {
      code: 'rate_limit',
      title: 'Rate Limit (429)',
      message: rawMsg.includes('retry')
        ? 'Service temporarily overloaded. Retrying automatically...'
        : rawMsg.substring(0, 200),
      action: 'Retry',
      url: null,
      retryable: true,
    };
  }

  // 400 context length
  if (statusCode === 400 && /context length|too many tokens|maximum context/i.test(rawMsg)) {
    const maxCtx = extractTokens(rawMsg, /maximum context length is (\d+) tokens/);
    const limit = maxCtx ? `${Math.round(parseInt(maxCtx) / 1024)}k` : 'the';
    return {
      code: 'context_length',
      title: 'Context Too Long (400)',
      message: `The conversation exceeded ${limit} token limit. Start a new conversation.`,
      action: 'New Conversation',
      url: null,
      retryable: false,
    };
  }

  // 400 guardrails / privacy
  if (
    statusCode === 400 &&
    /guardrail|endpoints? available|data policy/i.test(rawMsg)
  ) {
    return {
      code: 'guardrail',
      title: 'Model Blocked by Restrictions',
      message: 'Your provider privacy settings block this model. Adjust them in your account settings.',
      action: 'Provider Settings',
      url: extractUrl(rawMsg),
      retryable: false,
    };
  }

  // 400 schema / invalid tool
  if (statusCode === 400 && /schema|invalid.*tool|message.*json/i.test(rawMsg)) {
    return {
      code: 'schema',
      title: 'Unsupported Request Format',
      message: 'The target model does not support this request format (JSON schema, function calling, etc.).',
      action: null,
      url: null,
      retryable: false,
    };
  }

  // 400 generic
  if (statusCode === 400) {
    return {
      code: 'bad_request',
      title: 'Invalid Request (400)',
      message: rawMsg.substring(0, 200),
      action: null,
      url: null,
      retryable: false,
    };
  }

  // 401 / 403 auth
  if (statusCode === 401 || statusCode === 403) {
    return {
      code: 'auth',
      title: 'Authentication Error',
      message: 'Your API key is invalid or expired. Check your provider settings.',
      action: 'Provider Settings',
      url: extractUrl(rawMsg),
      retryable: false,
    };
  }

  // 500+ server
  if (statusCode >= 500) {
    return {
      code: 'server',
      title: 'AI Service Unavailable (500)',
      message: 'The provider is experiencing internal errors. Retry in a few moments.',
      action: 'Retry',
      url: null,
      retryable: true,
    };
  }

  // ECONNREFUSED / fetch failed
  if (/ECONNREFUSED|fetch failed/i.test(rawMsg)) {
    return {
      code: 'connection',
      title: 'Service Unreachable',
      message: 'Cannot connect to the AI provider. Check that the service is running.',
      action: 'Retry',
      url: null,
      retryable: true,
    };
  }

  // Unknown with status
  if (statusCode && statusCode >= 400) {
    return {
      code: `http_${statusCode}`,
      title: `Error ${statusCode}`,
      message: rawMsg.substring(0, 200),
      action: 'Retry',
      url: null,
      retryable: isRetryable,
    };
  }

  // Completely unknown
  return {
    code: 'unknown',
    title: 'Unexpected Error',
    message: rawMsg?.substring(0, 200) || 'An unexpected AI error occurred.',
    action: 'Retry',
    url: null,
    retryable: true,
  };
}

export function toUserMessage(err: any): string {
  const mapped = mapApiError(err);
  return `${mapped.title}\n${mapped.message}`;
}
