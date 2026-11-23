# Mały Odkrywca

Gra przygodowa 3D na iPhone’a dla pięciolatka. Wspólna mapa prowadzi do osobnych przygód. W głównej przygodzie gracz steruje Bilbem: gałka po lewej, a po prawej dłoń, miecz, łuk i tarcza. Kamera podąża za nim automatycznie. Przy zadaniach matematycznych dziecko dotyka jednej z kilku odpowiedzi.

## Etapy

1. **Dolina Hobbitów** — rozdział 1 „Most nad Bystrą Wodą”: bóbr prosi o naprawę mostu, Bilbo pakuje sprzęt, ćwiczy z łukiem i mieczem, mija orka, pomaga Tobowi, naprawia most, zapala latarenki i zbiera składniki na tort dla Tygryska. Szczegóły niżej. Plan rozdziału 2 jest w `docs/ROZDZIAL_2_TROLLE.md`. Stara trasa „Wyprawa Leo” (lis, sad, placek) to wcześniejsza wersja.
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

## Natywna wersja na iPhone’a

Projekt w katalogu `iphone/` korzysta z Godota 4.7.2, renderera Mobile i zasobów dołączonych do aplikacji. Gra działa w poziomie. Rekord gwiazdek i ustawienie dźwięku zapisuje lokalnie. Polskie podpowiedzi głosowe są dołączone do aplikacji.

W sklonowanym repozytorium otwórz `xcode/MalyOdkrywca.xcodeproj`. Z katalogu repozytorium na Macu możesz wykonać:

```sh
git pull --ff-only
open xcode/MalyOdkrywca.xcodeproj
```

Projekt zawiera wyeksportowaną grę oraz biblioteki dla urządzenia i symulatora. Xcode podczas kompilacji rozpakowuje właściwą bibliotekę Godota z katalogu `Engine`. W **Signing & Capabilities** zaznacz automatyczne podpisywanie i wybierz swój zespół. W razie potrzeby zmień Bundle Identifier na własny. Wybierz podłączonego iPhone’a z iOS 16 lub nowszym i naciśnij **Run**.

Aby ponownie wygenerować projekt z repozytorium, otwórz `iphone/project.godot` w Godocie 4.7.2, zainstaluj zgodne szablony eksportu i wybierz preset **iPhone**. Wpisz swój Apple Team ID zamiast technicznego znacznika `XXXXXXXXXX` używanego przy generowaniu niepodpisanego projektu. Eksportuj do folderu poza katalogiem źródeł. Do kompilacji, podpisania i dystrybucji potrzebny jest Xcode na macOS.

## Plan Doliny Hobbitów „Most nad Bystrą Wodą”

„Nowa przygoda” zaczyna się w chatce Bilba. Bóbr prosi o naprawienie mostu prowadzącego do Pestki. Kciuk w dół pozwala zostać w domu i później wrócić do rozmowy. Bilbo podchodzi do regałów i zbiera sprzęt dłonią. Z pudełka gwoździ dziecko samo przekłada osiem sztuk do plecaka. Przy drzwiach ponownie używa dłoni, żeby wyjść.

Mali hobbici zapraszają Bilba do strzelania do beczek i ćwiczeń na słomianych kukłach. Na trakcie dziecko korzysta z tej samej gałki i miecza. Może przytrzymać tarczę, obejść orka albo poczekać, aż ork opuści osłonę. Herszt pyta o sumę dwóch grup jabłek.

Tobo przynosi deski po ułożonych przez gracza kamieniach. Przy moście gracz liczy pięć luk, widzi dwie gotowe deski i dobiera trzy. Dopasowuje je do miejsc i przybija młotkiem. Za mostem Bilbo zapala latarenki. Wiewiórka zaprasza go do przygotowania tortu na urodziny Tygryska. Z placu gracz sam wybiera młyn, kurnik lub oborę. Gałka prowadzi Bilba między domami, a dłoń otwiera pobliskie drzwi. Po powrocie na plac Bilbo staje przed tym samym budynkiem. Do pieczenia potrzebuje mąki, jajek i mleka. Z pełnym plecakiem wraca do chatki z zielonym dachem i przekazuje składniki Wiewiórce przy stole.

„Wznów” odtwarza postęp. „Wyprawa Leo” otwiera wcześniejszą trasę.

### Sprawdzenie pakietu do Xcode

Po zmianach w Godocie wyeksportuj pakiet presetem iPhone do `xcode/MalyOdkrywca.pck`. Xcode kopiuje ten plik do aplikacji. Test z katalogu `tests/` otwiera ten sam pakiet na Macu, steruje ruchem i klika przyciski. Używa osobnego katalogu zapisu. Przy dostępnym poleceniu `godot` 4.7.2 uruchom z katalogu repozytorium:

```sh
repo_dir="$PWD"
qa_dir=$(mktemp -d)
cp xcode/MalyOdkrywca.pck "$qa_dir/game.pck"
printf '[application]\nconfig/use_custom_user_dir=true\nconfig/custom_user_dir_name="ValleyQA-%s"\n' "$(uuidgen)" > "$qa_dir/override.cfg"
(cd "$qa_dir" && godot --headless --main-pack game.pck --script "$repo_dir/tests/valley_flow.gd")
```
