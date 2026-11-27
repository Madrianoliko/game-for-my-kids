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
12. **Kolejka ma pierwszeństwo przed planem.** Jeśli opis zadania w kolejce różni się od planu fabuły w `docs/`, rób według kolejki, a w raporcie zapisz, czym się różniły. Pytaj tylko wtedy, gdy kolejka sama jest niejasna albo sprzeczna.
13. **Drobne decyzje podejmuj sam.** Jeśli zadanie zostawia wybór, który nie zmienia celu rozdziału (np. jak dopasować liczby, kwestie albo rozstawienie do losowania), wybierz wariant, który daje dziecku więcej liczenia i nie skraca zabawy, i opisz decyzję w raporcie. Zatrzymuj się z pytaniem tylko przy sprzecznościach, których nie da się pogodzić, albo przy zmianach, które usuwają lub skracają istniejącą scenę.
14. **Liczenie dotykiem zawsze widać.** Każdy dotknięty przedmiot, który się liczy, lekko się podświetla i pokazuje nad sobą kolejną cyfrę (1, 2, 3…). Zielony oznacza „jest”, czerwony „brakuje / puste”. Dotyczy to wszystkich obecnych i przyszłych zagadek.
15. **Zebrane rzeczy trafiają do paska plecaka.** Podniesiony przedmiot znika ze sceny, a jego obrazek pojawia się w pasku po lewej stronie ekranu. Gra nie wyprowadza Bilba sama. Gracz sam idzie do drzwi albo dalej.
16. **Chodzenie zamiast przeskoków.** Sceny łączy chodzenie gałką między oddalonymi miejscami. Przejścia między rozdziałami są krótkimi scenkami filmowymi z narratorem, a historia płynie dalej bez wracania do menu. Menu i „Wznów” wracają do ostatniego momentu.

---

## Kolejka

### [x] Z00 — Porządek w dokumentach (2026-11-25)
- Dodaj do repozytorium katalog `docs/` (plany i stare zlecenia są nieśledzone).
- Utwórz puste pliki `docs/RAPORTY.md` i `docs/UWAGI_Z_TESTOW.md` (w tym drugim krótka instrukcja: „Wpisz, co zauważyłeś podczas gry z synem. Codex uwzględni to przed następnym zadaniem.”).
- Przenieś stare zlecenia `ZLECENIE_CODEX_01–04.md` do `docs/archiwum/`.
- Commit i push. Bez zmian w grze.

### [x] Z01 — Rozdział 2: nocny most i herszt bez jabłek (2026-11-25)
Plan: `ROZDZIAL_2_TROLLE.md`, sceny 3 i 4. Wstaw między `stable` a `camp`.
- Krok `night_bridge`: Bilbo z Tobem idą wieczorem przez most z rozdziału 1 (ten sam most, przyciemniony filtr jak przy latarenkach). Bóbr macha z wody: „Twoje deski trzymają się świetnie, Bilbo! Uważaj w lesie!”. Dziecko samo przeprowadza Bilba.
- Krok `chief_sad`: na trakcie siedzi herszt orków z pustym koszem. Bilbo ma w plecaku 3 jabłka (dostaje je od Toba w stajni: „Weź jabłka na drogę.”). Herszt: „Trolle zabrały mi wszystkie jabłka!”. Zagadka: „Mam pusty kosz. Dasz mi jabłka? Ile ich masz?” — dziecko podaje jabłka dłonią po jednym, gra liczy na głos, potem herszt pyta „Ile mi dałeś?” (przyciski z kropkami). Herszt: „Trolle siedzą przy ognisku, za lasem. Uważaj na Gapę!”.
- Zapis po każdym kroku, test przejścia i test wznowienia.

### [x] Z02 — Rozdział 2: wybór drogi (2026-11-25)
Plan: scena 5. Wstaw między `chief_sad` a `camp`.
- Krok `fork`: rozwidlenie z dwiema widocznymi ścieżkami. Dziecko wybiera, idąc w jedną z nich.
- Droga krótka: śpiący troll Chrapek leży przy ścieżce i głośno chrapie. Gdy Bilbo podejdzie za blisko (widoczny krąg na ziemi), Chrapek przewraca się na drugi bok, mruczy i Bilbo wraca kilka kroków. Trzeba obejść krąg. To rozgrzewka przed obozem.
- Droga długa: strumień przechodzi się po kamieniach (wykorzystaj mechanikę kamieni z rozdziału 1).
- Obie drogi kończą się na skraju obozu. Zapis pamięta wybraną drogę.

### [x] Z03 — Rozdział 2: kłótnia trolli do świtu (2026-11-25)
Plan: scena 7. Wstaw po `camp`, przed `stable_home`.
- Po uratowaniu trzeciego kucyka obóz się nie kończy. Gapa „łapie” Bilba (scena, nie porażka), budzą się Burczyk i Chrapek. Trolle są śmieszne, nie straszne.
- Bilbo: „Założę się, że nie umiecie liczyć!”. Trzy zagadki z przedmiotami widocznymi na ekranie: 2 + 2 kamyki, 4 kiełbaski minus 1 zjedzona na oczach dziecka, 3 + 3 szyszki. Przyciski z kropkami.
- Po każdej dobrej odpowiedzi trolle się kłócą, a niebo jaśnieje o jeden stopień (widoczna zmiana). Po złej trolle się śmieją, niebo się nie zmienia.
- Po trzeciej: wschód słońca, trolle zastygają w śmiesznych pozach i zamieniają się w kamień („chrup… chrup… chrup”).
- Kwestie z planu (sekcja „Kwestie” przy scenie 7).

### [x] Z04 — Rozdział 2: jaskinia trolli i powrót przez trakt (2026-11-25)
Plan: sceny 8 i 9.
- Krok `troll_cave`: dziecko otwiera skrzynię dłonią. W środku jabłka herszta i zwinięta mapa z górą, nad którą unosi się dymek. Mapa trafia do plecaka (będzie potrzebna w rozdziale 3).
- Krok `chief_happy` przed `stable_home`: Bilbo z kucykami spotyka herszta na trakcie i oddaje mu jabłka dłonią. „Moje jabłka! Bilbo, jesteś najdzielniejszym hobbitem w dolinie!”.
- Kucyki przechodzą przez most po kolei, a gra liczy je na głos (1, 2, 3).
- Kamienne trolle zostają na wzgórzu jako nowy punkt na mapie doliny.

### [x] Z05 — Pomoc po dwóch pomyłkach (cała gra) (2026-11-26)
Plan: `PLAN_PRZYGOD.md`, zasady 3 i 4.
- Wspólny mechanizm dla wszystkich zagadek z przyciskami (herszt, latarenki, deski, stajnia, herszt bez jabłek, trolle): po dwóch złych odpowiedziach przedmioty, które trzeba policzyć, zapalają się po kolei, a głos liczy razem z dzieckiem („jeden… dwa… trzy…”). Potem zostają podświetlone do czasu dobrej odpowiedzi.
- Tam, gdzie to łatwe, pomyłka pokazuje skutek: przy latarenkach zapala się tyle latarenek, ile dziecko wybrało, i widać, że część stoi ciemna; przy deskach za mało desek zostawia widoczną lukę.
- Test: dwie złe odpowiedzi włączają pomoc, a dobra odpowiedź ją wyłącza.

### [x] Z06 — Inne liczby przy każdym przejściu (2026-11-26)
Plan: zasada 7.
- W każdej zagadce liczby losują się z bezpiecznego zakresu przy każdym nowym przejściu (np. latarenki 1–4 po każdej stronie, w stajni zniknęło 2–3 kucyków, u trolli różne pary). Wynik zapisuje się w zapisie gry, żeby wznowienie pokazywało te same liczby.
- Kwestie z liczbami nagraj w wariantach (np. „Dwie latarenki z lewej, trzy z prawej” w każdej potrzebnej kombinacji) albo złóż z krótkich nagrań („z lewej” + „dwie”…). Wybierz sposób, który brzmi naturalnie, i opisz go w raporcie.
- Liczby wypowiadane w fabule, które muszą zostać stałe (np. „osiem gwoździ”), zostaw bez zmian i wypisz je w raporcie.
- Test: dwa przejścia z różnym ziarnem losowania dają różne liczby, a wznowienie zachowuje te same.

### [x] Z07 — Rozdział 3, część 1: Iskierka i głodny smoczek (2026-11-26)
Plan: `PLAN_PRZYGOD.md`, rozdział 3. Nowe kroki po `stable_home`. Rozdział 3 dostaje przycisk w menu (obrazek smoczka) po ukończeniu rozdziału 2.
- Otwarcie: Bilbo w chatce rozwija mapę z plecaka. Rano w sadzie przypalone ogryzki pod jabłonią. W krzakach płacze mała smoczyca Iskierka: „Chlip… Zgubiłam się. Moja mama mieszka na górze, tam, gdzie dym.”.
- Nowa mechanika: Iskierka idzie za Bilbem (jak kucyk) i „kicha” ogniem po dotknięciu przycisku z płomykiem. Kichnięcie zapala rzeczy w zasięgu.
- Zagadka „Głodny smoczek”: 6 jagód, dziecko przeciąga je na dwa listki, aż na obu jest tyle samo. Gdy jest równo, Iskierka mruczy, a jej płomyk jaśnieje. Gdy nierówno, smutna mina i wskazanie listka, na którym jest mniej.
- Test całego fragmentu i odblokowania przycisku rozdziału 3.

### [x] Z08 — Rozdział 3, część 2: droga na górę (2026-11-26)
Plan: rozdział 3, zagadki 2 i 3, wybór drogi.
- Wybór drogi u stóp góry: strumień po kamieniach albo krzaki jeżyn, które Iskierka wypala kichnięciem.
- Kamienne stopnie: schody z kropkami 1–8, trzy stopnie leżą obok. Dziecko wkłada je w luki. Pasujący zapala się na złoto, a niepasujący się chwieje.
- Ciepła jaskinia: dwie kupki węgielków, „Na której jest więcej?”. Kichnięcie w większą daje duże ognisko, w mniejszą mały płomyczek i drżącą Iskierkę.

### [x] Z09 — Rozdział 3, część 3: kret, mama smoczyca i lot (2026-11-26)
Plan: rozdział 3, zagadki 4 i 5, nagroda.
- Kret pustelnik i świeczki: 3 na torcie + 2 na półce, każde kichnięcie zapala jedną. Za mało zostawia zgaszoną świeczkę, za dużo przypala kretowi czapkę (śmiesznie, bez kary).
- Mama smoczyca: „Mam pięcioro dzieci, a w gnieździe są cztery. Kogo brakuje?”. Po odpowiedzi mama obejmuje Iskierkę skrzydłem.
- Nagroda: lot na plecach mamy smoczycy nad doliną (prosta animacja kamery nad mapą z młynem, mostem i kamiennymi trollami). Mama: „Wracajcie przez jaskinie, tam jest krócej. Tylko uważajcie na Szeptka…”. Koniec rozdziału 3.

### [x] Z10 — Rozdział 4, część 1: Szeptek i liczenie dźwięków (2026-11-27)
Plan: rozdział 4. Przycisk w menu (obrazek kryształu) po ukończeniu rozdziału 3.
- Jaskinia z kryształami, Szeptek zabiera latarkę: „Ciii… Kto tu chodzi z latarką? Teraz to moja latarka! Hi, hi.”.
- Nowa mechanika: liczenie dźwięków. Ekran ciemnieje, słychać kapnięcia, a przy każdym na sekundę zapala się kryształ. Dziecko odpowiada przyciskami z kropkami. Po dwóch pomyłkach kryształy zostają zapalone.
- Trzy tunele w dowolnej kolejności. W tym zadaniu zbuduj tunel z kroplami (3, potem 5 kropli) i układ trzech wejść. Pozostałe tunele mogą być na razie zamknięte kamieniem.
- Każda wygrana zapala na stałe wielki kryształ na ścianie.

### [x] Z11 — Rozdział 4, część 2: drzwi, rybki i palce Szeptka (2026-11-27)
Plan: rozdział 4, zagadki 2–5.
- Tunel z kryształowymi drzwiami (wzór czerwony-niebieski, potem duży-mały-mały).
- Tunel z rybkami: 6 rybek, 2 odpływają, „Ile zostało?”.
- Po trzech tunelach: palce Szeptka (3 + 3) i wielka zagadka o nogach Bilba i kucyka (2 + 4).
- Finał: Szeptek oddaje latarkę: „Wygrałeś… Masz latarkę. Ale wróć kiedyś!”. Koniec rozdziału 4.

### [x] G01 — Głosy z OpenAI: lista kwestii i próbki do odsłuchu (2026-11-27)
Cel: zastąpić systemowy głos Zosi naturalnymi głosami postaci z OpenAI. Gra dalej odtwarza gotowe pliki mp3 z pakietu i NIGDY nie łączy się z API w trakcie gry.
- **Lista kwestii:** utwórz `voice/kwestie.csv` (albo `.json`) ze wszystkimi kwestiami w grze: plik mp3 (ścieżka jak dziś, np. `audio/story/route_door.mp3`), postać, tekst. Wygeneruj ją skryptem z kodu (słowniki WORDS, LINES, GUIDE itd.), żeby nic nie umknęło. Wypisz w raporcie kwestie, których nie dało się przypisać do postaci.
- **Postacie i ich opis głosu** w `voice/postacie.json`: narrator, bóbr, Tobo, herszt, Wiewiórka, Tygrysek, mali hobbici, Gapa, Burczyk, Chrapek, Iskierka, mama smoczyca, kret, Szeptek, Pestka. Każda postać ma głos OpenAI i krótką instrukcję po polsku (np. Gapa: „niski, powolny, dobroduszny troll, trochę głupkowaty, nie straszny”; Iskierka: „mała, wesoła smoczyca, wysoki głos”; narrator: „ciepły głos opowiadacza bajek dla pięciolatka, wyraźnie i spokojnie”). Wszystkie mówią po polsku, wyraźnie i niezbyt szybko.
- **Skrypt** `tools/generuj_glosy.py`: czyta listę i postacie, wysyła tekst do OpenAI Speech API (model w jednym ustawieniu na górze skryptu, dziś `gpt-4o-mini-tts`), zapisuje mp3 i pamięta skrót (hash) tekstu, głosu i instrukcji w `voice/manifest.json`. Przy ponownym uruchomieniu generuje tylko zmienione albo nowe kwestie. Opcje: `--probki` (tylko próbki), `--postac X`, `--wszystko`. Klucz bierze WYŁĄCZNIE ze zmiennej środowiskowej `OPENAI_API_KEY`. Klucza nigdy nie zapisuj w repozytorium ani w pakiecie gry. Dodaj do `.gitignore` pliki, w których mógłby się znaleźć.
- **Próbki:** dla każdej postaci wygeneruj 2–3 warianty głosu (różne głosy OpenAI) na 2 jej typowych kwestiach do `voice/probki/<postać>_<głos>_N.mp3`, plus `voice/probki/README.md` z listą do odsłuchu. NIE podmieniaj jeszcze nagrań w grze.
- Jeśli brakuje `OPENAI_API_KEY`, przygotuj listę, postacie i skrypt, zapisz PYTANIE z prośbą o klucz i zakończ.
- Uwaga: modele `/v1/audio/speech` mają zostać wyłączone 6 stycznia 2027. Skrypt ma pozwalać łatwo zmienić model albo dostawcę w jednym miejscu.

### [x] U01 — Uwagi z testu: wspólne mechanizmy (uwagi 2, 6, 7, 8, 11, 22, 31) (2026-11-27)
Szczegóły w `docs/UWAGI_Z_TESTOW.md` (test z 2026-11-27).
- **Pasek plecaka (zasada 15):** po lewej stronie ekranu pasek z obrazkami zebranych rzeczy. Wiaderko z mlekiem, worki mąki i jajka po podniesieniu dłonią znikają ze sceny i pojawiają się w pasku. Gracz sam wychodzi z budynku. Lista składników Wiewiórki może być częścią tego paska.
- **Drzwi:** po wyjściu z budynku Bilbo staje kawałek przed drzwiami, a drzwi nie reagują na dłoń, dopóki Bilbo nie odejdzie od nich i nie podejdzie ponownie. Nie może się zdarzyć, że wychodzi i od razu wchodzi z powrotem.
- **Pauza:** duże przyciski z samymi obrazkami (wznów, dźwięk, domek-menu, wyjście), co najmniej tak duże jak przyciski akcji. Bez polegania na napisach.
- **Liczenie dotykiem (zasada 14):** wspólny mechanizm podświetlenia i cyfry nad przedmiotem. Puste boksy w stajni na czerwono, boksy z kucykami po powrocie na zielono, smoczątka w gnieździe z numerkiem. Wprowadź go we wszystkich istniejących zagadkach z liczeniem dotykiem.
- Testy: wyjście z obory nie wraca od razu do środka, przedmiot po podniesieniu jest w pasku i znika ze sceny, cyfry pojawiają się po kolei.

### [x] U02 — Uwagi z testu: początek rozdziału 1 (uwagi 1, 3, 4, 5) (2026-11-27)
- **Wstęp:** przed chatką krótka scenka filmowa: kamera przelatuje nad doliną (most, młyn, wioska) i zatrzymuje się przy chatce Bilba. Narrator (2–3 krótkie zdania): kim jest Bilbo (mały hobbit z Doliny), że lubi przygody i liczenie, i że dziś ktoś puka do drzwi. Przy kolejnych przejściach można ją pominąć dużym przyciskiem ze strzałką.
- **Bóbr:** usuń pytanie z kciukiem w górę/w dół i ścieżkę odmowy. Bóbr mówi: „Proszę, Bilbo, pomóż mi! Woda zniszczyła most. Weź narzędzia i chodź za mną.” Dalej pakowanie jak dotąd. Starsze zapisy z krokiem odmowy mają się wczytać normalnie.
- **Pakowanie:** rozłóż przedmioty w chatce tak, żeby żaden nie zasłaniał innego z perspektywy kamery (minimalny odstęp, sprawdzony testem pozycji).
- **Po wyjściu z chatki:** narrator: „Gdy Bilbo wyszedł z chatki, podbiegły do niego dzieci.” Potem kwestie dzieci (postać „mali hobbici”).

### [x] U03 — Uwagi z testu: urodziny, stajnia i herszt (uwagi 10, 12, 13, 14) (2026-11-27)
- **Urodziny:** po ostatniej warstwie tortu krótka scenka: Wiewiórka gasi światło, wchodzi Tygrysek, wszyscy wołają „Niespodzianka!”, zapalają się świeczki, a dopiero potem „Sto lat”.
- **Dym:** przenieś dym z ogniska trolli dużo dalej, na wzgórze za mostem, żeby nie wyglądał jak ognisko za stodołą.
- **Jabłka na drogę:** w stajni stoi koszyk jabłek. Tobo mówi „Weź jabłka na drogę”, Bilbo podchodzi do koszyka i bierze je dłonią (trafiają do paska plecaka).
- **Herszt:** w koszu herszta leżą już jabłka (losowo 1–3, widoczne). Bilbo ma przy sobie 3–6 jabłek (losowo, razem w koszu najwyżej 9) i podaje je po jednym z liczeniem na głos. Pytania: „Ile mi dałeś?”, a potem „Ile teraz mam w koszu?”. Przy drugim pytaniu można dotknąć jabłek w koszu (zasada 14). Kwestie w wariantach liczb.

### [ ] U04 — Uwagi z testu: przebudowa obozu trolli (uwagi 15, 16, 17, 18)
- **Rozwidlenie:** usuń drogę obok chrapiącego Chrapka. Krok `fork` zostaje, ale prowadzi tylko przez strumień po kamieniach. Zapisy z wybraną drogą obok Chrapka wznawiają się na drodze przez strumień.
- **Pole:** usuń wydeptaną ścieżkę między stogami. Stogi ustaw w polu mniej więcej w kwadrat (np. siatka 3×3 lub podobna), kucyki przy krawędziach pola.
- **Nowa zasada patrolu (zastępuje liczenie i „Hmm”):** Gapa nie stoi w miejscu i nie liczy. Chodzi powoli po polu wokół stogów i między nimi po stałej trasie (np. po kwadracie) z latarnią. Przed nim na ziemi widać przezroczysty pomarańczowy stożek wzroku. Kto jest poza stogiem w stożku, zostaje złapany (łagodnie, jak dotąd). Za plecami Gapy i poza stożkiem można spokojnie biegać. Tempo patrolu dobierz tak, żeby między stogami było średnio ok. 5 sekund bezpiecznego biegu. Prędkość, długość stożka i kąt jako stałe do strojenia.
- Wprowadzenie Toba zmień na: „To Gapa. Widzisz to światło przed nim? Tam, gdzie świeci, on widzi. Chowaj się w stogach, kiedy idzie w twoją stronę!”. Nauka w pierwszym stogu zostaje.
- Testy: złapanie w stożku, bezpieczny bieg za plecami Gapy, stóg chroni w stożku, ratunek wszystkich kucyków przy patrolu.

### [ ] U05 — Uwagi z testu: kłótnia trolli, szyszki, mapa i przejście do rozdziału 3 (uwagi 19, 20, 21, 23)
- **Kłótnia:** po każdej odpowiedzi trolle wyraźnie się kłócą: stają naprzeciw siebie, machają łapami, mówią jeden po drugim (np. Burczyk: „Cztery!” — Chrapek: „Nieprawda, pięć!” — Gapa: „Cicho! Bilbo ma rację!”). Ma być jasne i śmieszne, że to sprzeczka.
- **Szyszki:** Gapa trzyma szyszki na otwartych, wyciągniętych na boki łapach, szyszki są większe i wyraźnie rozdzielone. Po dotknięciu pojawia się cyfra (zasada 14).
- **Mapa:** po wyjęciu ze skrzyni mapa rozwija się na cały ekran: dolina, most, dymiąca góra i znak X. Bilbo: „Hmm… Tam może być coś ciekawego.” Dotknięcie zwija mapę do paska plecaka.
- **Przejście do rozdziału 3:** po policzeniu kucyków w stajni nie wracaj do menu. Scenka: wieczór, Bilbo w chatce zasypia z mapą, rano narrator zaczyna rozdział 3. Gra płynie dalej, a zapis i „Wznów” wracają do ostatniego momentu. To samo zrób na końcu rozdziału 3 (przejście do rozdziału 4) i 4 (do rozdziału 5 albo na razie do napisu „Ciąg dalszy nastąpi”). Przyciski rozdziałów w menu zostają do powtórek.

### [ ] U06 — Uwagi z testu: rozdział 3 (uwagi 24, 25, 26, 28, 29, 30, 31, 32)
- **Ślad łapek:** droga od sadu do Iskierki ma trwać co najmniej ok. 10 sekund marszu, ślady widoczne na ziemi.
- **Latarnia:** usuń niezrozumiałe ikonki (dwa ogniska i głośnik). Bilbo idzie za Iskierką do latarni. Iskierka wyjaśnia: „Patrz! Umiem kichać ogniem!”, pokazuje kichnięcie, a potem: „Dotknij płomyka, a ja kichnę.” Przycisk z płomykiem pojawia się dopiero wtedy, z delikatnym pulsowaniem.
- **Więcej chodzenia:** sad, krzaki, latarnia i jagody są oddalone od siebie i połączone chodzeniem gałką (zasada 16).
- **Droga na górę:** bez wyboru. Najpierw strumień po kamieniach, potem dalej w prawo krzak jeżyn do wypalenia, potem schody.
- **Schody:** po ułożeniu stopni Bilbo sam wchodzi po nich gałką do jaskini.
- **Świeczki kreta:** jest 5 świeczek, część już się pali (losowo, np. 1. i 3.). Pytanie: „Ile razy musi kichnąć Iskierka, żeby paliło się wszystkie pięć?”. Przyciski z kropkami. Dobra odpowiedź: Iskierka kicha tyle razy, a świeczki zapalają się po kolei z liczeniem. Pomyłki jak dotąd (za mało: jedna zostaje zgaszona, za dużo: przypalona czapka).
- **Gniazdo:** dotknięte smoczątko lekko się podświetla i ma numerek (zasada 14). Pytanie: „Ile dzieci brakuje?” z przyciskami z kropkami (losowo: 1 lub 2 brakujące, mama mówi, ile ma dzieci razem).

### [ ] G02 — Głosy z OpenAI: podmiana nagrań w grze
Zaczynaj dopiero, gdy w `docs/UWAGI_Z_TESTOW.md` jest wybór głosów z próbek (np. „Gapa: onyx, Iskierka: shimmer…”). Jeśli wyboru jeszcze nie ma, pomiń to zadanie (zostaw je jako `[ ]`) i weź następne zadanie z kolejki. Wróć do G02, gdy wybór się pojawi.
- Ustaw wybrane głosy w `voice/postacie.json` i wygeneruj wszystkie kwestie (`--wszystko`) pod tymi samymi nazwami plików, więc kod gry się nie zmienia.
- Odsłuchaj automatycznie długość plików: żaden nie może być pusty ani wyraźnie dłuższy niż poprzednia wersja (np. ponad 2 razy). Odstępstwa wypisz w raporcie.
- Stare nagrania Zosi zachowaj w gałęzi albo w `voice/zosia_backup/` poza pakietem gry, żeby dało się wrócić.
- Do zasady 4 dopisz: nowe kwestie generuje się skryptem `tools/generuj_glosy.py` głosem przypisanej postaci.
- Eksport, testy, raport z rozmiarem `.pck` i liczbą wygenerowanych kwestii.

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
- Losowanie liczb (zasada 7) także w rozdziałach 3–5, tam gdzie zostały stałe: brakujące kamienne stopnie (dziś zawsze 5, 2 i 7), kupki węgielków (dziś 2 i 5, różnica może się zmniejszać przy kolejnych przejściach, np. 4 i 5), świeczki kreta, liczby u Szeptka i na wozie.
- Sprawdź płynność na iPhonie 12 (renderer Mobile): jeśli któraś scena ma dużo obiektów, uprość ją. Wypisz w raporcie sceny, które warto sprawdzić na telefonie.
