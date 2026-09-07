# Addon catalog security model

Addon archives and author-provided metadata are untrusted input.

1. Public browsing and downloading do not require an account.
2. Author login uses an external identity provider; Emissary does not store passwords.
3. Author accounts cannot publish directly. Releases enter moderation first.
4. GitHub releases are preferred to minimize duplicate binary storage.
5. Direct uploads are size-limited, extension-allowlisted, checksum-recorded, and scanned before review.
6. Archives are never extracted into the application runtime or executed by the service.
7. Upload paths are generated server-side; user input cannot select filesystem paths.
8. Provider tokens and storage credentials remain server-side with least-privilege access.
9. Moderation events, ownership claims, removals, and release changes are auditable.
10. Personal profile data is minimized and never published without the author's choice.

Addon metadata belongs in a dedicated database schema. Release files belong in GitHub releases or existing object storage, subject to strict quotas. Binaries must not be placed in the game-data tables or exposed through staff credentials.
