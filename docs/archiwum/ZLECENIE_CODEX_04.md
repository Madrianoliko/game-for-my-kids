Pracujesz w repozytorium „Mały Odkrywca” (Godot 4.7.2, iphone/). Plan fabuły jest w docs/ROZDZIAL_2_TROLLE.md i docs/PLAN_PRZYGOD.md. Przeczytaj oba, zanim zaczniesz.

W tym zleceniu: (1) usuwasz starą „Wyprawę Leo”, (2) dodajesz kropki na przyciskach z liczbami, (3) łączysz obóz trolli z główną przygodą Bilba jako rozdział 2.

ZASADY
- Każde zadanie zapisz w osobnym commicie z opisem po polsku. Po każdym zadaniu uruchom wszystkie testy z tests/.
- Zapisy gier z rozdziału 1 muszą dalej działać. Nowe kroki dopisuj NA KOŃCU ROUTE i nie zmieniaj nazw ani kolejności istniejących kroków.
- Nie ruszaj światów Hot Wheels i Harry Potter.
- Jeśli coś jest niejasne, nie zgaduj. Wpisz to do raportu.

ZADANIE 1: usuń „Wyprawę Leo”
Stara trasa to tryb uruchamiany przez atlas.classic_requested → start() w valley.gd (lis, sad, placek, quiz z odpowiedziami, fox_intro, stany WALK i kolejne etapy, VOICE_CLIPS, gwiazdki `best`).
- Usuń przycisk tej trasy z menu (atlas.gd) i cały kod używany tylko przez nią.
- UWAGA, NIE USUWAJ tego, czego używa trasa Bilba w river_story.gd i troll_camp.gd: modelu art/leo.glb (to model Bilba), zmiennej `leo` i ruchu postaci, `stick`, kamery, krajobrazu (valley.glb, shadery), `narrator`, `chime`, `play_clip`, `button`, `plate`, `say` (jeśli używane przez inne skrypty), pauzy i menu pauzy, bridge_repair.gd ani nagrań w audio/ używanych przez inne skrypty (np. count_1–count_4 przez bridge_repair.gd). Każde usunięcie potwierdź grepem.
- Zmiennej `leo` NIE przemianowuj w tym zleceniu.
- Komunikat pauzy „Leo poczeka tutaj.” zmień na „Bilbo poczeka tutaj.”.
- Gwiazdki `best` (rekord starej trasy): usuń je z menu i z zapisu, jeśli nic poza starą trasą ich nie używa.
- Usuń nagrania z audio/ (z plikami .import), które po usunięciu trasy nie są nigdzie używane. Listę wpisz w opis commita.
- tests/valley_flow.gd testuje starą trasę. Przepisz go tak, żeby sprawdzał menu: start bez zapisu, rozpoczęcie przygody Bilba, wyjście do menu i „Wznów”.
- Zaktualizuj README: usuń opis „Wyprawy Leo” i polecenie `python3 -m http.server` dla wersji przeglądarkowej, jeśli dotyczy już tylko starej trasy. Opisz rozdziały 1 i 2.

ZADANIE 2: kropki na przyciskach z liczbami
Pięciolatek nie zawsze zna cyfry. W river_icons.gd w funkcji apply przycisk z liczbą pokazuje dziś tylko tekst.
- Pod cyfrą narysuj tyle kropek, ile wynosi liczba, w układzie jak na kostce lub w ramce po 5 (np. 7 = rząd 5 + rząd 2). Przycisk może być trochę wyższy, ale wszystkie przyciski w rzędzie muszą mieć ten sam rozmiar.
- Dotyczy to wszystkich zagadek: herszta, desek, latarenek i nowej zagadki w stajni z zadania 3.

ZADANIE 3: rozdział 2 w głównej przygodzie
Obóz trolli przestaje być próbą i staje się częścią trasy Bilba po urodzinach Tygryska.

3a. Przejście z rozdziału 1
- Po scenie „homecoming” historia się nie kończy. Ekran przygasa, pojawia się napis i głos: „Wieczorem, po przyjęciu…”, a Bilbo stoi na placu wioski przed nową stajnią Toba.
- Stajnia to nowy budynek o stałym miejscu przy placu, z podkową nad drzwiami. Ma wyglądać inaczej niż młyn, kurnik i obora.
- W rozdziale 1 ukończenie zapisuje się jako „rozdział 1 ukończony”.

3b. Puste boksy (nowy krok ROUTE, np. „stable”)
- Tobo przy stajni. Widać 5 boksów: w 2 stoją kucyki, 3 są puste. Nad wzgórzem w oddali unosi się dym.
- Dziecko dotyka pustych boksów, a gra liczy na głos (nagrania count_1–count_3 albo nowe). Potem odpowiada przyciskami z kropkami na pytanie Toba (poprawna pozycja losowa, jak w pozostałych zagadkach).
- Po dobrej odpowiedzi Tobo pokazuje dym, a potem rozmowa przechodzi w krok obozu.
Kwestie:
- stable: „Bilbo! Miałem pięć kucyków. Dwa są tutaj. Ile zniknęło?”
- stable_ok: „Trzy! Widzisz ten dym na wzgórzu? Troll Gapa ukradł moje kucyki!”
- stable_go: „Chodź, uratujemy je!”

3c. Obóz trolli (nowy krok ROUTE, np. „camp”)
- Wykorzystaj troll_camp.gd, ze stogami i wprowadzeniem bez zmian zasad. Wprowadzenie dopasuj do fabuły: Tobo mówi już „ukradł moje kucyki” (liczba mnoga).
- Teraz są TRZY kucyki w różnych miejscach, a dziecko samo wybiera kolejność:
  - kucyk 1 przy drzewie z boku ścieżki, mniej więcej na wysokości 3. stogu (najłatwiejszy),
  - kucyk 2 przy wozie po drugiej stronie, mniej więcej na wysokości 5. stogu,
  - kucyk 3 przy ognisku Gapy, czyli obecne miejsce (najtrudniejszy).
  Dostaw stogi przy kucykach 1 i 2 tak, żeby do każdego dało się dojść z chowaniem się.
- Każdego kucyka odprowadza się do Toba osobno. Przy Tobie widać rosnącą gromadkę uratowanych kucyków. Postęp zapisuje się po każdym kucyku, więc po wyjściu z gry „Wznów” wraca do obozu z już uratowanymi kucykami przy Tobie.
- Kwestie po każdym kucyku: „Jeden kucyk jest już u mnie! Zostały jeszcze dwa.”, „Dwa kucyki! Został jeszcze jeden.”, a po trzecim „done”.
- Po trzecim kucyku ekran przygasa i następuje krok powrotu.

3d. Powrót do stajni (nowy krok ROUTE, np. „stable_home”)
- Wszystkie 5 kucyków stoi w boksach. Tobo: „Wszystkie w domu! Policzmy je razem.” Dziecko dotyka boksów, a gra liczy do 5.
- Potem Tobo: „Dziękuję, Bilbo! Jesteś najdzielniejszym hobbitem w dolinie!”. Pojawia się gwiazdka i koniec rozdziału 2 („rozdział 2 ukończony” w zapisie), a gra wraca do menu.
- Herszta, nocnego mostu i kłótni trolli do świtu z planu NIE buduj teraz. Zostaw kod tak, żeby te sceny dało się później wstawić między „stable” a „camp” oraz między „camp” a „stable_home”.

3e. Menu
- Usuń przycisk „Obóz trolli (próba)”.
- Po ukończeniu rozdziału 1 w menu pojawia się drugi przycisk przygody z obrazkiem trolla („Rozdział 2”), który zaczyna od kroku „stable”. Przycisk mostu zaczyna od początku jak dotąd. „Wznów” wraca do miejsca zapisu w dowolnym rozdziale. Przyciski mają obrazki, bo dziecko nie czyta.

TESTY
- tests/river_story_flow.gd: wydłuż o rozdział 2. Po homecoming → stable (zła odpowiedź odrzucona, dobra przechodzi dalej) → camp (trzy kucyki w dowolnej kolejności, w tym jeden test z inną kolejnością) → stable_home → zapis „rozdział 2 ukończony”.
- tests/troll_camp_flow.gd: dostosuj do trzech kucyków i sprawdź wznowienie po uratowaniu jednego.
- tests/valley_flow.gd: nowy test menu z zadania 1.
- Dodaj test, że zapis z rozdziału 1 sprzed tej zmiany (np. na kroku „mill”) wczytuje się poprawnie.

NA KONIEC
- Wyeksportuj xcode/MalyOdkrywca.pck presetem iPhone, uruchom wszystkie testy na pakiecie i zrób commit.
- Raport: co usunąłeś (kod i pliki), rozmiar .pck przed i po zmianach, rozstawienie kucyków i nowych stogów, nowe kroki ROUTE, wyniki testów, brakujące nagrania i wszystko, czego nie zrobiłeś, z uzasadnieniem.
