"""Odtwórz voice/kwestie.json z tekstów gry i sprawdź pokrycie plików MP3."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT / "iphone"
SCRIPTS = GAME / "scripts"
VOICE = ROOT / "voice"
EFFECTS = {"chime", "wood_tap", "swoosh", "story/water_drop", "story/camp_rustle",
           "story/fork_snore", "story/dawn_laugh"}
UNKNOWN = "do ustalenia"


def source(name):
    return (SCRIPTS / (name + ".gd")).read_text(encoding="utf-8")


def dictionary(script, name):
    body = re.search(rf"^const {name} := (\{{.*?^\}})", source(script), re.M | re.S)
    return json.loads(re.sub(r",\s*}", "}", body[1]))


# Reżyseria głosu dla kwestii fabularnych. Polecenia interfejsu czyta narrator.
CAST = {
    "bóbr": "door wait night_bridge",
    "Tobo": "stable stable_alt stable_ok stable_ok_alt travel_apples tobo stable_home stable_thanks stable_thanks_alt",
    "herszt": "chief chief_alt chief_happy sad_loss sad_give sad_next sad_question sad_retry sad_hint sad_thanks sad_thanks_alt",
    "Wiewiórka": "invitation delivery thanks",
    "mali hobbici": "range dummy",
    "Gapa": "dawn_caught dawn_cones dawn_cones_alt",
    "Burczyk": "dawn_accept dawn_rocks dawn_rocks_alt dawn_skewer dawn_skewer_alt dawn_sausages",
    "Chrapek": "dawn_sun",
    "Bilbo": "dawn_bet",
    "mama smoczyca": "nest_count nest_ask nest_retry nest_hug dragon_flight",
    "Iskierka": "dragon_lost dragon_near dragon_fire dragon_warm dragon_share dragon_less dragon_hint dragon_full mountain_coal mountain_cold mountain_warm",
    UNKNOWN: "homecoming dawn_dishes dawn_argue_rocks dawn_argue_rocks_alt dawn_argue_food dawn_argue_food_alt dawn_argue_cones dawn_argue_cones_alt",
}


def route_speaker(key):
    for role, names in CAST.items():
        if key in names.split():
            return role
    if key.startswith("sad_"): return "herszt"
    if key.startswith("mole_"):
        return "kret"
    if key.startswith("whisper_") or key in {
        "cave_palms", "cave_boots", "cave_hooves", "cave_together", "cave_final", "cave_last"
    }:
        return "Szeptek"
    return "narrator"


def catalog():
    lines = {}

    def record(key, role, words):
        lines[key] = {"plik": f"audio/{key}.mp3", "postać": role, "tekst": words}

    for key, words in dictionary("river_story_data", "WORDS").items():
        record("story/route_" + key, route_speaker(key), words)
    for key, words in dictionary("troll_camp", "WORDS").items():
        role = "Gapa" if key in {"count", "turn", "caught", "caught_again"} else "Tobo"
        if key in {"pony", "follow"}:
            role = "narrator"
        record("story/camp_" + key, role, words)
    for key, words in dictionary("riverbank", "LINES").items():
        role = "Wiewiórka" if key in {"scoop", "crack", "pour", "stir", "flip"} else "narrator"
        record("story/bank_" + key, role, words)
    for key, words in dictionary("field_encounter", "GUIDE").items():
        record("story/enc_" + key, "narrator", words)
    for script in ("riverbank", "field_encounter"):
        for key, words in re.findall(r'(?:prompt|instruction)\.emit\("([^"]+)","([^"]+)"\)', source(script)):
            record("story/" + key, "narrator", words)
    for words, key in re.findall(r'prompt\("([^"]+)","(beaver_[^"]+)"\)', source("bridge_repair")):
        record(key, "bóbr", words)
    words = ["Jeden", "Dwa", "Trzy", "Cztery", "Pięć", "Sześć", "Siedem", "Osiem", "Dziewięć"]
    for i, word in enumerate(words, start=1):
        record(f"count_{i}", "narrator", word)
        if 5 <= i <= 8:
            record(f"story/nail_{i}", "narrator", word)
    for words, key in re.findall(r'objective=="([^"]+)": play_clip\(narrator,"([^"]+)"\)', source("valley")):
        record(key, "narrator", words)
    for key, entry in json.loads((VOICE / "kwestie_dodatkowe.json").read_text()).items():
        record(key, entry["postać"], entry["tekst"])
    files = {p.relative_to(GAME / "audio").with_suffix("").as_posix()
             for p in (GAME / "audio").rglob("*.mp3")}
    missing = files - lines.keys() - EFFECTS
    if missing:
        raise ValueError(f"Nowe MP3 do rozpoznania: {sorted(missing)}")
    return [lines[key] for key in sorted(files & lines.keys())]


if __name__ == "__main__":
    (VOICE / "kwestie.json").write_text(json.dumps(catalog(), ensure_ascii=False, indent=2) + "\n")
