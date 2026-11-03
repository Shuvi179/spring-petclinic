#!/bin/bash
# SessionStart hook (see .claude/settings.json): makes sure the Docker daemon is running in
# Claude Code cloud sessions. The environment cache keeps files, not processes, so dockerd
# has to be started in every session. Without it, MySqlIntegrationTests and
# PostgresIntegrationTests are silently SKIPPED instead of failing.
#
# Does nothing on local machines.

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

if docker info >/dev/null 2>&1; then
  echo "[petclinic] Docker is running"
  exit 0
fi

nohup dockerd >/var/log/dockerd.log 2>&1 &
for _ in $(seq 1 30); do
  if docker info >/dev/null 2>&1; then
    echo "[petclinic] Docker started"
    exit 0
  fi
  sleep 1
done

echo "[petclinic] WARNING: dockerd did not start (see /var/log/dockerd.log);" \
  "Docker-based integration tests will be skipped" >&2
exit 0
