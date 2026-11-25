## 2026-11-25 — Z03. Kłótnia trolli do świtu

Po trzecim kucyku Gapa chwyta Bilba. Krok `troll_dawn` między obozem a stajnią obejmuje zakład i trzy zagadki z kamykami, kiełbaskami i szyszkami.
Przedmioty można policzyć dotykiem. Burczyk zjada jedną z czterech kiełbasek. Dobra odpowiedź wywołuje sprzeczkę i rozjaśnia niebo, pomyłka wywołuje śmiech. Po dwóch pomyłkach głos liczy podświetlane przedmioty.
Po trzeciej odpowiedzi wschodzi słońce i trzy trolle kolejno kamienieją. W tle widać jaskinię. Jej zwiedzanie jest osobnym zadaniem Z04.
Do strojenia z dzieckiem: 0,78 s między liczbami w podpowiedzi i 0,45 s między przemianami trolli. Wszystkie kwestie są nagrane głosem Zosi. Brak otwartych pytań.
Pakiet iPhone ma 8 680 084 bajty. Wszystkie trzy testy przy 60 kl./s przeszły, w tym dotykanie przedmiotów, ubycie kiełbaski, pomoc, świt, wznowienie zagadki i przejście ze starszego zapisu obozu.
Godot przy zamykaniu testów obozu i doliny zgłosił pozostające obiekty. Próba na fizycznym iPhonie pozostaje do wykonania.

## 2026-11-25 — Z02. Dwie drogi do obozu

Po spotkaniu z hersztem nowy krok `fork` prowadzi do obozu. Dziecko wybiera ścieżkę, idąc w nią Bilbem.
Na krótkiej drodze Chrapek chrapie. Wejście w jasne koło budzi trolla i cofa Bilba przed krąg. Po drugiej próbie Tobo podpowiada, jak go obejść.
Długa droga wykorzystuje skoki po kamieniach z rozdziału 1. Po przejściu na drugi brzeg dziecko dochodzi do krzaków przy obozie.
Zapis pamięta wybraną drogę i ukończone skoki. Do strojenia po teście z dzieckiem: promień koła 1,4 m, prędkość Bilba 3,6 m/s, powrót 1 s, odstęp między chrapnięciami 3,3 s.
Cztery nowe kwestie Zosi, chrapanie i mruczenie są w pakiecie. Przeprawa używa istniejącej instrukcji głosowej. Brak brakujących nagrań i pytań.
Pakiet iPhone ma 8 249 188 bajtów. Wszystkie trzy testy przy 60 kl./s przeszły, w tym obie drogi do obozu, cofnięcie przed krąg, wznowienie na kamieniu i zapis herszta sprzed Z02.
Przy zamykaniu testów obozu i doliny Godot zgłosił pozostające obiekty. Czytelność ścieżek i głośność chrapania czekają na próbę na iPhonie.

## 2026-11-25 — Z01 ukończone. Nocny most i jabłka dla herszta

Po stajni dodano kroki `night_bridge` i `chief_sad`. Tobo daje trzy jabłka i towarzyszy Bilbowi na moście. Z wody macha bóbr.
Herszt przyjmuje jabłka po jednym. Gra liczy na głos, po dwóch pomyłkach pomaga w liczeniu, a po poprawnej odpowiedzi herszt zdradza drogę do obozu.
Zapis zachowuje każde przekazane jabłko. Wcześniejszy zapis obozu nadal prowadzi prosto do kucyków.
Zgodnie z odpowiedzią Adriana zastosowano trzy jabłka. Dodano dziewięć kwestii Zosi i wykorzystano istniejące nagrania liczb. Brak brakujących nagrań i otwartych pytań.
Do strojenia po grze z dzieckiem: ekspozycja mostu 0,42, ekspozycja spotkania 0,66, czas podawania jabłka 0,36 s.
Pakiet iPhone ma 8 058 676 bajtów. Wszystkie trzy testy na pakiecie przy 60 kl./s przeszły (river_story_flow, troll_camp_flow, valley_flow).
Przy zamykaniu dwóch testów Godot zgłosił pozostające obiekty. Próba na fizycznym telefonie pozostaje do wykonania.

## 2026-11-25 — Z01. Nocny most i herszt bez jabłek

### PYTANIE

Czy w scenie z hersztem Bilbo ma podać trzy jabłka, a potem odpowiedzieć „Ile mi dałeś?” (Z01 w kolejce), czy podać jedno jabłko, po którym herszt wskazuje drogę (scena 4 w planie rozdziału 2)?
Decyzja zmienia liczbę interakcji, nagrania i warunek przejścia do obozu. Zgodnie z zasadą 10 Z01 pozostaje otwarte.

**ODPOWIEDŹ (Adrian / plan, 2026-11-25):** obowiązuje wersja z kolejki: trzy jabłka podawane po jednym, gra liczy na głos, potem „Ile mi dałeś?” z przyciskami z kropkami. Plan rozdziału 2 (scena 4) został poprawiony tak, żeby się zgadzał. Można robić Z01.
Brak nowych uwag z testów. Prace zatrzymano przed zmianą gry, eksportem i testami.

## 2026-11-25 — Z00. Porządek w dokumentach

Dodano plany, kolejkę, stały prompt oraz pliki raportów i uwag. Cztery stare zlecenia przeniesiono do `docs/archiwum/`.
Plik uwag powstał w tym zadaniu. Nie było zgłoszeń z gry z synem.
Zakres obejmował dokumentację. Brak nowych kroków ROUTE, wartości do strojenia i brakujących nagrań.
Godot 4.7.2 wyeksportował pakiet presetem iPhone. Rozmiar wynosi 7 751 392 B.
Wszystkie trzy testy przeszły na pakiecie przy 60 FPS: river_story_flow, troll_camp_flow i valley_flow.
Przy zamykaniu testu obozu i menu Godot zgłosił ostrzeżenia ObjectDB. Oba procesy zakończyły się kodem 0.
