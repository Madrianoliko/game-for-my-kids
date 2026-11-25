Pracujesz w repozytorium „Mały Odkrywca” (Godot 4.7.2, iphone/). Przerabiasz próbę „Obóz trolli (próba)” w iphone/scripts/troll_camp.gd po pierwszym teście z pięcioletnim synem autora. Nie zmieniaj ROUTE, zapisu gry ani rozdziału 1.

CO WYSZŁO W TEŚCIE
1. Trasa była za krótka. Dziecko przechodziło bez zatrzymywania się. Trasa ma być wyraźnie dłuższa, tak żeby w każdą stronę TRZEBA było schować się co najmniej 2 razy, a najlepiej 3.
2. Zielone krzaki były mylące. Dziecko nie wiedziało, czy jest schowane, bo „bezpieczny promień” wokół krzaka był niewidoczny.
3. Brakowało wprowadzenia: kto ukradł kucyka, gdzie on jest i jaka jest zasada.

NOWA ZASADA (zastępuje „stój jak posąg”)
- Kryjówkami są wyłącznie STOGI SIANA: duże, żółto-złote, wyraźnie wyglądające na siano (np. walec z kopułą i wystające źdźbła). Na polanie nie może być żadnych innych okrągłych obiektów, które da się z nimi pomylić. Usuń zielone krzaki z polany (drzewa na skraju lasu zostają).
- Bilbo jest SCHOWANY tylko w środku stogu (w odległości HAY_RADIUS ≈ 1.0 od środka). Kiedy wchodzi do stogu, stóg się trzęsie, słychać „szur”, a Bilbo zapada się w siano tak, że widać tylko czubek kapelusza. Kiedy wychodzi, wyskakuje z powrotem. Ma być od razu widać, czy jest w środku, czy nie.
- Kiedy Gapa patrzy, widzi wszystko poza stogami. Zamiast wąskiego stożka cała polana robi się pomarańczowa od latarni, a oczy Gapy świecą. Jeśli Bilbo jest wtedy POZA stogiem, zostaje złapany, także wtedy, gdy stoi w miejscu. Usuń regułę „bezruch chroni” i próg gałki jako warunek złapania.
- Po złapaniu (bez zmian w charakterze): śmieszne podniesienie, powrót do ostatniego stogu, w którym Bilbo był schowany, bez kar.
- Cykl Gapy: PLECAMI (liczy „Raz… dwa… trzy…”) → OBRÓT z „Hmm?” jako ostrzeżenie → PATRZY → PLECAMI. Ustaw TURN_TIME = 1.0 s, żeby dziecko zdążyło wskoczyć do stogu. GRACE zostaje jako stała.
- Kucyk idzie za Bilbem jak dotąd. Gdy Bilbo jest w stogu, kucyk staje tuż za stogiem. Kucyk nigdy nie powoduje złapania.

DŁUŻSZA TRASA
- Powiększ polanę w głąb i poprowadź drogę zakosami (ścieżka z jaśniejszej trawy lub udeptanej ziemi). Start z Tobem na południu, kucyk uwiązany przy ognisku Gapy na północnym końcu.
- Rozstaw 6 stogów wzdłuż ścieżki, co ok. 6–7 m. Jeden odcinek biegu ma trwać ok. 2–2,5 s przy prędkości Bilba, czyli w jednym okresie „plecami” da się przebiec najwyżej 1–2 odcinki. Policz to i dobierz BACK_TIME tak, żeby w każdą stronę było co najmniej 2 schowania. Wynik obliczeń wpisz w raport.
- Pierwszy stóg stoi 2 m od startu (do nauki).
- Kamera ma podążać za Bilbem, tak jak w wiosce, bo cała trasa nie zmieści się już w jednym kadrze. W kadrze zawsze ma być widać Bilba, najbliższy stóg przed nim i Gapę albo przynajmniej światło jego latarni.

WPROWADZENIE (przed pierwszym cyklem Gapy)
1. Tobo przy starcie, zmartwiony: „Bilbo! Troll Gapa ukradł mojego kucyka!”
2. Kamera powoli przelatuje wzdłuż ścieżki do kucyka i Gapy przy ognisku: „Tam jest! Przy ognisku trolla.”
3. Kamera wraca do Bilba. Tobo: „Idź po kucyka. Kiedy Gapa się odwraca i liczy, biegnij!”
4. Tobo: „Kiedy Gapa mówi „Hmm?”, wskocz do stogu siana. W stogu cię nie zobaczy!”
5. Nauka: Gapa NIE zaczyna cyklu, dopóki Bilbo nie wejdzie do pierwszego stogu (ten stóg delikatnie pulsuje). Tobo: „Wejdź do stogu.” Gdy Bilbo jest w środku, Gapa raz się odwraca i patrzy. Tobo: „Widzisz? Nie zobaczył cię!” Od tej chwili cykl działa normalnie.
Przy każdym kroku działa przycisk „Posłuchaj”. Wprowadzenia nie da się przerwać przypadkowym dotknięciem.

KWESTIE (głosem Zosi, tą samą metodą co dotąd; wypisz brakujące nagrania)
- intro_stolen: „Bilbo! Troll Gapa ukradł mojego kucyka!”
- intro_there: „Tam jest! Przy ognisku trolla.”
- intro_run: „Idź po kucyka. Kiedy Gapa się odwraca i liczy, biegnij!”
- intro_hide: „Kiedy Gapa mówi „Hmm?”, wskocz do stogu siana. W stogu cię nie zobaczy!”
- intro_first: „Wejdź do stogu.”
- intro_safe: „Widzisz? Nie zobaczył cię!”
- count: „Raz… dwa… trzy…” (bez zmian)
- turn: „Hmm? Kto tu łazi?” (bez zmian)
- caught: „Aha! Widzę cię! Wracaj do stogu!” (na zmianę z „Znowu ty? Hi, hi!”)
- hint (jednorazowo, po 2 złapaniach): „Kiedy Gapa mówi „Hmm?”, szybko do stogu!”
- pony, follow, done: bez zmian
Usuń kwestie i nagrania, które przestały być używane (np. stare „start” ze „stój jak posąg”).

TEST
Zaktualizuj tests/troll_camp_flow.gd. Ma sprawdzić, że:
1. wprowadzenie się kończy, a cykl startuje dopiero po wejściu do pierwszego stogu,
2. stanie poza stogiem w fazie PATRZY kończy się złapaniem,
3. bycie w stogu w fazie PATRZY nie kończy się złapaniem, także przy wychylonej gałce, jeśli Bilbo nie wyszedł ze stogu,
4. przejście bez chowania się jest niemożliwe (symulacja biegu prosto do kucyka kończy się złapaniem),
5. pełne przejście z chowaniem się działa w obie strony, kucyk nie powoduje złapania i scena kończy się gwiazdką.
Stare testy (river_story_flow.gd, valley_flow.gd) muszą przechodzić.

NA KONIEC
- Każdy etap zapisz w osobnym commicie z opisem po polsku. Wyeksportuj xcode/MalyOdkrywca.pck presetem iPhone, uruchom wszystkie trzy testy na pakiecie i zrób commit.
- Raport: rozstawienie stogów i obliczenie, ile razy trzeba się schować w każdą stronę, końcowe wartości stałych, wyniki testów i brakujące nagrania.
