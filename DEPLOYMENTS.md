# Deployment Log

Every deploy is recorded here (one row per deploy per environment).
Deploy command: `npx firebase-tools@15.25.1 deploy --only hosting --project <id> --message "vX.Y.Z+N <short-hash>"`

| Date (UTC) | Environment | Version | Commit | URL | Verified | Notes |
|---|---|---|---|---|---|---|
| 2026-04-22 | prod | 1.6.6+8 | legacy (pre-log) | https://stock-count-app-c381c.web.app | yes | Live build backed up 2026-08-05 -> C:\xampp\htdocs\stock-count-app-prod-backup-2026-08-05 (+ .zip). Tracked hosting cache found stale vs live |
| 2026-08-05 | staging | (pending) | (pending) | https://stock-count-app-staging.web.app | - | First staging deploy; project + hosting site exist |
