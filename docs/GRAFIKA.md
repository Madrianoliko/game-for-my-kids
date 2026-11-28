# Mały Odkrywca — plan grafiki (od 2026-11-28)

Cel: w przyszłym tygodniu ładna wersja demo do pokazania synowi. Rozwój nowych przygód (rozdział 5) czeka do czasu po demo.

## Decyzje
1. **Styl:** low-poly, płaskie cieniowanie, ciepłe i nasycone kolory, kreskówkowe proporcje (duże głowy, krótkie nogi). Pasuje do obecnej gry zbudowanej z prostych brył, do darmowych paczek CC0 i do iPhone’a 12 (mało wielokątów).
2. **Skala:** 1 jednostka = 1 metr. Wymiary docelowe (wysokość): Bilbo 1,0; Tobo 1,1; mali hobbici 0,8; Wiewiórka 0,6; Tygrysek 0,6; bóbr 0,5; herszt orków 1,6; trolle 2,6–3,0; kucyk 1,2 (w kłębie); Iskierka 0,5; mama smoczyca 4,0; drzwi 1,6; stóg siana 1,6. Zastępcze bryły i nowe modele muszą mieć dokładnie te wymiary.
3. **Wygląd oddzielony od logiki:** każda postać i ważny przedmiot to węzeł logiki (pozycja, kolizja, stan) z dzieckiem „Wyglad”, które wczytuje się z rejestru `kind → scena .tscn`. Jeśli modelu nie ma, rejestr zwraca dzisiejszą bryłę. Podmiana grafiki = podmiana pliku, bez zmian w logice i testach.
4. **Źródła modeli (w tej kolejności):**
   - darmowe paczki CC0 autora Quaternius (zwierzęta gospodarskie z koniem, potwory ze smokiem, postacie RPG, natura, średniowieczna wioska) i Kenney — gotowe animacje, bez kosztów,
   - Meshy (text-to-3D + auto-rigging) tylko dla postaci, których nie ma w paczkach (np. Bilbo-hobbit, trolle). Auto-rigging Meshy działa dobrze tylko dla postaci dwunożnych, więc zwierzęta i smoki bierzemy z paczek. Klucz w zmiennej `MESHY_API_KEY`, nigdy w repozytorium.
   - Licencje i źródło każdego modelu zapisujemy w `assets/ZRODLA.md`.
5. **„Soczystość” od razu:** reakcja na każdy dotyk (podskok, błysk, dźwięk), gwiazdki i konfetti przy dobrej odpowiedzi. Dla pięciolatka to często ważniejsze niż ładne modele.
6. **Kawałek na gotowo najpierw:** zanim podmienimy wszystko, robimy pełny test drogi modelu (pobranie → import do Godota → skala → animacje → telefon) na Bilbie, bobrze i kucyku.

## Kolejność (zadania A01–A06 w `docs/KOLEJKA.md`)
A01 rejestr wyglądu i skala → A02 światło, niebo, kolory i soczystość → A03 pierwsze modele (test drogi) → A04 pozostałe postacie → A05 otoczenie → A06 menu i ekran tytułowy. Głosy (G02) najlepiej przed demo, bo dają dużo za mało pracy.
