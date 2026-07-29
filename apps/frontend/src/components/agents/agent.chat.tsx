'use client';

import React, {
  FC,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import { CopilotChat, CopilotKitCSSProperties } from '@copilotkit/react-ui';
import {
  InputProps,
  UserMessageProps,
  RenderMessageProps,
} from '@copilotkit/react-ui/dist/components/chat/props';
import { Input } from '@gitroom/frontend/components/agents/agent.input';
import { useModals } from '@gitroom/frontend/components/layout/new-modal';
import {
  CopilotKit,
  useCopilotAction,
  useCopilotChat,
  useCopilotMessagesContext,
  useCopilotContext,
} from '@copilotkit/react-core';
import {
  MediaPortal,
  PropertiesContext,
} from '@gitroom/frontend/components/agents/agent';
import { useVariables } from '@gitroom/react/helpers/variable.context';
import { useParams } from 'next/navigation';
import { useFetch } from '@gitroom/helpers/utils/custom.fetch';
import {
  Message as CopilotMessage,
  TextMessage,
} from '@copilotkit/runtime-client-gql';
import { AddEditModal } from '@gitroom/frontend/components/new-launch/add.edit.modal';
import dayjs from 'dayjs';
import { makeId } from '@gitroom/nestjs-libraries/services/make.is';
import { ExistingDataContextProvider } from '@gitroom/frontend/components/launches/helpers/use.existing.data';
import { useT } from '@gitroom/react/translation/get.transation.service.client';
import { hasExtension } from '@gitroom/helpers/utils/has.extension';

const AgentRenderMessage: FC<RenderMessageProps> = (props) => {
  const { message, UserMessage, AssistantMessage, ...rest } = props;

  if (message?.isResultMessage?.()) {
    const msg = message as any;
    if (msg.actionName === 'generateImageTool') {
      let parsed: { path?: string } = {};
      try {
        parsed =
          typeof msg.result === 'string' ? JSON.parse(msg.result) : msg.result;
      } catch {
        return null;
      }
      if (parsed.path) {
        return (
          <div className="flex justify-start px-4 py-2">
            <img
              src={parsed.path}
              alt="Generated"
              className="w-full rounded-lg border border-custom6"
            />
          </div>
        );
      }
    }
  }

  if (message?.role === 'assistant' && AssistantMessage) {
    return <AssistantMessage {...rest} message={message} />;
  }

  if (message?.role === 'user' && UserMessage) {
    return <UserMessage {...rest} message={message} />;
  }
  return null;
};

export const AgentChat: FC = () => {
  const { backendUrl } = useVariables();
  const params = useParams<{ id: string }>();
  const { properties } = useContext(PropertiesContext);
  const t = useT();

  return (
    <CopilotKit
      {...(params.id === 'new' ? {} : { threadId: params.id })}
      credentials="include"
      runtimeUrl={backendUrl + '/copilot/agent'}
      showDevConsole={false}
      agent="postiz"
      properties={{
        integrations: properties,
      }}
    >
      <Hooks />
      <LoadMessages id={params.id} />
      <div
        style={
          {
            '--copilot-kit-primary-color': 'var(--new-btn-text)',
            '--copilot-kit-background-color': 'var(--new-bg-color)',
          } as CopilotKitCSSProperties
        }
        className="trz agent bg-newBgColorInner flex flex-col gap-[15px] transition-all flex-1 items-center relative"
      >
        <div className="absolute left-0 w-full h-full pb-[20px]">
          <CopilotChat
            className="w-full h-full [&_img]:max-w-full [&_img]:w-auto [&_img]:h-auto"
            labels={{
              title: t('your_assistant', 'Your Assistant'),
              initial: t('agent_welcome_message', `Hello, I am your Postiz agent 🙌🏻.
              
I can schedule a post or multiple posts to multiple channels and generate pictures and videos.

You can select the channels you want to use from the left menu.

You can see your previous conversations from the right menu.

You can also use me as an MCP Server, check Settings >> Public API
`),
            }}
            UserMessage={Message}
            Input={NewInput}
            RenderMessage={AgentRenderMessage}
          />
        </div>
      </div>
    </CopilotKit>
  );
};

const LoadMessages: FC<{ id: string }> = ({ id }) => {
  const { messages, setMessages } = useCopilotMessagesContext();
  const fetch = useFetch();
  const currentId = useRef<string | null>(null);
  const loaded = useRef<{ id: string; messages: CopilotMessage[] } | null>(
    null
  );

  const loadMessages = useCallback(async (idToSet: string) => {
    const data = await (await fetch(`/copilot/${idToSet}/list`)).json();
    const list = data.messages.map((p: any) => {
      return new TextMessage({
        content: p.content.content,
        role: p.role,
      });
    });

    if (currentId.current !== idToSet) {
      return;
    }

    loaded.current = { id: idToSet, messages: list };
    setMessages(list);
  }, []);

  useEffect(() => {
    currentId.current = id;
    if (id === 'new') {
      loaded.current = { id, messages: [] };
      setMessages([]);
      return;
    }
    loaded.current = null;
    loadMessages(id);
  }, [id]);

  // CopilotKit resolves loadAgentState to an empty list for Mastra local agents
  // and can clobber the messages we hold, depending on which request resolves last
  useEffect(() => {
    if (loaded.current?.id !== id) {
      return;
    }

    if (messages.length) {
      loaded.current.messages = messages;
      return;
    }

    if (loaded.current.messages.length) {
      setMessages(loaded.current.messages);
    }
  }, [messages, id]);

  return null;
};

const Message: FC<UserMessageProps> = (props) => {
  const convertContentToImagesAndVideo = useMemo(() => {
    return (props.message?.content || '')
      .replace(/Video: (http.*mp4\n)/g, (match, p1) => {
        return `<video controls class="h-[150px] w-[150px] rounded-[8px] mb-[10px]"><source src="${p1.trim()}" type="video/mp4">Your browser does not support the video tag.</video>`;
      })
      .replace(/Image: (http.*\n)/g, (match, p1) => {
        return `<img src="${p1.trim()}" class="h-[150px] w-[150px] max-w-full border border-newBgColorInner" />`;
      })
      .replace(/\[\-\-Media\-\-\](.*)\[\-\-Media\-\-\]/g, (match, p1) => {
        return `<div class="flex justify-center mt-[20px]">${p1}</div>`;
      })
      .replace(
        /(\[--integrations--\][\s\S]*?\[--integrations--\])/g,
        (match, p1) => {
          return ``;
        }
      );
  }, [props.message?.content]);
  return (
    <div
      className="copilotKitMessage copilotKitUserMessage min-w-[300px]"
      dangerouslySetInnerHTML={{ __html: convertContentToImagesAndVideo }}
    />
  );
};
const NewInput: FC<InputProps> = (props) => {
  const [media, setMedia] = useState([] as { path: string; id: string }[]);
  const [value, setValue] = useState('');
  const { properties } = useContext(PropertiesContext);
  return (
    <>
      <MediaPortal
        value={value}
        media={media}
        setMedia={(e) => setMedia(e.target.value)}
      />
      <Input
        {...props}
        onChange={setValue}
        onSend={(text) => {
          const send = props.onSend(
            text +
              (media.length > 0
                ? '\n[--Media--]' +
                  media
                    .map((m) =>
                      hasExtension(m.path, 'mp4')
                        ? `Video: ${m.path}`
                        : `Image: ${m.path}`
                    )
                    .join('\n') +
                  '\n[--Media--]'
                : '') +
              `
${
  properties.length
    ? `[--integrations--]
Use the following social media platforms: ${JSON.stringify(
        properties.map((p) => ({
          id: p.id,
          platform: p.identifier,
          profilePicture: p.picture,
          additionalSettings: p.additionalSettings,
        }))
      )}
[--integrations--]`
    : ``
}`
          );
          setValue('');
          setMedia([]);
          return send;
        }}
      />
    </>
  );
};

export const Hooks: FC = () => {
  const modals = useModals();
  const context = useCopilotContext();
  const t = useT();
  const { runChatCompletion } = useCopilotChat();
  const [errorBanners, setErrorBanners] = useState<
    { id: string; message: string; retryable: boolean; title: string; url: string | null }[]
  >([]);
  const lastErrorRef = useRef('');

  const addError = useCallback((title: string, message: string, retryable: boolean, url: string | null) => {
    const key = title + message;
    if (lastErrorRef.current === key) return;
    lastErrorRef.current = key;
    setErrorBanners((prev) => [
      ...prev,
      { id: Date.now().toString(), title, message, retryable, url },
    ].slice(-3));
  }, []);

  const retryLastMessage = useCallback(() => {
    lastErrorRef.current = '';
    setErrorBanners([]);
    runChatCompletion();
  }, [runChatCompletion]);

  useEffect(() => {
    const orig = console.error;
    console.error = (...args: any[]) => {
      orig.apply(console, args);
      const msg = args.join(' ');
      if (!msg.includes('AI_APICallError') && !msg.includes('Provider returned error')) return;

      const urlMatch = msg.match(/https:\/\/[^\s)]+/);
      const extractedUrl = urlMatch ? urlMatch[0] : null;

      const isQuota = /credit|quota|402|insufficient|only afford|daily limit|key limit/i.test(msg);
      const isCtx = /context.*length|too many tokens/i.test(msg);
      const isGuard = /guardrail|endpoint.*available|data policy/i.test(msg);
      const isRetry = /rate.limit|429/i.test(msg);

      if (isQuota) {
        const creditsMatch = msg.match(/only afford (\d+)/);
        const creditsStr = creditsMatch ? creditsMatch[1] : 'unknown';
        addError(
          `\uD83D\uDCB3 ${t('error_ai_quota_title', 'Quota Exceeded')}`,
          t('error_ai_quota_message', 'Daily API key quota reached. Increase your limit in the provider settings.'),
          true,
          extractedUrl
        );
      } else if (isCtx) {
        addError(
          `\u{1F4CF} ${t('error_ai_context_title', 'Context Too Long')}`,
          t('error_ai_context_message', 'Start a new conversation.'),
          false, null);
      } else if (isGuard) {
        addError(
          `\u{1F512} ${t('error_ai_guardrail_title', 'Model Blocked')}`,
          t('error_ai_guardrail_message', 'Your provider privacy settings block this model. Adjust them in your account settings.'),
          false, extractedUrl);
      } else if (isRetry) {
        addError(
          `\u23F3 ${t('error_ai_temporary_title', 'Temporary AI Error')}`,
          msg.substring(0, 200), true, null);
      } else {
        addError(
          `\u{1F527} ${t('error_ai_generic_title', 'AI Error')}`,
          msg.substring(0, 200), true, null);
      }
    };
    return () => { console.error = orig; };
  }, []);

  useCopilotAction({
    name: 'manualPosting',
    description:
      'This tool should be triggered when the user wants to manually add the generated post',
    parameters: [
      {
        name: 'list',
        type: 'object[]',
        description:
          'list of posts to schedule to different social media (integration ids)',
        attributes: [
          {
            name: 'integrationId',
            type: 'string',
            description: 'The integration id',
          },
          {
            name: 'date',
            type: 'string',
            description: 'UTC date of the scheduled post',
          },
          {
            name: 'settings',
            type: 'object',
            description: 'Settings for the integration [input:settings]',
          },
          {
            name: 'posts',
            type: 'object[]',
            description: 'list of posts / comments (one under another)',
            attributes: [
              {
                name: 'content',
                type: 'string',
                description: 'the content of the post',
              },
              {
                name: 'attachments',
                type: 'object[]',
                description: 'list of attachments',
                attributes: [
                  {
                    name: 'id',
                    type: 'string',
                    description: 'id of the attachment',
                  },
                  {
                    name: 'path',
                    type: 'string',
                    description: 'url of the attachment',
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
    renderAndWaitForResponse: ({ args, status, respond }) => {
      if (status === 'executing') {
        return <OpenModal args={args} respond={respond} />;
      }

      return null;
    },
  });
  if (errorBanners.length === 0) return null;
  return (
    <div className="absolute bottom-[80px] left-1/2 -translate-x-1/2 flex flex-col gap-2 w-[95%] max-w-lg z-10">
      {errorBanners.map((err) => {
        const isQuota = err.title?.includes('💳');
        return (
          <div
            key={err.id}
            className={`rounded-xl px-5 py-4 shadow-lg backdrop-blur-sm ${
              isQuota
                ? 'bg-red-950/80 border border-red-800 text-red-100'
                : 'bg-amber-950/80 border border-amber-800 text-amber-100'
            }`}
          >
            <div className="flex items-center gap-3">
              <span className="text-2xl shrink-0">{err.title.split(' ')[0]}</span>
              <div className="flex-1 min-w-0">
                <div className="font-semibold text-sm">{err.title.substring(err.title.indexOf(' ') + 1)}</div>
                <div className={`text-xs mt-0.5 ${isQuota ? 'text-red-300' : 'text-amber-300'}`}>{err.message}</div>
              </div>
              <button
                className={`text-lg leading-none opacity-60 hover:opacity-100 shrink-0 ${isQuota ? 'text-red-400 hover:text-red-200' : 'text-amber-400 hover:text-amber-200'}`}
                onClick={() => setErrorBanners((prev) => prev.filter((e) => e.id !== err.id))}
              >
                ×
              </button>
            </div>
            {(err.retryable || err.url) && (
              <div className="flex gap-2 mt-3 justify-end">
                {err.url && (
                  <a
                    href={err.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className={`px-3.5 py-1.5 rounded-lg text-xs font-medium transition-colors ${
                      isQuota
                        ? 'bg-red-800/60 hover:bg-red-700/80 text-red-100'
                        : 'bg-amber-800/60 hover:bg-amber-700/80 text-amber-100'
                    }`}
                  >
                    ⚙️ {t('open_settings', 'Settings')}
                  </a>
                )}
                {err.retryable && (
                  <button
                    className={`px-3.5 py-1.5 rounded-lg text-xs font-medium transition-colors ${
                      isQuota
                        ? 'bg-red-800/60 hover:bg-red-700/80 text-red-100'
                        : 'bg-amber-800/60 hover:bg-amber-700/80 text-amber-100'
                    }`}
                    onClick={retryLastMessage}
                  >
                    🔄 {t('retry_action', 'Retry')}
                  </button>
                )}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
};

const OpenModal: FC<{
  respond: (value: any) => void;
  args: {
    list: {
      integrationId: string;
      date: string;
      settings?: Record<string, any>;
      posts: { content: string; attachments: { id: string; path: string }[] }[];
    }[];
  };
}> = ({ args, respond }) => {
  const modals = useModals();
  const { properties } = useContext(PropertiesContext);
  const startModal = useCallback(async () => {
    for (const integration of args.list) {
      await new Promise((res) => {
        const group = makeId(10);
        modals.openModal({
          id: 'add-edit-modal',
          closeOnClickOutside: false,
          removeLayout: true,
          closeOnEscape: false,
          withCloseButton: false,
          askClose: true,
          size: '80%',
          title: ``,
          classNames: {
            modal: 'w-[100%] max-w-[1400px] text-textColor',
          },
          children: (
            <ExistingDataContextProvider
              value={{
                group,
                integration: integration.integrationId,
                integrationPicture:
                  properties.find((p) => p.id === integration.integrationId)
                    ?.picture || '',
                settings: integration.settings || {},
                posts: integration.posts.map((p) => ({
                  approvedSubmitForOrder: 'NO',
                  content: p.content,
                  createdAt: new Date().toISOString(),
                  state: 'DRAFT',
                  id: makeId(10),
                  settings: JSON.stringify(integration.settings || {}),
                  group,
                  integrationId: integration.integrationId,
                  integration: properties.find(
                    (p) => p.id === integration.integrationId
                  ),
                  publishDate: dayjs.utc(integration.date).toISOString(),
                  image: p.attachments.map((a) => ({
                    id: a.id,
                    path: a.path,
                  })),
                })),
              }}
            >
              <AddEditModal
                date={dayjs.utc(integration.date)}
                allIntegrations={properties}
                integrations={properties.filter(
                  (p) => p.id === integration.integrationId
                )}
                onlyValues={integration.posts.map((p) => ({
                  content: p.content,
                  id: makeId(10),
                  settings: integration.settings || {},
                  image: p.attachments.map((a) => ({
                    id: a.id,
                    path: a.path,
                  })),
                }))}
                reopenModal={() => {}}
                mutate={() => res(true)}
              />
            </ExistingDataContextProvider>
          ),
        });
      });
    }

    respond('User scheduled all the posts');
  }, [args, respond, properties]);

  useEffect(() => {
    startModal();
  }, []);
  return (
    <div onClick={() => respond('continue')}>
      Opening manually ${JSON.stringify(args)}
    </div>
  );
};
