/* 82
Podać identyfikator studenta, który zdawał egzamin w pierwszym dniu egzaminowania. */
SELECT DISTINCT
id_student
FROM egzaminy
WHERE data_egz = (SELECT MIN(data_egz) FROM egzaminy)

/* 83
Z którego przedmiotu przeprowadzono egzaminy po ostatnim egzaminie z przedmiotu
Bazy danych? Podać nazwę tego przedmiotu. */
SELECT DISTINCT
p.nazwa_p
FROM przedmioty p
INNER JOIN egzaminy e ON p.id_przedmiot = e.id_przedmiot
WHERE e.data_egz > (SELECT MAX(e.data_egz) 
                    FROM egzaminy e 
                    INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
                    WHERE p.nazwa_p = 'Bazy danych')

/* 84
Który egzaminator przeprowadził najmniej egzaminów? Podać jego identyfikator,
Nazwisko oraz imię. Uwzględnić tylko tych egzaminatorów, którzy już przeprowadzili
egzaminy. */
SELECT
egz.id_egzaminator,
egz.imie,
egz.nazwisko
FROM egzaminatorzy egz
INNER JOIN egzaminy e ON egz.id_egzaminator = e.id_egzaminator
GROUP BY egz.id_egzaminator, egz.imie, egz.nazwisko
HAVING COUNT(e.nr_egz) = (SELECT MIN(COUNT(nr_egz)) FROM egzaminy GROUP BY id_egzaminator)

/* 85
W którym ośrodku do egzaminu przystąpiło najwięcej osób? Podać identyfikator i nazwę
takiego ośrodka oraz liczbę egzaminowanych osób. Jeśli wynik zawiera wiele ośrodków,
uporządkować rezultat według nazwy ośrodka. */
SELECT
o.id_osrodek,
o.nazwa_o
FROM osrodki o 
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
GROUP BY o.id_osrodek, o.nazwa_o
HAVING COUNT(e.id_student) = 
                            (
                                SELECT
                                MAX(COUNT(id_student))
                                FROM egzaminy
                                GROUP BY id_osrodek
                            )
ORDER BY 2

/* 86
Z którego przedmiotu nie przeprowadzono jeszcze egzaminu? Podać nazwę przedmiotu. */
SELECT 
p.nazwa_p
FROM przedmioty p
LEFT JOIN egzaminy e ON p.id_przedmiot = e.id_przedmiot
WHERE e.id_przedmiot IS NULL

SELECT 
p.nazwa_p
FROM przedmioty p
WHERE p.id_przedmiot NOT IN (SELECT DISTINCT id_przedmiot FROM egzaminy)

SELECT DISTINCT nazwa_p FROM przedmioty
MINUS
SELECT DISTINCT p.nazwa_p FROM przedmioty p INNER JOIN egzaminy e ON p.id_przedmiot = e.id_przedmiot

/* 87
Który student nie przystąpił jeszcze do egzaminu? Podać jego identyfikator, imię oraz
Nazwisko. */
SELECT
id_student,
imie,
nazwisko
FROM studenci 
WHERE id_student NOT IN (SELECT DISTINCT id_student FROM egzaminy)

SELECT
id_student,
imie,
nazwisko
FROM studenci s
WHERE NOT EXISTS (SELECT nr_egz FROM egzaminy e WHERE e.id_student = s.id_student)

/* 88
Którzy studenci byli na ostatnim egzaminie przeprowadzanym w poszczególnych
ośrodkach? Uwzględnić tylko te ośrodki, w których odbyły się już egzaminy. Dla każdego
ośrodka określonego przez jego identyfikator, podać identyfikator studenta oraz datę
ostatniego egzaminu. */
SELECT DISTINCT 
e1.id_osrodek,
e1.id_student,
e1.data_egz
FROM egzaminy e1
WHERE (e1.id_osrodek, e1.data_egz) = (
                                        SELECT 
                                        e2.id_osrodek,
                                        MAX(e2.data_egz)
                                        FROM egzaminy e2
                                        WHERE e2.id_osrodek = e1.id_osrodek
                                        GROUP BY e2.id_osrodek
                                     )
ORDER BY 1, 2, 3

/* 89
Podać trzy ostatnie dni, kiedy odbyły się egzaminy? Dni należy określić poprzez podanie
pełnej daty tj. dnia, miesiąca oraz roku. Wynik uporządkować malejąco według daty
egzaminu */
SELECT DISTINCT
data_egz
FROM egzaminy e1
WHERE 3 > (
            SELECT 
            COUNT(DISTINCT e2.data_egz)
            FROM egzaminy e2
            WHERE e2.data_egz > e1.data_egz
           )
ORDER BY 1 DESC

/* 90
W których ośrodkach przeprowadzono najwięcej egzaminów z poszczególnych
przedmiotów? Dla każdego przedmiotu, identyfikowanego przez nazwę, wskazać ośrodek,
podając jego identyfikator oraz nazwę. Dodatkowo wyświetlić liczbę egzaminów. */
SELECT 
Nazwa_P, 
o.ID_Osrodek, 
Nazwa_O, 
COUNT(nr_egz)
FROM Przedmioty p
INNER JOIN Egzaminy e1 ON p.Id_przedmiot = e1.Id_przedmiot
INNER JOIN Osrodki o ON o.ID_Osrodek = e1.ID_Osrodek
GROUP BY p.Id_przedmiot, Nazwa_P, o.ID_Osrodek, Nazwa_O
HAVING COUNT(NR_EGZ) = ( 
                        SELECT MAX(COUNT(nr_egz))
                        FROM Egzaminy e2
                        WHERE e2.Id_przedmiot = p.Id_przedmiot
                        GROUP BY ID_Osrodek
                        ) 
                        
/* 91
W których ośrodkach student o identyfikatorze 0000050 nie zdawał jeszcze żadnego
egzaminu? Podać identyfikator ośrodka, jego nazwę oraz miasto */
SELECT 
id_osrodek,
nazwa_o,
miasto
FROM osrodki
WHERE id_osrodek NOT IN (SELECT DISTINCT id_osrodek FROM egzaminy WHERE id_student = '0000050')

/* 92
Który student nie zdawał egzaminu z przedmiotu Bazy danych? Podać identyfikator,
Nazwisko oraz imię studenta. Uwzględnić także tych studentów, którzy jeszcze nie
zdawali żadnego egzaminu. Wynik uporządkować według identyfikatora studenta.
Zadanie należy wykonać, wykorzystując podzapytanie.  */
SELECT
s.id_Student,
s.nazwisko,
s.imie
FROM studenci s
WHERE s.id_student NOT IN (
                            SELECT DISTINCT
                            e.id_student
                            FROM egzaminy e 
                            INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
                            WHERE p.nazwa_p = 'Bazy danych'
                          )
                          
/* 93
W których ośrodkach nie przeprowadzono egzaminu z przedmiotu Bazy danych? Podać
ich identyfikator, nazwę oraz miasto, w którym znajduje się ośrodek. Uwzględnić także te
ośrodki, w których nie odbył się jeszcze żaden egzamin. Wynik uporządkować według
identyfikatora ośrodka. Zadanie należy wykonać, wykorzystując podzapytanie. */
SELECT
o.id_osrodek,
o.nazwa_o,
o.miasto
FROM osrodki o 
WHERE o.id_osrodek NOT IN (
                            SELECT DISTINCT
                            e.id_osrodek
                            FROM egzaminy e 
                            INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
                            WHERE UPPER(p.nazwa_p) = 'BAZY DANYCH'
                          )
ORDER BY 1

/* 94
Którzy studenci zdawali egzaminy z przedmiotu Bazy danych w ośrodkach o nazwie
CKMP i LBS? Podać ich identyfikator, Nazwisko oraz imię. Uwzględnić tylko tych
studentów, którzy zdawali egzaminy ze wskazanego przedmiotu w jednym i drugim
ośrodku. Wynik uporządkować według identyfikatora studenta. Zadanie należy wykonać,
wykorzystując podzapytanie. */
SELECT DISTINCT
s.id_student,
s.imie,
s.nazwisko
FROM studenci s
INNER JOIN egzaminy e ON s.id_Student = e.id_Student
WHERE s.id_Student IN 
(
    SELECT DISTINCT
    id_student
    FROM egzaminy e2
    INNER JOIN osrodki o2 ON e2.id_osrodek = o2.id_osrodek
    WHERE o2.nazwa_o = 'CKMP'
)
AND s.id_student IN
(
    SELECT DISTINCT
    id_student
    FROM egzaminy e2
    INNER JOIN osrodki o2 ON e2.id_osrodek = o2.id_osrodek
    WHERE o2.nazwa_o = 'LBS'
)
ORDER BY 1

/* 95
W których ośrodkach student o nazwisku Biegaj nie zdawał jeszcze egzaminu? Dla
każdego studenta o podanym nazwisku wskazać ośrodek, podając jego identyfikator oraz
nazwę. Uporządkować rezultat zapytania według identyfikatora studenta oraz nazwy
ośrodka. */
SELECT
id_osrodek,
nazwa_o
FROM osrodki 
WHERE id_osrodek NOT IN (
                            SELECT DISTINCT
                            o.id_osrodek 
                            FROM osrodki o
                            INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
                            INNER JOIN studenci s ON e.id_student = s.id_student
                            WHERE s.nazwisko = 'Biegaj'
                        )
/* 96
Z którego przedmiotu przeprowadzono najwięcej egzaminów? Podać nazwę przedmiotu
oraz liczbę egzaminów. */
SELECT
p.nazwa_p,
COUNT(e.id_przedmiot) AS "Liczba egzaminów"
FROM przedmioty p 
LEFT JOIN egzaminy e ON p.id_przedmiot = e.id_przedmiot
GROUP BY p.nazwa_p
HAVING COUNT(e.id_przedmiot) = (
                                SELECT
                                MAX(COUNT(id_przedmiot))
                                FROM egzaminy
                                GROUP BY id_przedmiot
                               )
                               
/* 97
W którym ośrodku przeprowadzono najmniej egzaminów? Podać identyfikator, nazwę
ośrodka oraz liczbę egzaminów w ośrodku. Uwzględnić tylko te ośrodki, w których
odbyły się już egzaminy. */
SELECT
o.id_osrodek,
o.nazwa_o,
COUNT(e.nr_egz) AS "Liczba egzaminów"
FROM osrodki o 
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
GROUP BY o.id_osrodek, o.nazwa_o
HAVING COUNT(e.nr_egz) = (
                            SELECT 
                            MIN(COUNT(nr_egz))
                            FROM egzaminy
                            GROUP BY id_osrodek
                         )
                         
/* 98
Który student zdał najmniej egzaminów w ośrodku (ośrodkach) o nazwie CKMP? Dla
każdego ośrodka o podanej nazwie wskazać studenta, podając jego identyfikator, imię
oraz Nazwisko. Dodatkowo wyświetlić liczbę zdanych egzaminów przez studenta,
wskazanego w wyniku zapytania. Uporządkować wynik zapytania według identyfikatora
ośrodka oraz identyfikatora studenta. */
SELECT
o.id_osrodek,
s.id_student,
s.imie,
s.nazwisko,
COUNT(e.nr_egz) AS "Liczba zdanych egzaminów"
FROM studenci s 
INNER JOIN egzaminy e ON s.id_student = e.id_student
INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
WHERE o.nazwa_o = 'CKMP' AND e.zdal = 'T'
GROUP BY o.id_osrodek, s.id_student, s.imie, s.nazwisko
HAVING COUNT(e.nr_egz) = (
                            SELECT 
                            MIN(COUNT(e.nr_egz))
                            FROM egzaminy e
                            INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
                            WHERE o.nazwa_o = 'CKMP' AND e.zdal = 'T'
                            GROUP BY o.id_osrodek, e.id_student
                         )
ORDER BY 1, 2

/* 99
Który egzaminator egzaminował najwięcej osób? Podać identyfikator, imię i Nazwisko
egzaminatora oraz liczbę egzaminowanych przez niego osób. Jeśli wynik zawiera wielu
egzaminatorów, uporządkować rezultat według identyfikatora egzaminatora. */
SELECT 
egz.id_egzaminator,
egz.imie,
egz.nazwisko,
COUNT(DISTINCT e.id_student)
FROM egzaminatorzy egz
INNER JOIN egzaminy e ON egz.id_egzaminator = e.id_egzaminator
GROUP BY egz.id_egzaminator, egz.imie, egz.nazwisko
HAVING COUNT(DISTINCT e.id_student) = (
                                        SELECT 
                                        MAX(COUNT(DISTINCT id_student))
                                        FROM egzaminy  
                                        GROUP BY id_egzaminator
                                      )
ORDER BY 1

/* 100
W których ośrodkach przeprowadzono ostatni egzamin z poszczególnych przedmiotów?
Dla każdego przedmiotu, identyfikowanego przez nazwę, podać identyfikator oraz nazwę
ośrodka. Dodatkowo wyświetlić datę egzaminu. Uporządkować wynik zapytania według
nazwy przedmiotu. */
SELECT 
p.nazwa_p,
o.id_osrodek,
o.nazwa_o,
MAX(e.data_egz) AS "Data ostatniego egzaminu"
FROM egzaminy e 
INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
INNER JOIN osrodki o ON e.id_osrodek = o.id_osrodek
GROUP BY p.nazwa_p, o.id_osrodek, o.nazwa_o
HAVING MAX(e.data_egz) = (
                            SELECT 
                            MAX(e2.data_egz)
                            FROM egzaminy e2
                            INNER JOIN przedmioty p2 ON e2.id_przedmiot = p2.id_przedmiot
                            WHERE p2.nazwa_p = p.nazwa_p
                         )
ORDER BY 1

select distinct nazwa_p, o.id_osrodek, nazwa_o, data_egz
from przedmioty p inner join egzaminy e on p.id_przedmiot = e.id_przedmiot
inner join osrodki o on o.id_osrodek = e.id_osrodek
where data_egz = (
                    select max(data_egz)
                    from egzaminy
                    where id_przedmiot = p.id_przedmiot
                 )
order by 1, 2

/* 101
W których ośrodkach egzaminator o nazwisku Muryjas nie przeprowadził egzaminu? Dla
każdego egzaminatora o podanym nazwisku wskazać ośrodek bądź ośrodki, podając jego
identyfikator oraz nazwę. Uwzględnić także te ośrodki, w których nie odbył się jeszcze
żaden egzamin. Rezultat zapytania uporządkować według identyfikatora egzaminatora. */
SELECT
egz.id_egzaminator,
o.id_osrodek,
o.nazwa_o
FROM egzaminatorzy egz 
CROSS JOIN osrodki o
WHERE egz.nazwisko = 'Muryjas' AND
(egz.id_egzaminator, o.id_osrodek) NOT IN (
                                            SELECT 
                                            id_egzaminator, id_osrodek
                                            FROM egzaminy
                                          )
/* 102
Z którego przedmiotu przeprowadzono najwięcej egzaminów w poszczególnych
ośrodkach? Dla każdego ośrodka, opisanego przez jego identyfikator oraz nazwę, wskazać
przedmiot, podając jego nazwę. Dodatkowo podać największą liczbę egzaminów
przeprowadzonych z danego przedmiotu w kolejnych ośrodkach. Uporządkować rezultat
zapytania według identyfikatora ośrodka oraz nazwy przedmiotu. */
SELECT
o.id_osrodek,
o.nazwa_o,
p.nazwa_p,
COUNT(e.nr_egz) AS "Liczba egzaminów"
FROM osrodki o 
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON e.id_przedmiot = e.id_przedmiot
GROUP BY o.id_osrodek, o.nazwa_o, p.nazwa_p
HAVING COUNT(e.nr_egz) = (
                            SELECT
                            MAX(COUNT(nr_egz))
                            FROM egzaminy e2
                            WHERE e2.id_osrodek = o.id_osrodek
                            GROUP BY e2.id_osrodek
                         )
ORDER BY 1

/* 103
Którzy studenci zdawali egzamin z poszczególnych przedmiotów w pierwszym dniu
egzaminowania z danego przedmiotu? Dla każdego przedmiotu, identyfikowanego przez
jego nazwę, wskazać studenta, podając jego identyfikator, imię oraz Nazwisko.
Dodatkowo wyświetlić datę pierwszego egzaminu z poszczególnych przedmiotów.
Uporządkować wynik zapytania według nazwy przedmiotu. */
SELECT
p.nazwa_p,
s.id_student,
s.imie,
s.nazwisko,
e.data_egz
FROM przedmioty p
INNER JOIN egzaminy e ON e.id_przedmiot = p.id_przedmiot
INNER JOIN studenci s ON s.id_student = e.id_student
WHERE e.data_egz = (
                    SELECT
                    MIN(data_egz)
                    FROM egzaminy
                    WHERE id_przedmiot = p.id_przedmiot
                   )
ORDER BY 1, 2

/* 104
Którzy studenci zdawali egzamin u egzaminatora o nazwisku Muryjas w pierwszym dniu
egzaminowania przez tego egzaminatora? Dla każdego egzaminatora o podanym
nazwisku wskazać studenta, podając jego identyfikator, Imie oraz Nazwisko. Ponadto
wyświetlić datę pierwszego egzaminu dla każdego egzaminatora o podanym nazwisku.
Wynik zapytania uporządkować według nazwiska i Imienia egzaminatora. */
SELECT
egz.id_egzaminator,
egz.imie,
egz.nazwisko,
s.id_student,
s.imie,
s.nazwisko,
e.data_egz
FROM studenci s 
INNER JOIN egzaminy e ON s.id_student = e.id_student
INNER JOIN egzaminatorzy egz ON egz.id_egzaminator = e.id_egzaminator
WHERE egz.nazwisko = 'Muryjas' 
AND e.data_egz = (
                    SELECT
                    MIN(e2.data_egz)
                    FROM egzaminy e2
                    WHERE e2.id_egzaminator = e.id_egzaminator
                 )
ORDER BY 3, 2

/* 105
Z którego przedmiotu przeprowadzono najwięcej egzaminów w ośrodkach o nazwie
CKMP? Dla każdego ośrodka o podanej nazwie wskazać przedmiot, opisując go jego
nazwą, oraz podać liczbę egzaminów z przedmiotu, będącego wynikiem zapytania.
Otrzymane rezultaty uporządkować według identyfikatora ośrodka. */
SELECT
o.id_osrodek,
o.nazwa_o,
p.nazwa_p,
COUNT(e.nr_egz) AS "Liczba egzaminów"
FROM egzaminy e 
INNER JOIN osrodki o ON e.id_osrodek = o.id_osrodek
INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
WHERE o.nazwa_o = 'CKMP'
GROUP BY o.id_osrodek, o.nazwa_o, p.nazwa_p
HAVING COUNT(e.nr_egz) = (
                            SELECT
                            MAX(COUNT(e2.nr_egz))
                            FROM egzaminy e2
                            INNER JOIN przedmioty p2 ON e2.id_przedmiot = p2.id_przedmiot
                            WHERE e2.id_osrodek = o.id_osrodek
                            GROUP BY e2.id_osrodek, e2.id_przedmiot
                         ) /* W podzapytaniu moga byc tylko wyswietlane pola z zapytania nadrzednego */
ORDER BY 1

/* 106
Którzy studenci zdawali najwięcej egzaminów z poszczególnych przedmiotów? Dla
każdego przedmiotu, opisanego przez jego nazwę, wskazać studenta, podając jego
identyfikator, imię oraz Nazwisko. Uporządkować wynik zapytania według nazwy
przedmiotu.  */
SELECT
p.nazwa_p,
s.id_student,
s.imie,
s.nazwisko,
COUNT(e.nr_egz)
FROM studenci s 
INNER JOIN egzaminy e ON s.id_student = e.id_student
INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
GROUP BY p.nazwa_p, s.id_student, s.imie, s.nazwisko
HAVING COUNT(e.nr_egz) = (
                        SELECT
                        MAX(COUNT(e2.nr_egz))
                        FROM egzaminy e2
                        INNER JOIN przedmioty p2 ON e2.id_przedmiot = p2.id_przedmiot
                        WHERE p2.nazwa_p = p.nazwa_p
                        GROUP BY p2.nazwa_p, e2.id_student
                         )
ORDER BY 1

/* 107
W których ośrodkach egzaminator o nazwisku Muryjas egzaminował więcej niż 2
studentów. Dla każdego egzaminatora o podanym nazwisku podać identyfikator ośrodka
oraz jego nazwę. Rezultat zapytania uporządkować według nazwiska i Imienia
egzaminatora oraz nazwy ośrodka. */
SELECT
egz.id_egzaminator,
egz.nazwisko,
egz.imie,
o.id_osrodek,
o.nazwa_o,
COUNT(DISTINCT e.id_student)
FROM egzaminatorzy egz 
INNER JOIN egzaminy e ON egz.id_egzaminator = e.id_egzaminator
INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
WHERE egz.nazwisko = 'Muryjas'
GROUP BY egz.id_egzaminator, egz.nazwisko, egz.imie, o.id_osrodek, o.nazwa_o
HAVING COUNT(DISTINCT e.id_student) > 2
ORDER BY 3, 2, 4

/* 108
Którzy studenci zdawali pierwszy oraz ostatni egzamin przeprowadzony
w poszczególnych ośrodkach? Dla każdego ośrodka wskazać studenta, podając jego
identyfikator, Nazwisko oraz imię. Do opisu ośrodka użyć jego identyfikator oraz nazwę.
W odpowiedzi dodatkowo zamieścić datę pierwszego i ostatniego egzaminu w
poszczególnych ośrodkach dla wybranych studentów. Uwzględnić tylko te ośrodki, w
których odbył się już egzamin. */
SELECT
s.id_Student,
s.imie,
s.nazwisko,
o.id_osrodek,
o.nazwa_o,
MIN(e.data_egz),
MAX(e.data_egz)
FROM studenci s
INNER JOIN egzaminy e ON s.id_student = e.id_student
INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
GROUP BY s.id_Student, s.imie, s.nazwisko, o.id_osrodek, o.nazwa_o
HAVING (MIN(e.data_egz), MAX(e.data_egz)) = (
                                                SELECT
                                                MIN(e2.data_egz),
                                                MAX(e2.data_egz)
                                                FROM egzaminy e2
                                                WHERE e2.id_osrodek = o.id_osrodek
                                            )

/* 109
Z jakiego przedmiotu egzaminator o nazwisku Muryjas przeprowadził najwięcej
egzaminów w ośrodku o nazwie CKMP? Informację o przedmiocie podać dla każdego
egzaminatora o podanym nazwisku oraz ośrodka o wskazanej nazwie, w którym
egzaminator ten przeprowadził egzaminy. Uporządkować otrzymany wynik według
identyfikatora egzaminatora oraz identyfikatora ośrodka.  */
SELECT
egz.id_egzaminator,
egz.nazwisko,
o.id_osrodek,
o.nazwa_o,
p.nazwa_p,
COUNT(e.nr_egz)
FROM egzaminatorzy egz 
INNER JOIN egzaminy e ON egz.id_egzaminator = e.id_egzaminator
INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
WHERE o.nazwa_o = 'CKMP' AND egz.nazwisko = 'Muryjas'
GROUP BY p.nazwa_p, egz.id_egzaminator, egz.nazwisko, o.id_osrodek, o.nazwa_o
HAVING COUNT(e.nr_egz) = (
SELECT
MAX(COUNT(e2.nr_egz))
FROM egzaminy e2
WHERE e2.id_egzaminator = egz.id_egzaminator AND e2.id_osrodek = o.id_osrodek
GROUP BY e2.id_egzaminator, e2.id_osrodek, e2.id_przedmiot
)
ORDER BY 1, 3

/* 110
W którym ośrodku student o nazwisku Biegaj zdał najmniej egzaminów? Dla każdego
studenta o podanym nazwisku, wskazać ośrodek, podając jego identyfikator oraz nazwę.
Uwzględnić tylko tych studentów, którzy już przystąpili do egzaminu. Dodatkowo podać
dla każdego wybranego studenta liczbę zdanych przez niego egzaminów. Uporządkować
rezultat zapytania według nazwiska i Imienia studenta.  */
SELECT
s.id_student,
s.nazwisko,
s.imie,
o.id_osrodek,
o.nazwa_o,
COUNT(e.nr_egz) AS "Liczba zdanych egzaminów"
FROM studenci s 
INNER JOIN egzaminy e ON s.id_student = e.id_student
INNER JOIN osrodki o ON e.id_osrodek = o.id_osrodek
WHERE s.nazwisko = 'Kowal' AND e.zdal = 'T'
GROUP BY s.id_student, s.nazwisko, s.imie, o.id_osrodek, o.nazwa_o
HAVING COUNT(e.nr_egz) = (
                            SELECT
                            MIN(COUNT(e2.nr_egz))
                            FROM egzaminy e2
                            WHERE e2.id_student = s.id_student AND e2.zdal = 'T'
                            GROUP BY e2.id_student, e2.id_osrodek
                         )
ORDER BY 3, 2

/* 111
Który student ma najwięcej niezdanych egzaminów w poszczególnych ośrodkach? Dla
każdego ośrodka wskazać studenta, podając jego identyfikator, Nazwisko, Imie.
Uwzględnić tylko te ośrodki, w których odbył się już egzamin. Do opisu ośrodka użyć
jego identyfikator oraz nazwę. Dodatkowo dla każdego wybranego studenta wyświetlić
liczbę niezdanych przez niego egzaminów. Uporządkować wynika zapytania według
nazwy ośrodka oraz nazwiska i Imienia studenta */
SELECT
o.id_osrodek,
o.nazwa_o,
s.id_student,
s.nazwisko,
s.imie,
COUNT(e.nr_egz) AS "Liczba niezdanych egzaminów w ośrodku"
FROM studenci s 
INNER JOIN egzaminy e ON s.id_student = e.id_student
INNER JOIN osrodki o ON e.id_osrodek = o.id_osrodek
WHERE e.zdal = 'N'
GROUP BY o.id_osrodek, o.nazwa_o, s.id_student, s.nazwisko, s.imie
HAVING COUNT(e.nr_egz) = (
                            SELECT
                            MAX(COUNT(e2.nr_egz))
                            FROM egzaminy e2
                            WHERE e2.zdal = 'N' AND e2.id_osrodek = o.id_osrodek
                            GROUP BY e2.id_osrodek, e2.id_student
                         )
ORDER BY 2, 4, 5

/* 112
W których ośrodkach poszczególni egzaminatorzy przeprowadzili swój pierwszy i ostatni
zdany egzamin? Dla każdego egzaminatora, opisanego identyfikatorem, nazwiskiem
i Imieniem, wskazać ośrodek, podając jego identyfikator oraz nazwę. Dodatkowo
w odpowiedzi wyraźnie podkreślić informację, iż dany ośrodek jest miejscem pierwszego
lub ostatniego egzaminu. Uporządkować rezultat zapytania według nazwiska i Imienia
egzaminatora. */
SELECT
egz.id_egzaminator,
egz.imie,
egz.nazwisko,
o.id_osrodek,
o.nazwa_o,
e.data_egz,
'Pierwszy egzamin' AS "Opis"
FROM egzaminatorzy egz 
INNER JOIN egzaminy e ON egz.id_egzaminator = e.id_egzaminator
INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
WHERE e.zdal = 'T' AND 
e.data_egz = (
SELECT
MIN(e2.data_egz)
FROM egzaminy e2
WHERE e2.id_egzaminator = egz.id_egzaminator AND e2.zdal = 'T'
)
UNION
SELECT
egz.id_egzaminator,
egz.imie,
egz.nazwisko,
o.id_osrodek,
o.nazwa_o,
e.data_egz,
'Ostatni egzamin' AS "Opis"
FROM egzaminatorzy egz 
INNER JOIN egzaminy e ON egz.id_egzaminator = e.id_egzaminator
INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
WHERE e.zdal = 'T' AND 
e.data_egz = (
SELECT
MAX(e2.data_egz)
FROM egzaminy e2
WHERE e2.id_egzaminator = egz.id_egzaminator AND e2.zdal = 'T'
)
ORDER BY 1, 6

/* 113
W którym miesiącu i którego roku przeprowadzono najwięcej egzaminów w ośrodku
o nazwie Atena? Dla każdego ośrodka o wskazanej nazwie wyznaczyć miesiąc oraz rok,
podając pełną nazwę miesiąca i rok w formacie czterocyfrowym. Dodatkowo wyświetlić
liczbę egzaminów przeprowadzonych w wybranych ośrodkach dla każdego
wyznaczonego miesiąca i roku. Uporządkować wynik zapytania według identyfikatora
ośrodka.  */
SELECT 
o.id_osrodek,
to_char(e.data_egz, 'MONTH') Miesiac,
EXTRACT(YEAR FROM e.data_egz) Rok,
COUNT(e.nr_egz) AS "Liczba egzaminów"
FROM egzaminy e 
INNER JOIN osrodki o ON e.id_osrodek = o.id_osrodek
WHERE UPPER(o.nazwa_o) = 'CKMP'
GROUP BY o.id_osrodek, to_char(e.data_egz, 'MONTH'), EXTRACT(YEAR FROM e.data_egz)
HAVING COUNT(e.nr_egz) = (
SELECT 
MAX(COUNT(e2.nr_egz))
FROM egzaminy e2
WHERE e2.id_osrodek = o.id_osrodek
GROUP BY e2.id_osrodek, to_char(e2.data_egz, 'MONTH'), EXTRACT(YEAR FROM e2.data_egz)
)
ORDER BY 1

/* 114
W którym miesiącu każdego roku przeprowadzono najwięcej egzaminów? Uwzględnić
tylko te lata, w których odbywały się egzaminy. Dla każdego roku wskazać miesiąc,
opisując go jego nazwą.  */
SELECT
EXTRACT(YEAR FROM e.data_egz) Rok,
to_char(e.data_egz, 'MONTH') Miesiac,
COUNT(e.nr_egz) AS "Liczba egzaminów"
FROM egzaminy e
GROUP BY EXTRACT(YEAR FROM e.data_egz), to_char(e.data_egz, 'MONTH')
HAVING COUNT(e.nr_egz) = (
SELECT
MAX(COUNT(e2.data_egz))
FROM egzaminy e2
WHERE EXTRACT(YEAR FROM e2.data_egz) = EXTRACT(YEAR FROM e.data_egz)
GROUP BY EXTRACT(YEAR FROM e2.data_egz), to_char(e2.data_egz, 'MONTH')
)
ORDER BY 1


