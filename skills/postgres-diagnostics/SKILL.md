---
name: postgres-diagnostics
description: Essential PostgreSQL diagnostic queries for monitoring database health, performance, connections, locks, and system statistics
user-invocable: true
---

# PostgreSQL Diagnostics

Essential diagnostic queries for monitoring and managing PostgreSQL database health, performance, and operations.

## When to Use

**Use this when:**
- Investigating performance issues or slow queries
- Monitoring database health and resource usage
- Debugging connection or locking problems
- Checking index usage and table statistics
- Analyzing cache hit rates and system metrics

**Don't use when:**
- Making schema changes (use migrations instead)
- Querying application data (use `/query-postgres` instead)
- Running queries in production without understanding impact

## Core Pattern

Run these queries using `psql` with the connection string from `.env` or `.env.example`:

```bash
psql "postgresql://postgres:password@localhost:5444/platform" -c "QUERY_HERE"
```

For multiple diagnostics, use a heredoc with multiple queries.

---

## Active Queries & Sessions

### Currently Running Queries with Duration
```sql
SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state, wait_event_type, wait_event
FROM pg_stat_activity
WHERE state != 'idle' AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY duration DESC;
```

### All Connections by State
```sql
SELECT state, count(*) FROM pg_stat_activity GROUP BY state;
```

### Long-Running Queries (over 5 minutes)
```sql
SELECT pid, now() - query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active' AND now() - query_start > interval '5 minutes';
```

---

## Connections

### Connection Counts by Database and User
```sql
SELECT datname, usename, count(*)
FROM pg_stat_activity
GROUP BY datname, usename ORDER BY count DESC;
```

### Max Connections vs Current Usage
```sql
SELECT max_conn, used, max_conn - used AS available
FROM (SELECT count(*) AS used FROM pg_stat_activity) t1,
     (SELECT setting::int AS max_conn FROM pg_settings WHERE name = 'max_connections') t2;
```

### Connections by Client IP
```sql
SELECT client_addr, count(*) FROM pg_stat_activity
WHERE client_addr IS NOT NULL GROUP BY client_addr ORDER BY count DESC;
```

---

## Locks & Blocking

### Blocked Queries and What's Blocking Them
```sql
SELECT blocked.pid AS blocked_pid, blocked.query AS blocked_query,
       blocking.pid AS blocking_pid, blocking.query AS blocking_query
FROM pg_stat_activity blocked
JOIN pg_locks blocked_locks ON blocked.pid = blocked_locks.pid
JOIN pg_locks blocking_locks ON blocked_locks.locktype = blocking_locks.locktype
  AND blocked_locks.relation = blocking_locks.relation AND blocked_locks.pid != blocking_locks.pid
JOIN pg_stat_activity blocking ON blocking_locks.pid = blocking.pid
WHERE NOT blocked_locks.granted;
```

### All Current Locks
```sql
SELECT relation::regclass, mode, granted, pid
FROM pg_locks WHERE relation IS NOT NULL ORDER BY relation;
```

---

## Database & Table Statistics

### Database Sizes
```sql
SELECT datname, pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database ORDER BY pg_database_size(datname) DESC;
```

### Largest Tables
```sql
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS total_size
FROM pg_tables WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC LIMIT 20;
```

### Table Bloat Estimate (Dead Tuples)
```sql
SELECT schemaname, relname, n_live_tup, n_dead_tup,
       round(n_dead_tup * 100.0 / nullif(n_live_tup + n_dead_tup, 0), 2) AS dead_pct
FROM pg_stat_user_tables WHERE n_dead_tup > 1000 ORDER BY n_dead_tup DESC;
```

---

## Index Health

### Unused Indexes (Potential Candidates for Removal)
```sql
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes WHERE idx_scan = 0 AND indexrelname NOT LIKE '%_pkey';
```

### Index Hit Rate (should be > 95%)
```sql
SELECT sum(idx_blks_hit) * 100.0 / nullif(sum(idx_blks_hit + idx_blks_read), 0) AS index_hit_rate
FROM pg_statio_user_indexes;
```

### Missing Indexes (High Sequential Scans on Large Tables)
```sql
SELECT schemaname, relname, seq_scan, seq_tup_read, idx_scan,
       seq_tup_read / nullif(seq_scan, 0) AS avg_seq_tup
FROM pg_stat_user_tables WHERE seq_scan > 100 ORDER BY seq_tup_read DESC LIMIT 20;
```

---

## Cache & Performance

### Cache Hit Ratio (should be > 99%)
```sql
SELECT sum(heap_blks_hit) * 100.0 / nullif(sum(heap_blks_hit + heap_blks_read), 0) AS cache_hit_ratio
FROM pg_statio_user_tables;
```

### Checkpoint and BGWriter Stats
```sql
SELECT * FROM pg_stat_bgwriter;
```

### Replication Lag (if using replication)
```sql
SELECT client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS byte_lag
FROM pg_stat_replication;
```

---

## System Information

### PostgreSQL Version and Uptime
```sql
SELECT version(), pg_postmaster_start_time(), now() - pg_postmaster_start_time() AS uptime;
```

### Key Configuration Settings
```sql
SELECT name, setting, unit FROM pg_settings
WHERE name IN ('shared_buffers', 'work_mem', 'maintenance_work_mem', 'effective_cache_size',
               'max_connections', 'max_wal_size', 'checkpoint_completion_target');
```

### Current Database Activity Summary
```sql
SELECT datname, numbackends, xact_commit, xact_rollback, blks_read, blks_hit,
       round(blks_hit * 100.0 / nullif(blks_hit + blks_read, 0), 2) AS hit_ratio
FROM pg_stat_database WHERE datname = current_database();
```

---

## Useful Admin Commands

### Kill a Specific Query
```sql
SELECT pg_cancel_backend(pid);    -- graceful
SELECT pg_terminate_backend(pid); -- forceful
```

### Check if Vacuum/Analyze is Needed
```sql
SELECT schemaname, relname, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze
FROM pg_stat_user_tables ORDER BY last_autovacuum NULLS FIRST;
```

---

## Quick Start Examples

**Check active queries:**
```bash
psql "$DATABASE_URL" -c "SELECT pid, now() - pg_stat_activity.query_start AS duration, query FROM pg_stat_activity WHERE state != 'idle' AND query NOT ILIKE '%pg_stat_activity%' ORDER BY duration DESC;"
```

**Check connection usage:**
```bash
psql "$DATABASE_URL" -c "SELECT state, count(*) FROM pg_stat_activity GROUP BY state;"
```

**Check cache hit ratio:**
```bash
psql "$DATABASE_URL" -c "SELECT sum(heap_blks_hit) * 100.0 / nullif(sum(heap_blks_hit + heap_blks_read), 0) AS cache_hit_ratio FROM pg_statio_user_tables;"
```

---

## Notes

- The `pg_stat_*` views are your primary source for runtime diagnostics
- The `pg_settings` view gives you configuration visibility
- Most statistics are cumulative since the last stats reset
- High values don't always indicate problems - consider context and baselines
- For production databases, be cautious with queries that scan large result sets

## Related Skills

- Use `/query-postgres` for general database querying and inspection
- These diagnostic queries are specifically for monitoring and troubleshooting
