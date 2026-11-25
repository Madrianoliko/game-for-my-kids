# Zlecenie dla Codexa nr 1 — porządki w rozdziale 1 (przed rozdziałem 2)

Kontekst: Mały Odkrywca, Godot 4.7.2, projekt `iphone/`. Główna fabuła to trasa Bilba w `scripts/river_story.gd` i `scripts/river_story_data.gd` (ROUTE). Nie zmieniaj przebiegu fabuły. Po każdym zadaniu uruchom `tests/river_story_flow.gd` i `tests/valley_flow.gd` w sposób opisany w README. Każde zadanie zapisz jako osobny commit z czytelnym opisem.

## Zadanie 1 — Poprawna odpowiedź nie może zawsze stać w środku (WAŻNE)
Obecnie w każdej zagadce poprawna odpowiedź jest zawsze środkowym przyciskiem:
- herszt: `river_story.gd`, `for n in [2,3,4]`, odpowiedź 3,
- latarenki: `river_story.gd`, `for n in [4,5,6]`, odpowiedź 5,
- deski: `bridge_repair.gd`, `for n in [2,3,4]`, odpowiedź 3.

Pięciolatek szybko nauczy się klikać środkowy przycisk zamiast liczyć. Test także na tym polega (`options.get_child(1)`).

**Do zrobienia:**
- Dodaj wspólną funkcję, która dla odpowiedzi `a` tworzy trzy kolejne liczby, w których `a` stoi losowo na pozycji 1, 2 lub 3: `[a-k, ..., a-k+2]`, gdzie `k` to 0, 1 lub 2. Żadna liczba nie może być mniejsza od 1. Przyciski zostają w kolejności rosnącej, bo pomaga to dziecku.
- Użyj tej funkcji w trzech miejscach wymienionych wyżej.
- Zmień testy tak, żeby szukały przycisku po tekście, a nie po pozycji. Test powinien też sprawdzić, że w 30 losowaniach poprawna odpowiedź pojawia się na każdej pozycji.

## Zadanie 2 — Usuń martwe wątki wycofane z fabuły
Te wątki nie występują w `ROUTE`, ale ich kod i nagrania wciąż są w projekcie. Zwiększają `.pck` (z 3,4 MB do 11 MB) i mylą przy dalszej pracy. Przed usunięciem każdego elementu potwierdź wyszukiwaniem, że nic z ROUTE go nie używa.
- `riverbank.gd`: etapy `duck`, `tracks`, `fork`, `crank`, `rope`, `flour`, `snack`, `feast` wraz z kwestiami w `LINES` (kaczka, kocyk, korba, pływak, zastawka, baran, Tkacz, placek), a także postacie `duck`, `reeds` i `blanket`, jeśli są używane tylko przez te etapy.
- `mill_mechanism.gd`, jeśli służy tylko etapom `crank` i `flour`.
- `field_encounter.gd`: zostaw tylko sekwencję `pine`, która jest używana na strzelnicy. Usuń `orc1`–`hit3`, `solve`, `spool`, `ram` i `bell` razem z ich tekstami.
- `river_props.gd`: usuń postacie `ram` i `badger`, jeśli nic ich nie używa. **Zostaw `troll`**, bo przyda się w rozdziale 2.
- `river_icons.gd`: usuń ikony Kaczka i Kocyk oraz mapowania związane z kaczką i kocykiem.
- `audio/story/`: usuń pliki mp3 (wraz z `.import`), do których nie odwołuje się żaden kod. Zrób to skryptem i wypisz listę usuniętych plików w opisie commita.
- **Nie zmieniaj nazw kroków ROUTE**, na przykład `blanket`, i nie ruszaj migracji zapisu w `read_save()`. Zmiana nazw zepsułaby zapisane gry.

## Zadanie 3 — Krótsze polecenia (jedno polecenie naraz)
Dziecko nie czyta, więc jedna kwestia powinna zawierać jedną czynność. Rozdziel te kwestie na kroki odtwarzane jeden po drugim, a następną część włączaj dopiero po wykonaniu poprzedniej czynności:
- `range`: „Pokaż nam, jak strzelasz!” → (po wyjęciu łuku) „Naciągnij cięciwę i puść!”
- `guard`: „Ork zastąpił drogę! Osłoń się tarczą.” → (po pierwszym bloku) „Teraz obejdź go z boku.” → (gdy bok jest odsłonięty) „Teraz! Dotknij miecza!”
- `invitation`: zostaw zaproszenie. Po nim dodaj w plecaku widoczną listę z trzema obrazkami: worek mąki, jajko i dzbanek mleka. Każdy obrazek dostaje ptaszek po zdobyciu składnika.

Nowe nagrania przygotuj tak samo jak dotychczasowe klipy w `audio/story/` (prefiks `route_`).

## Zadanie 4 — Eksport
Po zakończeniu zadań wyeksportuj `xcode/MalyOdkrywca.pck` presetem iPhone. Uruchom testy na pakiecie i zrób commit.
