# Mały Odkrywca — kolejka zadań dla Codexa

Ten plik jest listą pracy na wiele sesji. Codex za każdym razem bierze **pierwsze zadanie ze statusem `[ ]`**, wykonuje je, oznacza jako `[x]` i dopisuje raport do `docs/RAPORTY.md`.

Plany fabuły, z których korzystają zadania:
- `docs/ROZDZIAL_2_TROLLE.md` — rozdział 2,
- `docs/PLAN_PRZYGOD.md` — rozdziały 3–5 i zasady dobrej zagadki.

---

## Zasady ogólne (obowiązują w każdym zadaniu)

1. **Uwagi z testów mają pierwszeństwo.** Zanim zaczniesz zadanie, przeczytaj `docs/UWAGI_Z_TESTOW.md`. Jeśli są tam nowe wpisy (bez dopisku „uwzględnione”), najpierw je wprowadź w osobnym commicie i dopisz przy nich „uwzględnione (data, commit)”.
2. **Jedno zadanie na sesję.** Nie zaczynaj następnego zadania z kolejki.
3. **Zapisy gry muszą działać.** Zapis pamięta nazwę kroku ROUTE (`route`), więc nowe kroki można wstawiać w dowolne miejsce trasy. Nie zmieniaj nazw istniejących kroków i nie usuwaj ich. Każde zadanie, które zmienia ROUTE, dodaje test wczytania zapisu z kroku sprzed zmiany.
4. **Dziecko ma 5 lat i nie czyta.** Każde polecenie jest wypowiadane polskim głosem (Zosia, tą samą metodą co dotąd) i ma przycisk „Posłuchaj”. Jedna kwestia prosi o jedną czynność. Przyciski mają obrazki zamiast napisów.
5. **Zasady zagadek** z `docs/PLAN_PRZYGOD.md`, część 1: odpowiedź zmienia świat, liczone przedmioty widać i można ich dotknąć, pomyłka pokazuje skutek, po dwóch pomyłkach jest pomoc, przyciski z liczbami mają kropki, a poprawna odpowiedź stoi na losowej pozycji.
6. **Zakres matematyki:** liczenie do 15, dodawanie i odejmowanie do 10, w dodawaniu składniki mniejsze niż 8.
7. **Pomyłka nigdy nie karze.** Nie ma żyć, punktów ujemnych ani cofania postępu. Po złapaniu lub pomyłce dziecko od razu próbuje jeszcze raz.
8. **Testy:** po każdym zadaniu wszystkie testy w `tests/` muszą przechodzić na wyeksportowanym `xcode/MalyOdkrywca.pck` (preset „iPhone”). Nowa scena dostaje własny test albo rozszerzenie `tests/river_story_flow.gd`. Testy uruchamiaj z `--fixed-fps 60`, żeby szły szybko.
9. **Commity:** osobny commit na każdy etap, opis po polsku. Na koniec zadania: eksport `.pck`, testy, commit i `git push`.
10. **Kiedy nie wiesz — zatrzymaj się.** Jeśli coś jest niejasne, sprzeczne z planem albo testy nie przechodzą i nie wiesz dlaczego, nie zgaduj. Zapisz pytanie w `docs/RAPORTY.md` pod nagłówkiem „PYTANIE”, zostaw zadanie jako `[ ]` i zakończ sesję.
11. **Raport** w `docs/RAPORTY.md` (najnowszy na górze): numer zadania, co zrobiono, co pominięto i dlaczego, nowe kroki ROUTE, wartości do strojenia, wyniki testów, brakujące nagrania, rozmiar `.pck`. Maksymalnie 15 linijek.

---

## Kolejka

### [ ] Z00 — Porządek w dokumentach
- Dodaj do repozytorium katalog `docs/` (plany i stare zlecenia są nieśledzone).
- Utwórz puste pliki `docs/RAPORTY.md` i `docs/UWAGI_Z_TESTOW.md` (w tym drugim krótka instrukcja: „Wpisz, co zauważyłeś podczas gry z synem. Codex uwzględni to przed następnym zadaniem.”).
- Przenieś stare zlecenia `ZLECENIE_CODEX_01–04.md` do `docs/archiwum/`.
- Commit i push. Bez zmian w grze.

### [ ] Z01 — Rozdział 2: nocny most i herszt bez jabłek
Plan: `ROZDZIAL_2_TROLLE.md`, sceny 3 i 4. Wstaw między `stable` a `camp`.
- Krok `night_bridge`: Bilbo z Tobem idą wieczorem przez most z rozdziału 1 (ten sam most, przyciemniony filtr jak przy latarenkach). Bóbr macha z wody: „Twoje deski trzymają się świetnie, Bilbo! Uważaj w lesie!”. Dziecko samo przeprowadza Bilba.
- Krok `chief_sad`: na trakcie siedzi herszt orków z pustym koszem. Bilbo ma w plecaku 3 jabłka (dostaje je od Toba w stajni: „Weź jabłka na drogę.”). Herszt: „Trolle zabrały mi wszystkie jabłka!”. Zagadka: „Mam pusty kosz. Dasz mi jabłka? Ile ich masz?” — dziecko podaje jabłka dłonią po jednym, gra liczy na głos, potem herszt pyta „Ile mi dałeś?” (przyciski z kropkami). Herszt: „Trolle siedzą przy ognisku, za lasem. Uważaj na Gapę!”.
- Zapis po każdym kroku, test przejścia i test wznowienia.

### [ ] Z02 — Rozdział 2: wybór drogi
Plan: scena 5. Wstaw między `chief_sad` a `camp`.
- Krok `fork`: rozwidlenie z dwiema widocznymi ścieżkami. Dziecko wybiera, idąc w jedną z nich.
- Droga krótka: śpiący troll Chrapek leży przy ścieżce i głośno chrapie. Gdy Bilbo podejdzie za blisko (widoczny krąg na ziemi), Chrapek przewraca się na drugi bok, mruczy i Bilbo wraca kilka kroków. Trzeba obejść krąg. To rozgrzewka przed obozem.
- Droga długa: strumień przechodzi się po kamieniach (wykorzystaj mechanikę kamieni z rozdziału 1).
- Obie drogi kończą się na skraju obozu. Zapis pamięta wybraną drogę.

### [ ] Z03 — Rozdział 2: kłótnia trolli do świtu
Plan: scena 7. Wstaw po `camp`, przed `stable_home`.
- Po uratowaniu trzeciego kucyka obóz się nie kończy. Gapa „łapie” Bilba (scena, nie porażka), budzą się Burczyk i Chrapek. Trolle są śmieszne, nie straszne.
- Bilbo: „Założę się, że nie umiecie liczyć!”. Trzy zagadki z przedmiotami widocznymi na ekranie: 2 + 2 kamyki, 4 kiełbaski minus 1 zjedzona na oczach dziecka, 3 + 3 szyszki. Przyciski z kropkami.
- Po każdej dobrej odpowiedzi trolle się kłócą, a niebo jaśnieje o jeden stopień (widoczna zmiana). Po złej trolle się śmieją, niebo się nie zmienia.
- Po trzeciej: wschód słońca, trolle zastygają w śmiesznych pozach i zamieniają się w kamień („chrup… chrup… chrup”).
- Kwestie z planu (sekcja „Kwestie” przy scenie 7).

### [ ] Z04 — Rozdział 2: jaskinia trolli i powrót przez trakt
Plan: sceny 8 i 9.
- Krok `troll_cave`: dziecko otwiera skrzynię dłonią. W środku jabłka herszta i zwinięta mapa z górą, nad którą unosi się dymek. Mapa trafia do plecaka (będzie potrzebna w rozdziale 3).
- Krok `chief_happy` przed `stable_home`: Bilbo z kucykami spotyka herszta na trakcie i oddaje mu jabłka dłonią. „Moje jabłka! Bilbo, jesteś najdzielniejszym hobbitem w dolinie!”.
- Kucyki przechodzą przez most po kolei, a gra liczy je na głos (1, 2, 3).
- Kamienne trolle zostają na wzgórzu jako nowy punkt na mapie doliny.

### [ ] Z05 — Pomoc po dwóch pomyłkach (cała gra)
Plan: `PLAN_PRZYGOD.md`, zasady 3 i 4.
- Wspólny mechanizm dla wszystkich zagadek z przyciskami (herszt, latarenki, deski, stajnia, herszt bez jabłek, trolle): po dwóch złych odpowiedziach przedmioty, które trzeba policzyć, zapalają się po kolei, a głos liczy razem z dzieckiem („jeden… dwa… trzy…”). Potem zostają podświetlone do czasu dobrej odpowiedzi.
- Tam, gdzie to łatwe, pomyłka pokazuje skutek: przy latarenkach zapala się tyle latarenek, ile dziecko wybrało, i widać, że część stoi ciemna; przy deskach za mało desek zostawia widoczną lukę.
- Test: dwie złe odpowiedzi włączają pomoc, a dobra odpowiedź ją wyłącza.

### [ ] Z06 — Inne liczby przy każdym przejściu
Plan: zasada 7.
- W każdej zagadce liczby losują się z bezpiecznego zakresu przy każdym nowym przejściu (np. latarenki 1–4 po każdej stronie, w stajni zniknęło 2–3 kucyków, u trolli różne pary). Wynik zapisuje się w zapisie gry, żeby wznowienie pokazywało te same liczby.
- Kwestie z liczbami nagraj w wariantach (np. „Dwie latarenki z lewej, trzy z prawej” w każdej potrzebnej kombinacji) albo złóż z krótkich nagrań („z lewej” + „dwie”…). Wybierz sposób, który brzmi naturalnie, i opisz go w raporcie.
- Liczby wypowiadane w fabule, które muszą zostać stałe (np. „osiem gwoździ”), zostaw bez zmian i wypisz je w raporcie.
- Test: dwa przejścia z różnym ziarnem losowania dają różne liczby, a wznowienie zachowuje te same.

### [ ] Z07 — Rozdział 3, część 1: Iskierka i głodny smoczek
Plan: `PLAN_PRZYGOD.md`, rozdział 3. Nowe kroki po `stable_home`. Rozdział 3 dostaje przycisk w menu (obrazek smoczka) po ukończeniu rozdziału 2.
- Otwarcie: Bilbo w chatce rozwija mapę z plecaka. Rano w sadzie przypalone ogryzki pod jabłonią. W krzakach płacze mała smoczyca Iskierka: „Chlip… Zgubiłam się. Moja mama mieszka na górze, tam, gdzie dym.”.
- Nowa mechanika: Iskierka idzie za Bilbem (jak kucyk) i „kicha” ogniem po dotknięciu przycisku z płomykiem. Kichnięcie zapala rzeczy w zasięgu.
- Zagadka „Głodny smoczek”: 6 jagód, dziecko przeciąga je na dwa listki, aż na obu jest tyle samo. Gdy jest równo, Iskierka mruczy, a jej płomyk jaśnieje. Gdy nierówno, smutna mina i wskazanie listka, na którym jest mniej.
- Test całego fragmentu i odblokowania przycisku rozdziału 3.

### [ ] Z08 — Rozdział 3, część 2: droga na górę
Plan: rozdział 3, zagadki 2 i 3, wybór drogi.
- Wybór drogi u stóp góry: strumień po kamieniach albo krzaki jeżyn, które Iskierka wypala kichnięciem.
- Kamienne stopnie: schody z kropkami 1–8, trzy stopnie leżą obok. Dziecko wkłada je w luki. Pasujący zapala się na złoto, a niepasujący się chwieje.
- Ciepła jaskinia: dwie kupki węgielków, „Na której jest więcej?”. Kichnięcie w większą daje duże ognisko, w mniejszą mały płomyczek i drżącą Iskierkę.

### [ ] Z09 — Rozdział 3, część 3: kret, mama smoczyca i lot
Plan: rozdział 3, zagadki 4 i 5, nagroda.
- Kret pustelnik i świeczki: 3 na torcie + 2 na półce, każde kichnięcie zapala jedną. Za mało zostawia zgaszoną świeczkę, za dużo przypala kretowi czapkę (śmiesznie, bez kary).
- Mama smoczyca: „Mam pięcioro dzieci, a w gnieździe są cztery. Kogo brakuje?”. Po odpowiedzi mama obejmuje Iskierkę skrzydłem.
- Nagroda: lot na plecach mamy smoczycy nad doliną (prosta animacja kamery nad mapą z młynem, mostem i kamiennymi trollami). Mama: „Wracajcie przez jaskinie, tam jest krócej. Tylko uważajcie na Szeptka…”. Koniec rozdziału 3.

### [ ] Z10 — Rozdział 4, część 1: Szeptek i liczenie dźwięków
Plan: rozdział 4. Przycisk w menu (obrazek kryształu) po ukończeniu rozdziału 3.
- Jaskinia z kryształami, Szeptek zabiera latarkę: „Ciii… Kto tu chodzi z latarką? Teraz to moja latarka! Hi, hi.”.
- Nowa mechanika: liczenie dźwięków. Ekran ciemnieje, słychać kapnięcia, a przy każdym na sekundę zapala się kryształ. Dziecko odpowiada przyciskami z kropkami. Po dwóch pomyłkach kryształy zostają zapalone.
- Trzy tunele w dowolnej kolejności. W tym zadaniu zbuduj tunel z kroplami (3, potem 5 kropli) i układ trzech wejść. Pozostałe tunele mogą być na razie zamknięte kamieniem.
- Każda wygrana zapala na stałe wielki kryształ na ścianie.

### [ ] Z11 — Rozdział 4, część 2: drzwi, rybki i palce Szeptka
Plan: rozdział 4, zagadki 2–5.
- Tunel z kryształowymi drzwiami (wzór czerwony-niebieski, potem duży-mały-mały).
- Tunel z rybkami: 6 rybek, 2 odpływają, „Ile zostało?”.
- Po trzech tunelach: palce Szeptka (3 + 3) i wielka zagadka o nogach Bilba i kucyka (2 + 4).
- Finał: Szeptek oddaje latarkę: „Wygrałeś… Masz latarkę. Ale wróć kiedyś!”. Koniec rozdziału 4.

### [ ] Z12 — Rozdział 5, część 1: śnieżyca i wóz z drewnem
Plan: rozdział 5. Przycisk w menu (obrazek płatka śniegu) po ukończeniu rozdziału 4.
- Dolina w śniegu (biała tekstura terenu, padające płatki). Bóbr: „Idzie śnieżyca! Domy nie mają drewna na zimę!”.
- Nowa mechanika: kucyk Toba ciągnie wóz za Bilbem. Na wozie widać 10 miejsc jak w ramce do liczenia. Polana przeciąga się palcem ze stosu na wóz.
- Zagadka „Pełny wóz”: na wozie leży 7 polan, „Ile jeszcze się zmieści?”. Za dużo i ostatnie spada w śnieg z „bęc”.

### [ ] Z13 — Rozdział 5, część 2: rozwożenie i finał
Plan: rozdział 5, zagadki 1, 3, 4 i finał.
- Każdy dom potrzebuje tyle polan, ile ma okien (okna świecą i można ich dotknąć). Dziecko samo wybiera kolejność domów. Po dowiezieniu z komina leci dym. Gdy na wozie brakuje polan, Bilbo wraca na plac.
- Sanki: trzech małych hobbitów w szalikach różnych kolorów zjeżdża z górki, a dziecko ustawia ich na mecie w kolejności przyjazdu.
- Bitwa na śnieżki: łuk strzela śnieżkami, tarcza je odbija.
- Finał przy ognisku z wszystkimi postaciami całej wyprawy. Tobo liczy gości razem z dzieckiem. Koniec przygody.

### [ ] Z14 — Menu rozdziałów i szlify
- Menu pokazuje odblokowane rozdziały jako 5 obrazków (most, troll, smoczek, kryształ, płatek śniegu). Zablokowane są szare z kłódką.
- „Wznów” zawsze wraca do ostatniego miejsca zapisu.
- Przejrzyj wszystkie kwestie: żadna nie może mieć więcej niż jednego polecenia ani być dłuższa niż ok. 6 sekund.
- Sprawdź płynność na iPhonie 12 (renderer Mobile): jeśli któraś scena ma dużo obiektów, uprość ją. Wypisz w raporcie sceny, które warto sprawdzić na telefonie.
