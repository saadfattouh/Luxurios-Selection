# Decisions

| ID | Decision | Reason |
|---|---|---|
| 001 | New monorepo, baseline empty Git commit | No project or local instructions existed in the working directory. No user files replaced. |
| 002 | Laravel 13 on PHP 8.3, PostgreSQL | Explicit requested baseline; PHP compatibility checked against official Laravel documentation. |
| 003 | Provider + ChangeNotifier, handwritten typed DTOs | Small, clear MVVM-style slice without code-generation overhead; repository remains replaceable. |
| 004 | Native Flutter Android plus web runner | Android-first implementation; web is a convenient additional development target. |
| 005 | One bounded home endpoint plus paginated indexes | One entrance round trip; predictable editorial payload. Full browsing remains Phase 2. |
| 006 | Store EN/AR together, English UI initially | Bilingual data foundation without pretending full RTL localization is implemented. |
| 007 | Public reference media bundled locally | No runtime dependency on a stock-photo CDN; fictional artist claims are disclosed. |
| 008 | Public, read-only endpoints; no auth scaffolding | No private or mutating operations exist. Add policies before future protected use cases. |
| 009 | No automatic fixture fallback | Network failures remain honest and retryable. Fixtures exist only in tests. |
| 010 | Database queue foundation | Slow future media/index tasks must move to jobs; none is needed in Phase 1 HTTP. |
| 011 | PGlite only for workspace verification | Native PostgreSQL unavailable under root-only mapped UID; native PostgreSQL CI remains mandatory. |
| 012 | Respect Flutter auto-review block | Startup attempted a cloud metadata endpoint; do not bypass or claim unrun tests/builds. |

## Sources consulted

- Laravel 13 release / PHP requirements: https://laravel.com/docs/13.x/releases
- Laravel exception configuration: https://laravel.com/docs/13.x/errors
- Flutter installation: https://docs.flutter.dev/install
- PostgreSQL wire adapter used for temporary verification: https://github.com/kamilogorek/pglite-server

Dependency versions for PHP are fixed by composer.lock. Flutter package versions are constrained in pubspec.yaml; a pubspec.lock cannot honestly be supplied until package resolution succeeds in an authorized Flutter environment. CI currently uses stable Flutter; pin the verified SDK and commit pubspec.lock after that gate succeeds.
