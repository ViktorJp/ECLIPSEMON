import os
import requests
import pandas as pd
from datetime import datetime, timezone

REPO_FULL = os.environ.get("GITHUB_REPOSITORY", "")
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
CSV_FILE = "metrics/release_downloads.csv"

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
                "size_bytes": asset.get("size")
            })

    return records

def update_historical_data(records):
    os.makedirs(os.path.dirname(CSV_FILE), exist_ok=True)
    df_new = pd.DataFrame(records)

    if os.path.exists(CSV_FILE):
        df_existing = pd.read_csv(CSV_FILE)
        df_combined = pd.concat([df_existing, df_new], ignore_index=True)
    else:
        df_combined = df_new

    df_combined.to_csv(CSV_FILE, index=False)
    print(f"Updated {CSV_FILE} with {len(records)} asset entries.")

if __name__ == "__main__":
    if not REPO_FULL:
        raise ValueError("GITHUB_REPOSITORY environment variable is missing.")
    data = fetch_release_stats()
    update_historical_data(data)
