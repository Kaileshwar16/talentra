#!/usr/bin/env bash
set -euo pipefail

# Resume the verified 100k/10k/500k checkpoint in talentra_local.
# Each generated batch is atomic and can be rerun after interruption.
container=queryparity-postgres-1
database=talentra_local
min_free_bytes=2147483648

check_space() {
  local free_bytes
  free_bytes=$(df -B1 --output=avail "$PWD" | tail -n 1 | tr -d ' ')
  if (( free_bytes < min_free_bytes )); then
    echo "Stopping: only $free_bytes bytes free; need at least $min_free_bytes" >&2
    exit 1
  fi
}

load() {
  local stage=$1 start=$2 end=$3
  shift 3
  check_space
  echo "$stage $start-$end"
  python3 phase5/seeds/generate_core.py "$stage" --start "$start" --end "$end" "$@" |
    docker exec -i "$container" sh -c \
      'psql -X -q -1 -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d talentra_local'
}

for stage in users candidates; do
  for ((start=100001; start<=1000000; start+=50000)); do
    end=$((start + 49999))
    load "$stage" "$start" "$end"
  done
done

load jobs 10001 100000 --accounts 100

for ((start=100001; start<=1000000; start+=50000)); do
  end=$((start + 49999))
  load applications "$start" "$end" --jobs 100000 --applications-per-candidate 5
done

echo "Core seed complete in $database"
