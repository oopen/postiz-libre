import { HttpException } from '@nestjs/common';
import OpenAI from 'openai';
import { ChatOpenAI, DallEAPIWrapper } from '@langchain/openai';
import { APICallError } from '@ai-sdk/provider';
import { mapApiError } from './error-display';

const MAX_RETRIES = 3;
const BASE_DELAY_MS = 2000;

function isRetryableApiError(err: unknown): boolean {
  if (!APICallError.isInstance(err)) return false;
  return err.isRetryable === true || err.statusCode === 429;
}

export async function withRetry<T>(
  fn: () => Promise<T>,
  retries: number = MAX_RETRIES
): Promise<T> {
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      return await fn();
    } catch (err: any) {
      if (attempt < retries && isRetryableApiError(err)) {
        const delay = BASE_DELAY_MS * Math.pow(2, attempt);
        console.warn(
          `[openai-retry] retry ${attempt + 1}/${retries} in ${delay}ms — status: ${(err as any)?.statusCode || err.message?.substring(0, 60)}`
        );
        await new Promise((resolve) => setTimeout(resolve, delay));
        continue;
      }
      if (APICallError.isInstance(err) && err.statusCode === 402) {
        throw new HttpException(mapApiError(err).message, 402);
      }
      throw err;
    }
  }
  throw new HttpException(
    'AI request failed after multiple rate-limit retries.',
    429
  );
}

function wrapApiObject(obj: any): any {
  return new Proxy(obj, {
    get(target, prop) {
      const original = target[prop];
      if (typeof original === 'function') {
        return (...args: any[]) => withRetry(() => original.apply(target, args));
      }
      if (
        typeof original === 'object' &&
        original !== null &&
        !(original instanceof Promise)
      ) {
        return wrapApiObject(original);
      }
      return original;
    },
  });
}

export function createRetryableClient(client: OpenAI): OpenAI {
  return new Proxy(client, {
    get(target, prop) {
      const original = (target as any)[prop];
      if (
        typeof original === 'object' &&
        original !== null &&
        !(original instanceof Promise)
      ) {
        return wrapApiObject(original);
      }
      if (typeof original === 'function') {
        return (...args: any[]) => withRetry(() => original.apply(target, args));
      }
      return original;
    },
  }) as OpenAI;
}

export function createRetryableChatModel(model: ChatOpenAI): ChatOpenAI {
  const originalInvoke = model.invoke.bind(model);
  const originalStream = model.stream.bind(model);
  const originalBindTools = model.bindTools.bind(model);
  const originalWithStructuredOutput = model.withStructuredOutput.bind(model);

  model.invoke = (...args: any[]): any => withRetry(() => originalInvoke(...args));
  model.stream = (...args: any[]): any => withRetry(() => originalStream(...args));
  model.bindTools = (...args: any[]) => {
    const bound = originalBindTools(...args);
    const origBoundInvoke = bound.invoke.bind(bound);
    bound.invoke = (...a: any[]) => withRetry(() => origBoundInvoke(...a));
    return bound;
  };
  model.withStructuredOutput = (...args: any[]) => {
    const output = originalWithStructuredOutput(...args);
    const origPipe = output.pipe ? output.pipe.bind(output) : undefined;
    if (output.invoke) {
      const origInvoke = output.invoke.bind(output);
      output.invoke = (...a: any[]) => withRetry(() => origInvoke(...a));
    }
    return output;
  };

  return model;
}

export async function withRetryDalle(prompt: string, dalle: DallEAPIWrapper): Promise<string> {
  return withRetry(() => dalle.invoke(prompt));
}
