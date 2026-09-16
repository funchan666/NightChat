#!/usr/bin/env python3
"""Audit full source coverage, unique ownership, and gender continuity.

Portrait, cover, and live clip for one person must not mix a feminine
presentation with a masculine subject (or the reverse). Scenery clips
are the only videos allowed across presentation.
"""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / "AfterglowKeep/NightSocialMedia/media-manifest.json").read_text())
pics = root / "assets/pics"
videos = root / "assets/videos"
people = manifest["people"]

FEMININE_PHOTOS = {
    "Dc0X-ygiGzb.jpg",
    "Dc1CvDfCCHN.jpg",
    "Dc1Ii5HACCq.jpg",
    "Dc1zxOZj248.jpg",
    "Dc2AwHAjPnJ.jpg",
    "Dc3Rd76kpf7.jpg",
    "Dc3eSgKCMLY.jpg",
    "Dc6AmbVDv2F.jpg",
    "Dc8hyesGhnv.jpg",
    "DcJF-bEid7L.jpg",
    "Dc_JVYmiG2t.jpg",
    "Dc_eq2fDZdm.jpg",
    "Dcd3fWfE0AE.jpg",
    "DcdUhJUE9Ky.jpg",
    "Dcgdf_NDEFv.jpg",
    "Dch7iOmGEa9.jpg",
    "Dci4PcCDYhi.jpg",
    "DcjDeOjAsNA.jpg",
    "DcndilxiGpk.jpg",
    "DcoHfK1jQ-_.jpg",
    "DcoKusglnkE.jpg",
    "Dcq1BSFjVTl.jpg",
    "DcqmIOfgKla.jpg",
    "DcqcD2ZDvwG.jpg",
    "DcqzI2gjCHu.jpg",
    "DcrCQ_IkZQQ.jpg",
    "DcsDAJ6m5eM.jpg",
    "Dct1-PyDNlc.jpg",
    "DcwQONqDNl2.jpg",
    "DcxVRBeGlk1.jpg",
    "DcxxVlpjC1R.jpg",
    "DdEepkZDQ5r.jpg",
    "DdEfRgwCOY1.jpg",
    "DdEox5TCPdp.jpg",
    "DdFQGzUiHAZ.jpg",
    "DdGA048Aaq-.jpg",
    "DdHG73WCAVo.jpg",
    "DdHgwvAiMAg.jpg",
    "DdK4-UdDS9q.jpg",
    "DdKK_HUDHz_.jpg",
    "DdMJA6mE7N0.jpg",
    "DdRRhFgjMbk.jpg",
}
MASCULINE_PHOTOS = {
    "Dc1JCcQDA_z.jpg",
    "Dc4HHTTiC2k.jpg",
    "Dc6Dfy6jSal.jpg",
    "Dc9ESRRiEmy.jpg",
    "Dcd74DACNcv.jpg",
    "DceQ5FngLl7.jpg",
    "Dcg3Zgll8lU.jpg",
    "DcgW36njHOh.jpg",
    "DcgzAm8kU1C.jpg",
    "Dclj5ZJjdeP.jpg",
    "DcrSpuuGj9s.jpg",
    "DctrZb7jKiH.jpg",
    "DcuIUt0EfAG.jpg",
    "DcuZZmSliO1.jpg",
    "Dcv_XcoEcIs.jpg",
    "DcwPyn2CBID.jpg",
    "DcyFYoOjbOm.jpg",
    "DdCc-najmV9.jpg",
    "DdEc_R6CNvg.jpg",
    "DdMUXVnkSru.jpg",
    "DdMdwL7jHdI.jpg",
    "DdOfuRCDPcb.jpg",
}
MIXED_PHOTOS = {"Dc1gwKBAUoO.jpg"}

FEMININE_VIDEOS = {
    "jlaw_DdHAY9TuvhK.mp4",
    "iiolumi_Dbdw4RkMD4p.mp4",
    "maredrame_DbVxqk-tNXZ.mp4",
    "twinsinparis__DaA_s5bI36i.mp4",
    "justinegotico__DbtMHu7pVzx.mp4",
    "mkaaloha_DcJhc7MRaoo.mp4",
    "lilyrowland1_DcG0k25qjc8.mp4",
    "nottrebeca__DdMmWWwOIS-.mp4",
    "paramorgan96_DcqwMphvRVE.mp4",
    "patagonico.k_DZ-bQGlOMaG.mp4",
}
MASCULINE_VIDEOS = {
    "gqitalia_DaySfwOOrRp.mp4",
    "reedmakesvideos_DcKQC1vPUpj.mp4",
    "alex_uspk_DaiGceLxTQc.mp4",
    "nathanroq_DZ7oSdpOS1h.mp4",
    "olliemuhl_DcwLo1KKA_L.mp4",
    "mitchfieldd_DcS11ETTQM6.mp4",
    "charliestringr_DcRs7ivyH2b.mp4",
    "anselmoprestini__Db-WhauBkuX.mp4",
    "danat_aliyev_DcHhsNJza4I.mp4",
}
SCENERY_VIDEOS = {
    "mmishkaa_DanbZxoRWOE.mp4",
    "sebastian_schieren_DaCxd9VMpZM.mp4",
    "scuba.earth_Dc58aMONTVM.mp4",
    "iamhippeel_DdNODifzki4.mp4",
    "thevillage.newyork_Dat9aT9Cwa6.mp4",
}


def photo_gender(name: str) -> str:
    if name in FEMININE_PHOTOS:
        return "feminine"
    if name in MASCULINE_PHOTOS:
        return "masculine"
    if name in MIXED_PHOTOS:
        return "mixed"
    raise AssertionError(f"Unclassified photograph: {name}")


def video_gender(name: str) -> str:
    if name in FEMININE_VIDEOS:
        return "feminine"
    if name in MASCULINE_VIDEOS:
        return "masculine"
    if name in SCENERY_VIDEOS:
        return "scenery"
    raise AssertionError(f"Unclassified video: {name}")


assert len({p["deskKey"] for p in people}) == len(people), "Repeated person ID"
photos = [manifest["localPortrait"]] + [p[role] for p in people for role in ("portrait", "cover")]
movies = [p["video"] for p in people if p["video"]]
assert len(photos) == len(set(photos)), "Photo assigned to multiple roles/people"
assert len(movies) == len(set(movies)), "Video assigned to multiple rooms"
assert set(movies) == {p.name for p in videos.glob("*.mp4")}, "Unused/missing video"
assert set(photos) | set(manifest["duplicateAliases"]) == {p.name for p in pics.glob("*.jpg")}, "Unused/missing photo"
assert photo_gender(manifest["localPortrait"]) == "feminine"
classified = FEMININE_PHOTOS | MASCULINE_PHOTOS | MIXED_PHOTOS
assert classified == {p.name for p in pics.glob("*.jpg")} - set(manifest["duplicateAliases"]), "Photo gender map drift"
assert FEMININE_VIDEOS | MASCULINE_VIDEOS | SCENERY_VIDEOS == {p.name for p in videos.glob("*.mp4")}, "Video gender map drift"

hashes = [hashlib.sha256((pics / photo).read_bytes()).hexdigest() for photo in photos]
assert len(hashes) == len(set(hashes)), "Duplicate visual content assigned"
for alias, canonical in manifest["duplicateAliases"].items():
    assert (pics / alias).read_bytes() == (pics / canonical).read_bytes(), "Alias is not a duplicate"

for person in people:
    portrait_g = photo_gender(person["portrait"])
    cover_g = photo_gender(person["cover"])
    presentation = person["presentation"]
    if presentation in ("feminine", "masculine"):
        assert portrait_g == presentation, f"{person['deskKey']} portrait is {portrait_g}"
        assert cover_g == presentation, f"{person['deskKey']} cover is {cover_g}"
    else:
        assert presentation == "mixed", f"Unknown presentation: {person['deskKey']}"
        assert cover_g == "mixed", f"{person['deskKey']} mixed host needs a mixed cover"
    if person["video"]:
        clip_g = video_gender(person["video"])
        assert person["videoPresentation"] == clip_g, f"{person['deskKey']} videoPresentation != clip"
        if presentation == "feminine":
            assert clip_g in ("feminine", "scenery"), f"Feminine host with masculine live clip: {person['deskKey']}"
        elif presentation == "masculine":
            assert clip_g in ("masculine", "scenery"), f"Masculine host with feminine live clip: {person['deskKey']}"
        else:
            assert clip_g == "scenery", f"Mixed host with gendered live clip: {person['deskKey']}"
        assert (videos / person["video"]).is_file()

print(
    f"PASS: {len(people)} people; {len(photos)} unique photos; {len(movies)} unique room videos; "
    f"{len(manifest['duplicateAliases'])} identical-file aliases."
)
print("Every source is accounted for. Portrait, cover, and live clip stay on one gender.")
