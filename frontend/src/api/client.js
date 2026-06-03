const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '';
const SESSION_KEY = 'ftc_console_session';

let session = readSession();
let refreshPromise = null;

function readSession() {
  try {
    const raw = localStorage.getItem(SESSION_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

function writeSession(nextSession) {
  session = nextSession;
  if (nextSession) {
    localStorage.setItem(SESSION_KEY, JSON.stringify(nextSession));
  } else {
    localStorage.removeItem(SESSION_KEY);
  }
  window.dispatchEvent(new CustomEvent('session-change', { detail: nextSession }));
}

function normalizeList(payload) {
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.results)) return payload.results;
  return [];
}

function buildUrl(path, params) {
  const url = new URL(`${API_BASE_URL}${path}`, window.location.origin);
  Object.entries(params || {}).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      url.searchParams.set(key, value);
    }
  });
  return API_BASE_URL ? url.toString() : `${url.pathname}${url.search}${url.hash}`;
}

async function parseResponse(response) {
  if (response.status === 204) return null;
  const text = await response.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

function getErrorMessage(payload, fallback) {
  if (!payload) return fallback;
  if (typeof payload === 'string') return payload;
  if (payload.detail) return payload.detail;
  const firstKey = Object.keys(payload)[0];
  const firstValue = payload[firstKey];
  if (Array.isArray(firstValue)) return `${firstKey}: ${firstValue.join(' ')}`;
  if (typeof firstValue === 'string') return `${firstKey}: ${firstValue}`;
  return fallback;
}

async function refreshAccessToken() {
  if (!session?.refresh) throw new Error('登录已过期，请重新登录');
  if (!refreshPromise) {
    refreshPromise = fetch(buildUrl('/api/auth/refresh/'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refresh: session.refresh }),
    })
      .then(async (response) => {
        const payload = await parseResponse(response);
        if (!response.ok) throw new Error(getErrorMessage(payload, '刷新登录状态失败'));
        const nextSession = {
          ...session,
          access: payload.access,
          refresh: payload.refresh || session.refresh,
        };
        writeSession(nextSession);
        return nextSession.access;
      })
      .finally(() => {
        refreshPromise = null;
      });
  }
  return refreshPromise;
}

async function request(path, options = {}, retry = true) {
  const headers = new Headers(options.headers || {});
  const isFormData = options.body instanceof FormData;
  if (!isFormData && options.body !== undefined && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json');
  }
  if (session?.access) {
    headers.set('Authorization', `Bearer ${session.access}`);
  }

  const response = await fetch(buildUrl(path, options.params), {
    ...options,
    headers,
    body: isFormData || options.body === undefined ? options.body : JSON.stringify(options.body),
  });

  if (response.status === 401 && retry && session?.refresh) {
    try {
      await refreshAccessToken();
      return request(path, options, false);
    } catch (error) {
      writeSession(null);
      throw error;
    }
  }

  const payload = await parseResponse(response);
  if (!response.ok) {
    throw new Error(getErrorMessage(payload, '请求失败'));
  }
  return payload;
}

export const auth = {
  getSession() {
    return session;
  },
  saveSession(nextSession) {
    writeSession(nextSession);
  },
  async login(values) {
    const payload = await request('/api/auth/login/', {
      method: 'POST',
      body: values,
    }, false);
    writeSession(payload);
    return payload;
  },
  async logout() {
    const refresh = session?.refresh;
    try {
      if (refresh) {
        await request('/api/auth/logout/', {
          method: 'POST',
          body: { refresh },
        }, false);
      }
    } finally {
      writeSession(null);
    }
  },
};

export const api = {
  get: (path, params) => request(path, { params }),
  list: async (path, params) => normalizeList(await request(path, { params })),
  create: (path, data) => request(path, { method: 'POST', body: data }),
  update: (path, id, data) => request(`${path}${encodeURIComponent(id)}/`, { method: 'PATCH', body: data }),
  remove: (path, id) => request(`${path}${encodeURIComponent(id)}/`, { method: 'DELETE' }),
};
