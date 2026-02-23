---
name: query-postgres
description: Use when you need to query a PostgreSQL database for inspection, debugging, or data verification, especially in local development environments
user-invocable: true
---

# Query Postgres

## Overview

Use `psql` to interactively query PostgreSQL databases. When you need to check database state, inspect data, or run ad-hoc queries, `psql` is the fastest path - no scripts needed.

## When to Use

**Use this when:**
- Inspecting local database state during development
- Debugging data issues (checking counts, finding records, verifying state)
- Running ad-hoc queries to understand data
- Verifying migrations or seeding worked correctly

**Don't use when:**
- Running queries in production (use appropriate secured access)
- Credentials aren't available locally
- Building automated tools (use Prisma or your ORM instead)

## Core Pattern

**Direct psql command with inline SQL:**

```bash
psql "postgresql://postgres:password@localhost:5444/platform" -c "SELECT COUNT(*) FROM \"platform.user\";"
```

**For multiple queries, use multiple -c flags:**

```bash
psql "postgresql://postgres:password@localhost:5444/platform" \
  -c "SELECT COUNT(*) FROM \"platform.user\";" \
  -c "SELECT email FROM \"platform.user\" LIMIT 5;"
```

**For complex queries, use heredoc:**

```bash
psql "postgresql://postgres:password@localhost:5444/platform" <<EOF
SELECT
  table_name,
  (xpath('/row/cnt/text()', xml_count))[1]::text::int as row_count
FROM (
  SELECT table_name,
         query_to_xml(format('SELECT COUNT(*) AS cnt FROM %I.%I', table_schema, table_name), false, true, '') as xml_count
  FROM information_schema.tables
  WHERE table_schema = 'platform'
) t
ORDER BY row_count DESC;
EOF
```

## Quick Reference

| Task                  | Command                                                          |
| --------------------- | ---------------------------------------------------------------- |
| Count records         | `psql "connection_string" -c "SELECT COUNT(*) FROM table_name;"` |
| List tables           | `psql "connection_string" -c "\dt"`                              |
| Describe table        | `psql "connection_string" -c "\d table_name"`                    |
| Show schema           | `psql "connection_string" -c "\d+ table_name"`                   |
| Interactive mode      | `psql "connection_string"` then type queries                     |
| Get connection string | From `.env.example` file in project root                         |

## Project-Specific Details

**Connection string location:** Always in `.env.example` at project root as `DATABASE_URL`

**Database schema reference:** Full Prisma schema available at `packages/database/prisma/schema.prisma`

**Common format:** `postgresql://postgres:password@localhost:5444/platform`

**Schema names:** This project uses two schemas: `platform` (main tables) and `jobs` (job processing system). Check `packages/database/prisma/schema.prisma` for full model definitions.


## Common Mistakes

| Mistake                                     | Fix                                                    |
| ------------------------------------------- | ------------------------------------------------------ |
| Creating SQL files unnecessarily            | Use `-c` flag for single queries, heredoc for multiple |
| Writing Node.js scripts for one-off queries | Just use `psql` directly - it's faster                 |
| Not quoting table names with capitals       | Use `"TableName"` in quotes                            |
| Forgetting schema prefix                    | Use `schema_name.table_name` or `\dt schema_name.*`    |
| Over-engineering with ORMs                  | Local inspection doesn't need Prisma - raw SQL is fine |

## Red Flags - Consider psql Instead

These thoughts mean you might be over-engineering:
- "I'll create a script for this"
- "Let me use Prisma to query..."
- "I'll write a SQL file and pipe it"
- "I need to set up TypeScript types"

**Reality:** For one-off queries and inspection, `psql` is the right tool. Save scripting for automation.

## Security Note

**Local development:** Using credentials from `.env.example` is appropriate - these are local development credentials

**Production/Staging:** Never use this approach - use proper authenticated access through your deployment platform's secure interfaces

## Related Skills

**For database diagnostics and monitoring:** Use `/postgres-diagnostics` for essential queries to check:
- Active queries and sessions
- Connection usage and limits
- Locks and blocking queries
- Table and index statistics
- Cache hit rates and performance metrics
- System configuration and health
