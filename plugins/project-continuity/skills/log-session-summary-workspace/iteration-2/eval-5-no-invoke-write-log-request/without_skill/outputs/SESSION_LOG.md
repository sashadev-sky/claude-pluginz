# Session Log — 2026-05-01

## Summary

Debugged and resolved an authentication bug that was causing users to be unexpectedly logged out. The root cause was identified as a race condition in the token refresh logic, and the fix was landed and merged.

---

## Authentication Bug: Key Decisions

### Problem
- Users were being logged out intermittently during active sessions
- Bug traced to the token refresh flow: multiple concurrent requests could each trigger a refresh independently, causing the first refresh to invalidate the token before the others completed
- Affected the `/api/auth/refresh` endpoint logic

### Root Cause
Race condition in `refreshAccessToken()`: when several requests fired simultaneously near token expiry, each called the refresh endpoint independently. The first successful refresh invalidated the old refresh token; subsequent calls with the stale refresh token returned 401, triggering a forced logout.

### Decision: Use a mutex / in-flight deduplication

We decided to introduce an in-flight promise cache so that if a refresh is already in progress, subsequent callers await the same promise rather than issuing a new request. This was preferred over:
- A server-side lock (too much infrastructure overhead)
- Simply increasing token TTL (masks the problem, doesn't fix it)

### Fix Applied
```ts
let refreshPromise: Promise<Token> | null = null;

async function refreshAccessToken(): Promise<Token> {
  if (refreshPromise) return refreshPromise;
  refreshPromise = doRefresh().finally(() => {
    refreshPromise = null;
  });
  return refreshPromise;
}
```

### Testing
- Added unit tests covering concurrent refresh calls — verified only one HTTP request is issued
- Manual QA confirmed no logout under rapid parallel API calls
- Fix merged to `main`; deployed to staging

---

## Files Touched

- `src/auth/tokenManager.ts` — added in-flight deduplication
- `src/auth/tokenManager.test.ts` — new concurrent-refresh test cases
- `src/api/client.ts` — updated to use revised `refreshAccessToken` signature

---

## Open Items / Follow-ups

- [ ] Monitor error rates on `/api/auth/refresh` in production after deploy
- [ ] Consider adding observability (log when deduplication actually fires)
- [ ] Review whether similar race conditions exist in other token-related flows

---

*Log written at end of session on 2026-05-01.*
