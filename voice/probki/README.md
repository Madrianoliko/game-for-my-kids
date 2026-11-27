# Próbki głosów

Z katalogu repozytorium uruchom `python3 tools/generuj_glosy.py --probki`. Program pobiera klucz z OPENAI_API_KEY i zapisuje ukończone próbki w tym katalogu. Możesz ograniczyć odsłuch do jednej postaci, np. przez `--probki --postac Gapa`.

Katalog kwestii odtworzysz poleceniem `python3 tools/lista_kwestii.py`. W kolejnym zadaniu opcje `--wszystko` i samo `--postac` zapisują nagrania do iphone/audio.

Każdą parę kwestii czytają dwa głosy syntetyczne. Po odsłuchu wpisz wybór postaci w docs/UWAGI_Z_TESTOW.md.

Teksty dla Pestki i dodatkowe zdania dla Tygryska, Chrapka i Bilba służą do odsłuchu.

- narrator · marin (oczekuje) — Wstaw kamień w schody tam, gdzie pasuje liczba kropek.
- narrator · marin (oczekuje) — Wieczorem, po przyjęciu…
- narrator · cedar (oczekuje) — Wstaw kamień w schody tam, gdzie pasuje liczba kropek.
- narrator · cedar (oczekuje) — Wieczorem, po przyjęciu…
- bóbr · cedar (oczekuje) — Bilbo, to ja, bóbr! Woda porwała deski z mostu. Pestka czeka na drugim brzegu. Pomożesz mi go naprawić?
- bóbr · cedar (oczekuje) — Twoje deski trzymają się świetnie, Bilbo! Uważaj w lesie!
- bóbr · fable (oczekuje) — Bilbo, to ja, bóbr! Woda porwała deski z mostu. Pestka czeka na drugim brzegu. Pomożesz mi go naprawić?
- bóbr · fable (oczekuje) — Twoje deski trzymają się świetnie, Bilbo! Uważaj w lesie!
- Tobo · ash (oczekuje) — Bilbo! Miałem pięć kucyków. Dwa są tutaj. Ile zniknęło?
- Tobo · ash (oczekuje) — Weź jabłka na drogę.
- Tobo · sage (oczekuje) — Bilbo! Miałem pięć kucyków. Dwa są tutaj. Ile zniknęło?
- Tobo · sage (oczekuje) — Weź jabłka na drogę.
- herszt · onyx (oczekuje) — Dość pojedynku! Przepuszczę was, jeśli policzycie moje jabłka. Dwa tutaj i jeszcze jedno. Ile razem?
- herszt · onyx (oczekuje) — Moje jabłka! Bilbo, jesteś najdzielniejszym hobbitem w dolinie!
- herszt · echo (oczekuje) — Dość pojedynku! Przepuszczę was, jeśli policzycie moje jabłka. Dwa tutaj i jeszcze jedno. Ile razem?
- herszt · echo (oczekuje) — Moje jabłka! Bilbo, jesteś najdzielniejszym hobbitem w dolinie!
- Wiewiórka · coral (oczekuje) — Jesteś, Bilbo! Podejdź do mojego stołu i podaj mi składniki dłonią.
- Wiewiórka · coral (oczekuje) — Trzy woreczki mąki, dwa jajka i mleko! Dziękuję! Teraz upieczemy tort dla Tygryska.
- Wiewiórka · nova (oczekuje) — Jesteś, Bilbo! Podejdź do mojego stołu i podaj mi składniki dłonią.
- Wiewiórka · nova (oczekuje) — Trzy woreczki mąki, dwa jajka i mleko! Dziękuję! Teraz upieczemy tort dla Tygryska.
- Tygrysek · verse (oczekuje) — Dziękuję za mój urodzinowy tort, Bilbo!
- Tygrysek · verse (oczekuje) — Ale piękny tort! To naprawdę dla mnie?
- Tygrysek · shimmer (oczekuje) — Dziękuję za mój urodzinowy tort, Bilbo!
- Tygrysek · shimmer (oczekuje) — Ale piękny tort! To naprawdę dla mnie?
- mali hobbici · nova (oczekuje) — Bilbo! Ale masz super łuk! Pokaż nam, jak strzelasz!
- mali hobbici · nova (oczekuje) — A pokażesz nam swój miecz? Podejdź do słomianych kukieł i spróbuj je ściąć.
- mali hobbici · verse (oczekuje) — Bilbo! Ale masz super łuk! Pokaż nam, jak strzelasz!
- mali hobbici · verse (oczekuje) — A pokażesz nam swój miecz? Podejdź do słomianych kukieł i spróbuj je ściąć.
- Gapa · onyx (oczekuje) — Hmm? Kto tu łazi?
- Gapa · onyx (oczekuje) — Aha! Widzę cię! Wracaj do stogu!
- Gapa · ballad (oczekuje) — Hmm? Kto tu łazi?
- Gapa · ballad (oczekuje) — Aha! Widzę cię! Wracaj do stogu!
- Burczyk · cedar (oczekuje) — Ja mam dwa kamyki, Chrapek ma dwa. Ile razem?
- Burczyk · cedar (oczekuje) — Na patyku są cztery kiełbaski. Mniam!
- Burczyk · ash (oczekuje) — Ja mam dwa kamyki, Chrapek ma dwa. Ile razem?
- Burczyk · ash (oczekuje) — Na patyku są cztery kiełbaski. Mniam!
- Chrapek · ballad (oczekuje) — Chrrr… co? Słońce?! O nie…
- Chrapek · ballad (oczekuje) — Jeszcze chwilkę… Dopiero co zasnąłem.
- Chrapek · onyx (oczekuje) — Chrrr… co? Słońce?! O nie…
- Chrapek · onyx (oczekuje) — Jeszcze chwilkę… Dopiero co zasnąłem.
- Iskierka · shimmer (oczekuje) — Chlip… Zgubiłam się. Moja mama mieszka na górze, tam, gdzie dym.
- Iskierka · shimmer (oczekuje) — Apsik! Świeci! Aż zgłodniałam.
- Iskierka · nova (oczekuje) — Chlip… Zgubiłam się. Moja mama mieszka na górze, tam, gdzie dym.
- Iskierka · nova (oczekuje) — Apsik! Świeci! Aż zgłodniałam.
- mama smoczyca · marin (oczekuje) — Mam pięcioro dzieci, a w gnieździe są cztery. Kogo brakuje?
- mama smoczyca · marin (oczekuje) — Jednego! Iskierko, moje maleństwo!
- mama smoczyca · sage (oczekuje) — Mam pięcioro dzieci, a w gnieździe są cztery. Kogo brakuje?
- mama smoczyca · sage (oczekuje) — Jednego! Iskierko, moje maleństwo!
- kret · fable (oczekuje) — Kto zapali moje świeczki, ten przejdzie. Trzy na torcie, dwie na półce!
- kret · fable (oczekuje) — Apsik! Ojej, moja czapka!
- kret · echo (oczekuje) — Kto zapali moje świeczki, ten przejdzie. Trzy na torcie, dwie na półce!
- kret · echo (oczekuje) — Apsik! Ojej, moja czapka!
- Szeptek · ash (oczekuje) — Ciii… Kto tu chodzi z latarką? Teraz to moja latarka! Hi, hi.
- Szeptek · ash (oczekuje) — Wygrałeś… Masz latarkę. Ale wróć kiedyś!
- Szeptek · fable (oczekuje) — Ciii… Kto tu chodzi z latarką? Teraz to moja latarka! Hi, hi.
- Szeptek · fable (oczekuje) — Wygrałeś… Masz latarkę. Ale wróć kiedyś!
- Pestka · coral (oczekuje) — Bilbo! Teraz mogę przejść na drugi brzeg!
- Pestka · coral (oczekuje) — Ale miękka grzywa! Mogę pogłaskać kucyka?
- Pestka · shimmer (oczekuje) — Bilbo! Teraz mogę przejść na drugi brzeg!
- Pestka · shimmer (oczekuje) — Ale miękka grzywa! Mogę pogłaskać kucyka?
- Bilbo · verse (oczekuje) — Założę się, że nie umiecie liczyć!
- Bilbo · verse (oczekuje) — Chodź, Iskierko. Znajdziemy twoją mamę.
- Bilbo · cedar (oczekuje) — Założę się, że nie umiecie liczyć!
- Bilbo · cedar (oczekuje) — Chodź, Iskierko. Znajdziemy twoją mamę.
