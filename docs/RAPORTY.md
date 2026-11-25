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
