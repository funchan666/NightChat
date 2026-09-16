#!/usr/bin/env python3
"""Audit full source coverage, unique ownership, and presentation continuity."""
import hashlib
import json
from collections import Counter
from pathlib import Path

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / 'AfterglowKeep/NightSocialMedia/media-manifest.json').read_text())
pics = root / 'assets/pics'
videos = root / 'assets/videos'
people = manifest['people']
assert len({p['deskKey'] for p in people}) == len(people), 'Repeated person ID'
photos = [manifest['localPortrait']] + [p[role] for p in people for role in ('portrait', 'cover')]
movies = [p['video'] for p in people if p['video']]
assert len(photos) == len(set(photos)), 'Photo assigned to multiple roles/people'
assert len(movies) == len(set(movies)), 'Video assigned to multiple rooms'
assert set(movies) == {p.name for p in videos.glob('*.mp4')}, 'Unused/missing video'
assert set(photos) | set(manifest['duplicateAliases']) == {p.name for p in pics.glob('*.jpg')}, 'Unused/missing photo'
hashes = [hashlib.sha256((pics / photo).read_bytes()).hexdigest() for photo in photos]
assert len(hashes) == len(set(hashes)), 'Duplicate visual content assigned'
for alias, canonical in manifest['duplicateAliases'].items():
    assert (pics / alias).read_bytes() == (pics / canonical).read_bytes(), 'Alias is not a duplicate'
for person in people:
    if person['video']:
        assert person['videoPresentation'] in (person['presentation'], 'scenery'), f"Presentation mismatch: {person['deskKey']}"
        assert (videos / person['video']).is_file()
print(f"PASS: {len(people)} people; {len(photos)} unique photos; {len(movies)} unique room videos; {len(manifest['duplicateAliases'])} identical-file aliases.")
print('Every source is accounted for. No source is assigned to unrelated owners.')
