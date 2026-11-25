Pracujesz w repozytorium „Mały Odkrywca” (gra 3D na iPhone’a dla pięciolatka, Godot 4.7.2, GDScript, projekt w iphone/). Rozdział 1 (trasa Bilba w river_story.gd / ROUTE) jest skończony i przetestowany. Teraz budujemy PIERWSZY WYCINEK rozdziału 2. Pełny plan rozdziału jest w docs/ROZDZIAL_2_TROLLE.md (scena 6). Przeczytaj go przed rozpoczęciem pracy.

CEL WYCINKA: „Obóz trolli — pierwszy kucyk”
Bilbo w nocy skrada się przez obóz trolli, uwalnia jednego kucyka i przyprowadza go do Toba. Wycinek ma sprawdzić z dzieckiem jedną nową mechanikę: „Troll patrzy” (jak w zabawie „Raz, dwa, trzy, Baba Jaga patrzy”).

ZASADY
- NIE zmieniaj ROUTE, zapisu gry ani przebiegu rozdziału 1. Wycinek to osobna scena w nowym pliku iphone/scripts/troll_camp.gd. Nie zapisuje postępu.
- Wejście do wycinka: nowy przycisk w menu głównym „Obóz trolli (próba)” z ikoną trolla, bo dziecko nie czyta. Przycisk będzie później usunięty, więc dodaj go w jednym, łatwym do znalezienia miejscu.
- Wykorzystaj to, co już jest: ruch Bilba gałką (stick.gd i ruch z valley.gd/river_story.gd), przycisk dłoni, napisy i przycisk „Posłuchaj”, ciemny filtr światła ze sceny latarenek, postać „troll” i pozostałe modele z river_props.gd, a także zachowanie Toba z deskami, który idzie za Bilbem.
- Jedyna NOWA mechanika to troll, który patrzy. Nie dodawaj innych nowych systemów.
- Wszystkie czasy i odległości zapisz jako stałe na początku troll_camp.gd, żeby dało się je łatwo stroić po teście z dzieckiem.
- Każdy etap pracy zapisz w osobnym commicie z opisem po polsku. Stare testy (tests/valley_flow.gd, tests/river_story_flow.gd) muszą dalej przechodzić.

UKŁAD SCENY (widok ukośnie z góry, jak w wiosce)
- Polana nocą. Na północy ognisko z garnkiem i troll Gapa z latarnią.
- Bilbo zaczyna na południu, obok Toba schowanego w krzakach. Tobo jest celem powrotu.
- Między startem a kucykiem stoją 2 duże, okrągłe krzaki. Mają być wyraźnie większe od Bilba, żeby dziecko widziało, że można się za nimi schować.
- Kucyk stoi uwiązany do drzewa za drugim krzakiem, w zasięgu wzroku trolla.
- Na początku kamera pokazuje całą drogę: Bilba, oba krzaki, kucyka i trolla.

MECHANIKA „TROLL PATRZY”
Gapa ma cykl:
1. PLECAMI (BACK_TIME = 3.5 s): odwrócony, liczy na głos „Raz… dwa… trzy…”. Bilbo może swobodnie iść.
2. OBRÓT (TURN_TIME = 0.6 s): dźwięk „Hmm?” i widoczny obrót. To ostrzeżenie.
3. PATRZY (LOOK_TIME = 2.5 s): na ziemi widać pomarańczowy, półprzezroczysty stożek światła z latarni (LOOK_RANGE, LOOK_ANGLE jako stałe).
4. Powrót do 1.

Bilbo zostaje złapany, gdy w fazie PATRZY minęło już GRACE = 0.25 s, Bilbo jest w stożku, NIE jest schowany (schowany = w odległości HIDE_RADIUS od środka krzaka) i gałka jest wychylona ponad STILL_THRESHOLD = 0.15.

Po złapaniu: krótka śmieszna animacja (Gapa „podnosi” Bilba), a Bilbo płynnie wraca do ostatniego krzaka, przy którym był schowany (albo do startu). Jeśli kucyk już szedł za Bilbem, wraca razem z nim. Po ok. 1.5 s cykl zaczyna się od PLECAMI. Nie ma kar, żyć ani punktów.

Kucyk idzie za Bilbem w odległości ok. 1 m, staje, gdy Bilbo stoi, i NIGDY nie powoduje złapania.

PRZEBIEG I KWESTIE (polskie głosy; jeśli nie możesz nagrać klipu tą samą metodą co dotąd, użyj TTS i wypisz brakujące nagrania w raporcie)
- start: Tobo: „Ciii… To Gapa. Kiedy troll się odwraca, idź. Kiedy patrzy, stój jak posąg!”
- liczenie: Gapa: „Raz… dwa… trzy…”
- obrót: Gapa: „Hmm? Kto tu łazi?”
- złapanie: Gapa: „Aha! Mysz w kapeluszu! Wracaj do krzaczka!” (może być na zmianę z „Znowu ty? Hi, hi!”)
- po 2 złapaniach jednorazowa podpowiedź: Tobo: „Kiedy troll patrzy, stój jak posąg.”
- przy kucyku, dłoń podświetlona: „Dotknij dłoni. Odwiąż kucyka i daj mu siana.”
- po odwiązaniu: „Kucyk idzie za tobą! Wracaj do Toba.”
- koniec (Bilbo z kucykiem przy Tobie): Tobo: „Jest! Mój kucyk! Dziękuję, Bilbo!” → gwiazdka → powrót do menu.

TEST AUTOMATYCZNY: dodaj tests/troll_camp_flow.gd w stylu istniejących testów. Ma sprawdzić, że:
1. ruch w fazie PATRZY w stożku bez krzaka kończy się złapaniem i powrotem do ostatniego krzaka,
2. stanie w miejscu w fazie PATRZY nie kończy się złapaniem,
3. ruch za krzakiem w fazie PATRZY nie kończy się złapaniem,
4. pełne przejście (krzak 1 → krzak 2 → kucyk → dłoń → powrót do Toba) kończy scenę,
5. kucyk nigdy nie powoduje złapania.

NA KONIEC
- Wyeksportuj xcode/MalyOdkrywca.pck presetem „iPhone”, uruchom wszystkie trzy testy na pakiecie i zrób commit.
- Raport: jakie wartości stałych przyjąłeś, co wykorzystałeś z istniejącego kodu, wyniki testów, lista brakujących nagrań oraz wszystko, czego nie zrobiłeś, z uzasadnieniem.
