# Cross-stack verification

`validate_contract.py` validates docs/openapi.json and the real HTTP snapshot in docs/evidence/curation.json. Install requirements.txt first. Flutter test/fixtures/curation.json is the same captured contract; it is not a production offline mode.

The optional `workspace_postgres` harness uses PostgreSQL WebAssembly when native PostgreSQL is unavailable. It is development-only, binds loopback, does not authenticate users, and must not be used as production infrastructure. It is NOT the default runbook database and does not replace native PostgreSQL CI.

```bash
cd tests/workspace_postgres
npm ci
PHP_BIN=php node verify.mjs
PHP_BIN=php node smoke.mjs
```

The harness creates separate ephemeral databases for development migration/seeding and test execution. It overwrites only sample public media and evidence fixtures. All PHP processes run under the same parent network namespace so local sockets work in isolated execution environments.
