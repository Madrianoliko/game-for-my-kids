# Mały Odkrywca

Gra przygodowa 3D na iPhone’a dla pięciolatka. Wspólna mapa prowadzi do osobnych przygód. W każdej z nich Leo porusza się jedną gałką, a kamera podąża za nim automatycznie. Przy zadaniach matematycznych dziecko dotyka jednej z czterech odpowiedzi.

## Etapy

1. **Dolina Hobbitów** — wyprawa przez dolinę. Leo liczy deski na planie bobra, przechodzi po wyznaczonej ścieżce i dodaje latarenki, aby otworzyć bramę. Za wioską zbiera w sadzie trzy jabłka na placek. Pierwsza wersja skupia się na tym świecie.
2. **Hot Wheels** — osobna przygoda na pomarańczowym torze z zagadkami związanymi z jazdą. Na razie dostępny jest podgląd świata.
3. **Harry Potter** — osobna przygoda w szkole magii z własną scenerią i zagadkami. Na razie dostępny jest podgląd świata.

Gra ćwiczy liczenie do 15. W dodawaniu każdy składnik jest mniejszy niż 8.

## Uruchomienie

Otwórz opublikowaną grę w Safari na iPhonie. Opcja **Udostępnij → Do ekranu początkowego** dodaje ikonę gry na telefonie.

Wersję roboczą można uruchomić bez instalowania zależności, z katalogu repozytorium:

```sh
python3 -m http.server 8080 --directory maly-odkrywca/dist
```

Otwórz `http://localhost:8080`. Na komputerze strzałki lub klawisze WASD zastępują ekranową gałkę.

## Punkty zapisu pracy

Po ukończeniu grywalnego odcinka sprawdź przejście od wyboru świata do nagrody, zrób commit i wypchnij go do repozytorium. Przed końcem sesji porównaj identyfikatory lokalnego i zdalnego commitu. Każdy kolejny świat dostaje własny katalog i własny punkt zapisu.
