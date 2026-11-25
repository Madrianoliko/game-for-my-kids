# Mały Odkrywca — Dolina Hobbitów: plan kolejnych przygód

Rozdziały 1 (most i tort) i 2 (kucyki i trolle) są opisane osobno. Ten dokument planuje rozdziały 3–5. Razem tworzą jedną wyprawę „tam i z powrotem”: mapa ze skrzyni trolli prowadzi na Dymiącą Górę, droga wiedzie przez jaskinie, a na końcu Bilbo wraca do doliny na zimę.

Najważniejsze są zagadki matematyczne. Każdy rozdział uczy jednej nowej umiejętności i powtarza poprzednie.

---

## 1. Zasady dobrej zagadki (wnioski z rozdziału 1)

1. **Odpowiedź zmienia świat.** Tak jak latarenki, które zapalają się po dobrym policzeniu. Nigdy nie kończymy na samym „brawo”.
2. **Wszystko, co się liczy, widać i można tego dotknąć.** Dziecko najpierw dotyka przedmiotów, a gra liczy na głos („jeden… dwa…”), i dopiero potem odpowiada. Tak działa liczenie luk w moście.
3. **Pomyłka pokazuje, dlaczego jest pomyłką.** Za krótka kładka nie sięga brzegu, za mało jagód i smoczek dalej jest głodny, za ciężki wóz staje. Dziecko widzi skutek i od razu próbuje jeszcze raz. Samo „spróbuj jeszcze raz” uczy mniej.
4. **Pomoc po dwóch pomyłkach.** Przedmioty zapalają się po kolei, a głos liczy razem z dzieckiem. Następna próba to już sukces.
5. **Nie zawsze cztery przyciski.** Najlepiej działają odpowiedzi rękami: dobierz 3 deski, podziel jagody, ułóż kamienie po kolei. Przyciski z liczbami zostawiamy na krótkie pytania postaci.
6. **Przyciski z kropkami.** Pięciolatek, który nie czyta, nie zawsze zna cyfry. Na przycisku powinna być cyfra i pod nią tyle kropek, ile wynosi liczba. Obecne przyciski (`river_icons.gd`, funkcja `apply`) pokazują same cyfry, więc warto to zmienić od razu, także w rozdziale 1.
7. **Inne liczby przy każdym przejściu.** Przy drugim przejściu liczby w zagadkach powinny się zmieniać w granicach, na jakie pozwala fabuła (np. 2 + 3 albo 1 + 4 latarenki). Dzięki temu syn liczy, a nie pamięta odpowiedź.
8. **Zakres:** liczenie do 15, dodawanie i odejmowanie do 10, w dodawaniu każdy składnik mniejszy niż 8 (tak jak w README).

---

## 2. Drabinka umiejętności

| Rozdział | Nowa umiejętność | Powtórka |
|---|---|---|
| 1. Most i tort | liczenie do 5, dodawanie, „ile brakuje” | — |
| 2. Kucyki i trolle | odejmowanie („ile zniknęło”, „ile zostało”) | dodawanie, liczenie |
| 3. Zgubiony smoczek | kolejność liczb, porównywanie (więcej/mniej), dzielenie po równo | dodawanie |
| 4. Zagadki w ciemności | wzory (co będzie dalej), liczenie dźwięków, podwajanie | wszystko z rozdziałów 1–3 |
| 5. Zima w dolinie | dopełnianie do 10, rozdzielanie ładunku, liczby porządkowe | wszystko |

---

## 3. Rozdział 3: „Zgubiony smoczek”

**Otwarcie:** Bilbo rozwija mapę znalezioną w jaskini trolli. Nad Dymiącą Górą widać dymek. W nocy z sadu znikają jabłka, a rano pod jabłonią leżą przypalone ogryzki i jest ślad małych łapek. W krzakach płacze mała smoczyca Iskierka. Zgubiła się i nie umie wrócić do mamy.

**Cel Bilba:** odprowadzić Iskierkę do mamy na szczyt Dymiącej Góry.

**Scena do opowiadania:** „Iskierka kichnęła i zapaliła wszystkie świeczki naraz, a potem jej mama zabrała nas na plecach nad całą doliną!”

**Nowa mechanika:** smoczek idzie za Bilbem (tak jak kucyk) i może „kichnąć” ogniem po dotknięciu przycisku z płomykiem. To przycisk jak miecz czy łuk, a kichnięcie zapala rzeczy w zasięgu.

### Zagadki
1. **Głodny smoczek (dzielenie po równo).** Bilbo ma 6 jagód, a smoczek chce się podzielić: „Dla ciebie i dla mnie, tyle samo!”. Dziecko przeciąga jagody na dwa listki. Gdy na listkach jest po 3, smoczek mruczy z radości i jego płomyk robi się jaśniejszy. Gdy jagód jest nierówno, smoczek robi smutną minę i pokazuje listek, na którym jest mniej.
2. **Kamienne stopnie (kolejność liczb).** Schody na zbocze mają wyryte kropki od 1 do 8, ale trzy stopnie spadły i leżą obok. Dziecko wkłada je w luki, a każdy pasujący stopień zapala się na złoto. Pomyłka: stopień się chwieje, a Bilbo nie może na niego wejść.
3. **Ciepła jaskinia (więcej/mniej).** Iskierka marznie. Są dwie kupki węgielków. Smoczek pyta: „Na której jest więcej?”. Dziecko dotyka kupki, a Iskierka kicha w nią. Więcej węgielków daje duże, ciepłe ognisko. Mniej daje mały płomyczek, przy którym smoczek dalej się trzęsie i można wybrać jeszcze raz.
4. **Świeczki pustelnika (dodawanie).** Stary kret pustelnik przepuszcza tylko tego, kto zapali mu świeczki urodzinowe: 3 na torcie i 2 na półce. „Ile razy musi kichnąć Iskierka?”. Każde kichnięcie zapala jedną świeczkę. Za mało kichnięć znaczy, że jakaś zostaje zgaszona. Za dużo i Iskierka przypala kretowi czapkę, co jest śmieszne i nie przeszkadza w dalszej grze.
5. **Jajka mamy (odejmowanie, finał).** Na szczycie mama smoczyca liczy swoje dzieci: w gnieździe są 4 skorupki. „Mam pięcioro dzieci, a w gnieździe są cztery. Kogo brakuje?”. Odpowiedź „jednego”, czyli Iskierki, kończy scenę. Mama obejmuje Iskierkę skrzydłem.

**Wybór drogi:** u stóp góry są dwie ścieżki, przez strumień po kamieniach albo przez krzaki jeżyn, które Iskierka może wypalić kichnięciem. Obie prowadzą do kamiennych stopni.

**Nagroda:** lot na plecach mamy smoczycy nad doliną. Dziecko widzi z góry młyn, most i obóz trolli, czyli wszystkie znajome miejsca. Mama ostrzega: „Wracajcie przez jaskinie, tam jest krócej. Tylko uważajcie na Szeptka…”.

### Kwestie
> Iskierka: „Chlip… Zgubiłam się. Moja mama mieszka na górze, tam, gdzie dym.”
> Iskierka: „Podzielmy się! Dla ciebie i dla mnie, tyle samo.”
> Kret: „Kto zapali moje świeczki, ten przejdzie. Trzy na torcie, dwie na półce!”
> Mama smoczyca: „Mam pięcioro dzieci, a w gnieździe są cztery. Kogo brakuje?”

**Czas:** około 12–15 min.

---

## 4. Rozdział 4: „Zagadki w ciemności”

**Otwarcie:** Bilbo wraca do doliny przez jaskinie pod Dymiącą Górą. W ciemności błyszczą kryształy, a gdzieś kapie woda. Z cienia wychodzi Szeptek, chudy, ciekawski stworek z wielkimi oczami. Jest bardziej psotny niż groźny. Zabrał Bilbowi latarkę i odda ją tylko temu, kto wygra z nim w zagadki.

**Cel Bilba:** wygrać z Szeptkiem w zagadki, odzyskać latarkę i wyjść z jaskini.

**Scena do opowiadania:** „Szeptek kazał mi liczyć kapiące krople po ciemku, a ja wszystkie policzyłem i wygrałem!”

**Nowa mechanika:** liczenie dźwięków. Ekran ciemnieje, słychać kapnięcia, stuknięcia albo kumkanie, a dziecko odpowiada, ile ich było. Przy każdym dźwięku na sekundę zapala się kryształ. Po dwóch pomyłkach kryształy zostają zapalone na stałe, żeby można je było policzyć wzrokiem.

### Zagadki
Każda wygrana zagadka zapala na stałe jeden wielki kryształ na ścianie. Kryształy pokazują, ile jeszcze zostało do wyjścia, a po zapaleniu wszystkich robi się jasno.

1. **Kapiące krople (liczenie dźwięków).** „Słuchaj… Ile kropli spadło?”. Najpierw 3 krople, później 5.
2. **Kryształowe drzwi (wzór).** Na drzwiach wiszą kryształy: czerwony, niebieski, czerwony, niebieski, czerwony i puste miejsce. Dziecko wkłada pasujący kryształ, a drzwi się otwierają. W trudniejszej wersji wzór ma trzy elementy: duży, mały, mały, duży, mały, ?
3. **Palce Szeptka (podwajanie).** „Na jednej ręce mam trzy palce. Ile mam na dwóch?”. Szeptek najpierw pokazuje jedną rękę, potem obie. Śmieszne jest to, że Szeptek ma tylko trzy palce na ręce.
4. **Ryby w jeziorku (odejmowanie z ruchem).** W jeziorku pływa 6 świecących rybek. Szeptek klaszcze i 2 rybki odpływają w ciemność. „Ile zostało?”. Dziecko widzi, jak rybki odpływają.
5. **Wielka zagadka (powtórka).** „Ile nóg ma Bilbo, a ile kucyk? A razem?”. Kucyk Toba pojawia się na obrazku. Bilbo ma 2 nogi, kucyk 4, razem 6. To przygotowanie do rozdziału 5.

**Wybór kolejności:** w jaskini są trzy tunele, każdy z inną zagadką (krople, drzwi, rybki). Dziecko samo wybiera kolejność, tak jak przy domach w wiosce. Po trzech wygranych Szeptek zadaje dwie ostatnie zagadki.

**Finał:** Szeptek przegrywa, ale nie umie się złościć. Oddaje latarkę i pokazuje wyjście. Na pożegnanie mówi: „Wróć kiedyś. Mam jeszcze dużo zagadek!”. To dobre wejście do przyszłego trybu zagadek do powtarzania.

### Kwestie
> Szeptek: „Ciii… Kto tu chodzi z latarką? Teraz to moja latarka! Hi, hi.”
> Szeptek: „Oddam, jeśli wygrasz w zagadki. Słuchaj uważnie…”
> Szeptek: „Ile kropli spadło? Raz jeszcze? Proszę bardzo!”
> Szeptek (po przegranej): „Wygrałeś… Masz latarkę. Ale wróć kiedyś!”

**Czas:** około 12 min.

---

## 5. Rozdział 5: „Zima w dolinie” (finał wyprawy)

**Otwarcie:** Bilbo wychodzi z jaskini nad doliną, a z nieba spadają pierwsze płatki śniegu. Bóbr woła: „Idzie śnieżyca! Domy nie mają drewna na zimę!”. Na placu leży wielki stos polan, a Tobo przyprowadza kucyka z wozem.

**Cel Bilba:** rozwieźć drewno do wszystkich domów, zanim przyjdzie śnieżyca.

**Scena do opowiadania:** „Rozwiozłem drewno wozem z kucykiem do wszystkich domów, a potem była wielka bitwa na śnieżki!”

**Nowa mechanika:** wóz z ładunkiem. Kucyk ciągnie wóz za Bilbem, a do wozu przeciąga się polana palcem (tak jak gwoździe do plecaka). Wóz mieści najwyżej 10 polan, a na wozie widać 10 miejsc, jak w ramce do liczenia.

### Zagadki
1. **Ile potrzebuje dom (liczenie z wyglądu).** Każdy dom potrzebuje tyle polan, ile ma okien. Okna świecą, a dziecko może ich dotknąć i policzyć. Młyn ma 4 okna, kurnik 2, chatka Wiewiórki 3.
2. **Pełny wóz (dopełnianie do 10).** Na wozie leży już 7 polan. „Ile jeszcze zmieści się na wóz?”. Wolne miejsca w ramce świecą. Za dużo polan i ostatnie spada w śnieg z humorystycznym „bęc”.
3. **Rozwożenie (dodawanie i odejmowanie w praktyce).** Dziecko samo wybiera, do których domów pojedzie i w jakiej kolejności. Pod drzwiami zdejmuje z wozu tyle polan, ile trzeba. Kiedy w domu jest dość drewna, z komina leci dym, co jest widoczną zmianą w świecie. Jeśli na wozie zabraknie polan, Bilbo wraca na plac po więcej. To naturalna lekcja planowania.
4. **Kto pierwszy na sankach (liczby porządkowe).** Na koniec mali hobbici zjeżdżają na sankach z górki. Dziecko ustawia ich na mecie „pierwszy, drugi, trzeci” według kolejności, w jakiej przyjechali. Kolejne sanki mają w czasie zjazdu inny kolor szalika.

**Finał:** wszystkie kominy dymią. Na placu jest bitwa na śnieżki z małymi hobbitami: łuk strzela śnieżkami, a tarcza je odbija. To lekka walka znanymi przyciskami. Potem wszyscy goście z całej wyprawy siedzą przy ognisku: Wiewiórka, Tygrysek, bóbr, Pestka, Tobo z kucykami, herszt z jabłkami, a nad doliną przelatuje mama smoczyca. Tobo liczy gości razem z dzieckiem.

### Kwestie
> Bóbr: „Idzie śnieżyca! Domy nie mają drewna na zimę!”
> Tobo: „Mój kucyk pociągnie wóz. Ładuj polana!”
> Wiewiórka: „Moja chatka ma trzy okna. Ile polan mi przywieziesz?”
> Tobo: „Na wozie jest siedem. Ile jeszcze się zmieści?”

**Czas:** około 15 min.

---

## 6. Ile to razem daje

| Rozdział | Szacowany czas |
|---|---|
| 1. Most i tort | już zbudowany (do zmierzenia stoperem) |
| 2. Kucyki i trolle | około 15 min |
| 3. Zgubiony smoczek | około 12–15 min |
| 4. Zagadki w ciemności | około 12 min |
| 5. Zima w dolinie | około 15 min |

Razem, łącznie z rozdziałem 1, to około godziny grania, podzielonej na rozdziały po kwadransie, co jest dobrą długością na jedno posiedzenie pięciolatka.

## 7. Kolejność budowy

1. Dokończyć rozdział 2 (po teście stogów).
2. Zasady 6 i 7 z części 1 (kropki na przyciskach, losowanie liczb) wprowadzić w całej grze. To mała praca, a pomaga we wszystkich rozdziałach.
3. Rozdział 3 zacząć od wycinka „Głodny smoczek”: smoczek idący za Bilbem i dzielenie jagód. To pierwsza zagadka z dzieleniem i warto sprawdzić z synem, czy rozumie „tyle samo”.
4. W rozdziale 4 najpierw sprawdzić liczenie dźwięków, bo to zupełnie nowy sposób odpowiadania.
