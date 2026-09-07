# Addon catalog rights and provenance model

Every release needs independent provenance and rights state. The catalog must not infer Return of Reckoning permission from a download URL, a filename, an Idrinth listing, or a user's claim that they found the archive.

Minimum release fields:

- `source_url` and `source_repository`
- `source_catalog` and `imported_at`
- `distribution_authority` and `distribution_authorized_at`
- `target_games` (`ror`, `dawn`, `other`, or explicit multi-game values)
- `rights_status` (`unverified`, `author-confirmed`, `license-confirmed`, `restricted`, `removed`)
- `submitted_by`, `rights_declaration_version`, and `rights_accepted_at`
- `sha256`, filename, archive type, and release version
- `moderation_status` and moderation audit events

The current Idrinth import may be marked `distribution-authorized` based on the maintainer's permission to mirror the catalog, with the authorization source and date recorded. That status permits Emissary to host and distribute the release; it does not by itself claim copyright ownership or override a third-party license. Only releases with `ror` in `target_games` may appear in the public Return of Reckoning catalog. Historical or other-project imports must remain visibly labeled with their target and rights state.
