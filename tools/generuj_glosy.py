"""Generowanie nagrań na Macu. Sama gra odtwarza lokalne pliki MP3."""
import argparse
import fcntl
import hashlib
import http.client
import json
import os
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VOICE = ROOT / "voice"
MODEL = "gpt-4o-mini-tts"


def speech(payload, key):
    connection = http.client.HTTPSConnection("api.openai.com", timeout=90)
    try:
        connection.request("POST", "/v1/audio/speech", json.dumps(payload).encode(),
                           {"Authorization": "Bearer " + key, "Content-Type": "application/json"})
        result = connection.getresponse()
        if result.status != 200:
            raise RuntimeError(f"OpenAI Speech zwrócił HTTP {result.status}.")
        audio = result.read()
        if not (audio.startswith(b"ID3") or (len(audio) > 2 and audio[0] == 255 and audio[1] & 224 == 224)):
            raise RuntimeError("Odpowiedź nie zawiera nagrania MP3.")
        return audio
    finally:
        connection.close()


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def atomic_write(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as handle:
        tmp = Path(handle.name)
        try:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        except BaseException:
            tmp.unlink(missing_ok=True)
            raise
    try:
        tmp.replace(path)
    finally:
        tmp.unlink(missing_ok=True)


def sample_jobs(profiles):
    for role, profile in profiles.items():
        for variant in profile["warianty"]:
            for i, words in enumerate(profile["probki"], 1):
                name = f"{role.replace(' ', '_')}_{variant}_{i}.mp3"
                yield role, variant, words, VOICE / "probki" / name


def game_jobs(profiles):
    for line in read_json(VOICE / "kwestie.json"):
        role = line["postać"]
        if role not in profiles or not line["tekst"]:
            print("Do ustalenia:", line["plik"], file=sys.stderr)
            continue
        yield role, profiles[role]["glos"], line["tekst"], ROOT / "iphone" / line["plik"]


def index_samples(profiles):
    lines = ["# Próbki głosów", "",
             "Z katalogu repozytorium uruchom `python3 tools/generuj_glosy.py --probki`. "
             "Program pobiera klucz z OPENAI_API_KEY i zapisuje ukończone próbki w tym katalogu. "
             "Możesz ograniczyć odsłuch do jednej postaci, np. przez `--probki --postac Gapa`.", "",
             "Katalog kwestii odtworzysz poleceniem `python3 tools/lista_kwestii.py`. "
             "W kolejnym zadaniu opcje `--wszystko` i samo `--postac` zapisują nagrania do iphone/audio.", "", "Każdą parę kwestii czytają dwa głosy syntetyczne. "
             "Po odsłuchu wpisz wybór postaci w docs/UWAGI_Z_TESTOW.md.", "",
             "Teksty dla Pestki i dodatkowe zdania dla Tygryska, Chrapka i Bilba służą do odsłuchu.", ""]
    for role, variant, words, path in sample_jobs(profiles):
        label = f"{role} · {variant}"
        item = f"[{label}]({path.name})" if path.exists() else f"{label} (oczekuje)"
        lines.append(f"- {item} — {words}")
    atomic_write(VOICE / "probki/README.md", ("\n".join(lines) + "\n").encode())


def generate(jobs, profiles, key):
    manifest_path = VOICE / "manifest.json"
    manifest = read_json(manifest_path) if manifest_path.exists() else {}
    for role, variant, words, path in jobs:
        payload = dict(model=MODEL, input=words, voice=variant, response_format="mp3",
                       instructions=profiles[role]["instrukcja"])
        digest = hashlib.sha256(json.dumps(payload, sort_keys=True).encode()).hexdigest()
        rel = path.relative_to(ROOT).as_posix()
        saved = manifest.get(rel, {})
        if saved.get("request") == digest and path.is_file():
            if saved.get("mp3") == hashlib.sha256(path.read_bytes()).hexdigest():
                continue
        audio = speech(payload, key)
        atomic_write(path, audio)
        manifest[rel] = {"request": digest, "mp3": hashlib.sha256(audio).hexdigest()}
        atomic_write(manifest_path, (json.dumps(manifest, indent=2, sort_keys=True) + "\n").encode())
        print(rel)


def main():
    profiles = read_json(VOICE / "postacie.json")
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument("--probki", action="store_true", help="Dwa głosy na dwóch kwestiach każdej postaci")
    modes.add_argument("--wszystko", action="store_true", help="Nagrania gry ze wszystkich przypisanych kwestii")
    parser.add_argument("--postac", choices=list(profiles), help="Ogranicz generowanie do jednej postaci")
    args = parser.parse_args()
    if not (args.probki or args.wszystko or args.postac):
        parser.error("Wybierz --probki, --postac lub --wszystko.")
    key = os.environ.get("OPENAI_API_KEY")
    if not key:
        parser.exit(1, "Brak OPENAI_API_KEY w środowisku procesu.\n")
    jobs = sample_jobs(profiles) if args.probki else game_jobs(profiles)
    with (VOICE / "manifest.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        try:
            generate((job for job in jobs if not args.postac or job[0] == args.postac), profiles, key)
        finally:
            if args.probki:
                index_samples(profiles)


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, http.client.HTTPException) as error:
        sys.exit(str(error))
