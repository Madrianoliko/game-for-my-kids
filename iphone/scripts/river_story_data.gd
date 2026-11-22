extends RefCounted

const ROUTE := ["door","pack","range","dummy","guard","chief","tobo","blanket","bridge","cross","lanterns","invitation","village","mill","coop","dairy","delivery","recipe","eggs","milk","homecoming"]
const GEAR := ["Latarka","Sznurek","Młotek","Gwoździe","Miecz","Łuk","Tarcza"]
const POSITIONS := [Vector3(-2.8,0,-1.7),Vector3(-1.4,0,-1.8),Vector3(1.15,0,-1.4),Vector3(2.95,0,-.65),Vector3(2.7,0,.6),Vector3(-2.7,0,1.4),Vector3(1.35,0,1.8)]
const VILLAGE := {"lanterns":-11.0,"mill":-19.0,"coop":-27.0,"dairy":-36.0}
const WORDS := {
	"lanterns":"We wiosce jest ciemno! Dwie latarenki stoją z lewej, a trzy z prawej. Ile trzeba zapalić razem?",
	"lit":"Pięć! Wioska rozświetlona. Przy zielonej chatce macha do nas Wiewiórka.",
	"invitation":"Bilbo! Dziś urodziny Tygryska. Pomożesz mi upiec tort? Poszukaj mąki w młynie, jajek w kurniku i mleka w oborze. Przynieś je do mojej chatki z żołędziem!",
	"village":"Rozejrzyj się. Sam wybierz dom. Podejdź do drzwi i dotknij dłoni.",
	"return_home":"Masz wszystko! Zanieś składniki Wiewiórce. Szukaj zielonego dachu i żołędzia nad drzwiami.",
	"delivery":"Jesteś, Bilbo! Podejdź do mojego stołu i podaj mi składniki dłonią.",
	"thanks":"Trzy woreczki mąki, dwa jajka i mleko! Dziękuję! Teraz upieczemy tort dla Tygryska.",
	"leave_mill":"Mąka spakowana! Wróć na plac przez drzwi.",
	"leave_coop":"Jajka są w koszyku! Wyjdź na plac.",
	"leave_dairy":"Wiaderko pełne! Zabierz mleko i wyjdź na plac.",
	"have_mill":"Mąka jest już w twoim plecaku.",
	"have_coop":"Jajka są już w twoim plecaku.",
	"have_dairy":"Mleko jest już w twoim plecaku.",
	"need_mill":"Brakuje mąki. Rozejrzyj się za młynem z dużym kołem.",
	"need_coop":"Brakuje jajek. Poszukaj domu, przy którym chodzą kury.",
	"need_dairy":"Brakuje mleka. Znajdź oborę ze snopkami siana.",
	"road_mill":"Idź ścieżką do młyna z wielkim kołem. Tam są trzy woreczki mąki.",
	"mill":"W młynie pająki zasłoniły worki. Wyjmij łuk i strzel do dwóch pająków!",
	"take_flour":"Droga wolna! Podejdź do worków i dotknij dłoni, żeby zabrać mąkę.",
	"road_coop":"Teraz poszukaj kurnika. Potrzebujemy dwóch jajek.",
	"coop":"Lis zakradł się do kurnika! Podejdź i machnij mieczem, żeby go przepłoszyć.",
	"take_eggs":"Lis uciekł! Podejdź do gniazda i zabierz dwa jajka.",
	"road_dairy":"Zostało mleko. Idź do obory i pomóż nakarmić krowy.",

	"door":"Bilbo, to ja, bóbr! Woda porwała deski z mostu. Pestka czeka na drugim brzegu. Pomożesz mi go naprawić?",
	"wait":"Dobrze, poczekam przy drzwiach. Kiedy będziesz gotowy, podejdź i dotknij dłoni.",
	"pack":"Zbierz narzędzia i sprzęt na drogę. Podejdź do przedmiotu i dotknij dłoni.",
	"exit":"Wszystko spakowane! Podejdź do bobra przy drzwiach i dotknij dłoni.",
	"range":"Bilbo! Ale masz super łuk! Pokaż nam, jak strzelasz. Dotknij łuku obok miecza, potem naciągnij cięciwę i puść, żeby trafić w beczkę!",
	"dummy":"A pokażesz nam swój miecz? Podejdź do słomianych kukieł i spróbuj je ściąć.",
	"guard":"Ork zastąpił drogę do mostu! Osłoń się tarczą i obejdź go. Gdy odsłoni bok, dotknij miecza.",
	"chief":"Dość pojedynku! Przepuszczę was, jeśli policzycie moje jabłka. Dwa tutaj i jeszcze jedno. Ile razem?",
	"tobo":"Jestem Tobo. Mam deski dla bobra, ale nie przejdę przez wodę. Ułożysz kamienie, żebyśmy mogli je zanieść?",
	"trail_guard":"Ścieżka do mostu biegnie obok orka. Chodźmy do niego.",
	"trail_tobo":"Za orkami czeka Tobo. Podejdź do niego. Ma deski dla bobra!",
	"homecoming":"Sto lat, Tygrysku! Wiewiórka stawia tort na stole. Tygrysek uśmiecha się. Dziękuję za mój urodzinowy tort, Bilbo!"
}

static func number_choices(answer:int) -> Array[int]:
	var first := answer - randi_range(0, mini(2, answer - 1))
	return [first, first + 1, first + 2]
