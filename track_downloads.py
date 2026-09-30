from datetime import datetime, timezone
import os
import pandas as pd
from pandas.errors import EmptyDataError, ParserError
import requests

REPO_FULL = os.environ.get("GITHUB_REPOSITORY", "")
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
CSV_FILE = "metrics/release_downloads.csv"
SCHEMA_COLUMNS = [
    "timestamp",
    "release_tag",
    "asset_name",
    "total_downloads",
    "size_bytes",
]


def fetch_release_stats():
  headers = {"Accept": "application/vnd.github+json"}
  if GITHUB_TOKEN:
    headers["Authorization"] = f"Bearer {GITHUB_TOKEN}"

  url = f"https://api.github.com/repos/{REPO_FULL}/releases"
  response = requests.get(url, headers=headers)
  response.raise_for_status()
  releases = response.json()

  now = datetime.now(timezone.utc).isoformat()
  records = []

  for release in releases:
    tag = release.get("tag_name")
    for asset in release.get("assets", []):
      records.append({
          "timestamp": now,
          "release_tag": tag,
          "asset_name": asset.get("name"),
          "total_downloads": asset.get("download_count"),
          "size_bytes": asset.get("size"),
      })

  return records


def update_historical_data(records):
  os.makedirs(os.path.dirname(CSV_FILE), exist_ok=True)

  df_existing = pd.DataFrame(columns=SCHEMA_COLUMNS)

  # Check both existence and size to prevent EmptyDataError on 0-byte files
  if os.path.exists(CSV_FILE) and os.path.getsize(CSV_FILE) > 0:
    try:
      df_existing = pd.read_csv(CSV_FILE)
    except (EmptyDataError, ParserError):
      df_existing = pd.DataFrame(columns=SCHEMA_COLUMNS)

  if records:
    df_new = pd.DataFrame(records)
  else:
    print("Notice: No release assets found in GitHub API response.")
    df_new = pd.DataFrame(columns=SCHEMA_COLUMNS)

  # Combine existing data and new records
  if not df_existing.empty and not df_new.empty:
    df_combined = pd.concat([df_existing, df_new], ignore_index=True)
  elif not df_new.empty:
    df_combined = df_new
  elif not df_existing.empty:
    df_combined = df_existing
  else:
    # Ensures a valid CSV with headers is created even if there are 0 releases
    df_combined = pd.DataFrame(columns=SCHEMA_COLUMNS)

  df_combined.to_csv(CSV_FILE, index=False)
  print(f"Updated {CSV_FILE} with {len(records)} asset entries.")


if __name__ == "__main__":
  if not REPO_FULL:
    raise ValueError("GITHUB_REPOSITORY environment variable is missing.")
  data = fetch_release_stats()
  update_historical_data(data)
