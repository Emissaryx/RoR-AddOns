# RoR Addons

Emissary's Return of Reckoning addon catalog prototype.

## Current slice

- Idrinth-style public addon browsing with search and category filters.
- Release detail drawer with version and download metadata.
- Author portal entry point reserved for authenticated submissions.
- Visible content-rights and security documentation.
- GitHub-first distribution model; direct uploads remain moderated and quota-limited.

## Planned service boundary

The frontend will consume a stable addon API. A dedicated database schema will store metadata, rights declarations, authors, dependencies, and moderation events. Release archives will remain in GitHub releases or existing object storage rather than game-data tables.

See [CONTENT-RIGHTS.md](CONTENT-RIGHTS.md), [DATA-MODEL.md](DATA-MODEL.md), and [SECURITY.md](SECURITY.md).
