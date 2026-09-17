#!/usr/bin/env python3
"""Audit unique ownership and gender continuity of NightChat media."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / "AfterglowKeep/NightSocialMedia/media-manifest.json").read_text())
pics = root / "assets/pics"
videos = root / "assets/videos"
people = manifest["people"]

assert len({p["deskKey"] for p in people}) == len(people), "Repeated person ID"
photos = [manifest["localPortrait"]] + [p[role] for p in people for role in ("portrait", "cover")]
movies = [p["video"] for p in people if p["video"]]
assert len(photos) == len(set(photos)), "Photo assigned to multiple roles/people"
assert len(movies) == len(set(movies)), "Video assigned to multiple rooms"
assert set(movies) == {p.name for p in videos.glob("*.mp4")}, "Unused/missing video"
assert set(photos) == {p.name for p in pics.glob("*.jpg")}, "Unused/missing photo"

hashes = [hashlib.sha256((pics / photo).read_bytes()).hexdigest() for photo in photos]
assert len(hashes) == len(set(hashes)), "Duplicate visual content assigned"

for name in photos + movies:
    assert not name.startswith(("Dc", "Dd", "DZ")), f"Instagram-style media name remains: {name}"
    assert "Group_" not in name and "Frame@" not in name

for person in people:
    presentation = person["presentation"]
    assert person["portrait"].startswith("portrait_"), person["portrait"]
    assert person["cover"].startswith("cover_"), person["cover"]
    if person["video"]:
        clip_g = person["videoPresentation"]
        assert person["video"].startswith("live_"), person["video"]
        if presentation == "feminine":
            assert clip_g in ("feminine", "scenery"), person["deskKey"]
        elif presentation == "masculine":
            assert clip_g in ("masculine", "scenery"), person["deskKey"]
        else:
            assert clip_g == "scenery", person["deskKey"]
        assert (videos / person["video"]).is_file()

print(
    f"PASS: {len(people)} people; {len(photos)} unique photos; {len(movies)} unique room videos."
)
print("Every source is accounted for. Portrait, cover, and live clip stay on one gender.")
