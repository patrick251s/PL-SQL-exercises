/* 47
Który egzaminator nie przeprowadził jeszcze żadnego egzaminu? Podać jego identyfikator,
imię oraz Nazwisko. Uporządkować otrzymany wynik wg nazwiska i Imienia
egzaminatora. */
SELECT 
id_egzaminator,
nazwisko,
imie
FROM egzaminatorzy
MINUS
SELECT DISTINCT
p.id_egzaminator,
p.nazwisko,
p.imie
FROM egzaminatorzy p INNER JOIN egzaminy e ON p.id_egzaminator = e.id_egzaminator

SELECT DISTINCT
p.id_egzaminator,
p.nazwisko,
p.imie
FROM egzaminatorzy p LEFT JOIN egzaminy e ON p.id_egzaminator = e.id_egzaminator
WHERE e.id_egzaminator IS NULL
ORDER BY p.nazwisko, p.imie

/* 48
W których ośrodkach przeprowadzono egzaminy z przedmiotu o nazwie Bazy danych oraz
Arkusze kalkulacyjne? W odpowiedzi uwzględnić te ośrodki, w których odbył się egzamin
przynajmniej z jednego podanego przedmiotu. Dla każdego przedmiotu, opisanego przez
jego nazwę, podać identyfikator oraz nazwę ośrodka. Rezultat uporządkować wg nazwy
przedmiotu i identyfikatora ośrodka. */
SELECT DISTINCT
p.nazwa_p,
o.id_osrodek,
o.nazwa_o
FROM osrodki o INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
WHERE UPPER(p.nazwa_p) IN ('BAZY DANYCH', 'ARKUSZE KALKULACYJNE')
ORDER BY p.nazwa_p, o.id_osrodek

/* 49
Którzy egzaminatorzy przeprowadzili egzaminy w poszczególnych ośrodkach? Dla
każdego ośrodka, w którym odbył się egzamin podać identyfikator, imię i Nazwisko
egzaminatora, prowadzącego ten egzamin. Uporządkować rezultat według identyfikatora
ośrodka oraz identyfikatora egzaminatora. */
SELECT DISTINCT
o.id_osrodek,
o.nazwa_o,
egz.id_egzaminator,
egz.imie,
egz.nazwisko
FROM osrodki o INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN egzaminatorzy egz ON e.id_egzaminator = egz.id_egzaminator
ORDER BY o.id_osrodek, egz.id_egzaminator

/* 50
W których ośrodkach student o identyfikatorze '0000049' zdał egzaminy z poszczególnych
przedmiotów? Uwzględnić tylko te przedmioty, które były już zdawane przez studenta.
Dla każdego przedmiotu wskazać ośrodek, w którym miał miejsce zdany egzamin. Do
opisu przedmiotu zastosować jego nazwę, natomiast do opisu ośrodka – jego identyfikator
oraz nazwę. Uporządkować wyświetlane informacje malejąco wg daty zdania egzaminu. */
SELECT DISTINCT
p.nazwa_p,
o.id_osrodek,
o.nazwa_o,
e.data_egz
FROM osrodki o INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
INNER JOIN studenci s ON e.id_student = s.id_student
WHERE s.id_student = '0000005' AND e.zdal = 'T'
ORDER BY e.data_egz DESC

/* 51
W których ośrodkach student o identyfikatorze '0000050' nie zdawał jeszcze żadnego
egzaminu? Podać identyfikator ośrodka, jego nazwę oraz miasto. Uporządkować
otrzymany wynik wg nazwy ośrodka. */
SELECT DISTINCT
o.id_osrodek,
o.nazwa_o,
o.miasto
FROM osrodki o LEFT JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN studenci s ON e.id_student = s.id_student
WHERE e.id_osrodek IS NULL AND s.id_student = '0000005'
ORDER BY o.nazwa_o

/* 52
Którzy studenci nie zdawali egzaminu w okresie od 20 maja 2000 r. do 20 maja 2002 r.?
Uwzględnić także tych studentów, którzy jeszcze nie przystąpili do egzaminu. Podać ich
identyfikator, Nazwisko oraz imię. Uporządkować otrzymany wynik wg identyfikatora
studenta. */
SELECT DISTINCT
id_student,
nazwisko,
imie
FROM studenci
MINUS
SELECT DISTINCT
s.id_student,
s.nazwisko,
s.imie
FROM studenci s
INNER JOIN egzaminy e ON s.id_student = e.id_student
WHERE e.data_egz BETWEEN '2005-05-20' AND '2006-05-20'

/* 53
Którzy egzaminatorzy przeprowadzili egzaminy w ośrodkach o nazwie CKMP i LBS?
Podać ich identyfikator, Nazwisko oraz imię. Uwzględnić tylko tych egzaminatorów,
którzy przeprowadzali egzaminy w jednym i drugim ośrodku. Uporządkować otrzymany
wynik wg identyfikatora egzaminatora. */
SELECT DISTINCT
p.id_egzaminator,
p.nazwisko,
p.imie
FROM egzaminatorzy p
INNER JOIN egzaminy e ON p.id_egzaminator = e.id_egzaminator
INNER JOIN osrodki o ON e.id_osrodek = o.id_osrodek
WHERE UPPER(o.nazwa_o) = 'CKMP'
INTERSECT
SELECT DISTINCT
p.id_egzaminator,
p.nazwisko,
p.imie
FROM egzaminatorzy p
INNER JOIN egzaminy e ON p.id_egzaminator = e.id_egzaminator
INNER JOIN osrodki o ON e.id_osrodek = o.id_osrodek
WHERE UPPER(o.nazwa_o) = 'LBS'
ORDER BY 1

/* 54
W których ośrodkach nie przeprowadzono egzaminu z przedmiotu „Bazy danych”? Podać
ich identyfikator, nazwę oraz miasto, w którym znajduje się ośrodek. Uwzględnić także te
ośrodki, w których nie odbył się jeszcze żaden egzamin. Uporządkować otrzymany wynik
wg nazwy ośrodka. */
SELECT DISTINCT
o.id_osrodek,
o.nazwa_o,
o.miasto
FROM osrodki o
MINUS
SELECT DISTINCT
o.id_osrodek,
o.nazwa_o,
o.miasto
FROM osrodki o
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
WHERE p.nazwa_p = 'Bazy danych'
ORDER BY 1

select distinct o.id_osrodek, nazwa_o
from osrodki o cross join przedmioty p
left join egzaminy e 
on o.id_osrodek = e.id_osrodek and p.id_przedmiot = e.id_przedmiot
where upper(nazwa_p) = 'BAZY DANYCH'
    and e.id_osrodek is null;
    
/* 55
Którzy studenci nie zdawali egzaminu w ośrodku o nazwie CKMP i LBS? Uwzględnić
tylko tych studentów, którzy nie zdawali egzaminów w jednym i drugim ośrodku. Podać
ich identyfikator, imię i Nazwisko. Uporządkować otrzymany wynik wg nazwiska i
Imienia studenta. */
select distinct e.id_student, e.nazwisko, e.imie
from studenci e
MINUS
select distinct e.id_student, e.nazwisko, e.imie
from studenci e
join egzaminy eg on eg.id_student = e.id_student
join osrodki o on o.id_osrodek = eg.id_osrodek
where upper(o.nazwa_o)='LBS'
MINUS
select distinct e.id_student, e.nazwisko, e.imie
from studenci e
join egzaminy eg on eg.id_student = e.id_student
join osrodki o on o.id_osrodek = eg.id_osrodek
where upper(o.nazwa_o)='CKMP'
order by id_student

/* 56
Którzy egzaminatorzy przeprowadzili egzaminy w ośrodku o nazwie CKMP? Dla każdego
ośrodka o podanej nazwie wskazać egzaminatora, podając jego identyfikator, imię
i Nazwisko. W odpowiedzi uwzględnić także te ośrodki, w których nie było jeszcze
egzaminu. Do identyfikacji ośrodka użyć jego identyfikatora oraz nazwy. Uporządkować
otrzymany rezultat wg identyfikatora ośrodka oraz identyfikatora egzaminatora */
SELECT DISTINCT
o.nazwa_o,
p.id_egzaminator,
p.nazwisko,
p.imie
FROM osrodki o 
LEFT JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN egzaminatorzy p ON e.id_egzaminator = p.id_egzaminator
WHERE o.nazwa_o = 'CKMP'
ORDER BY 1, 2

/* 57
Którzy studenci zdawali egzaminy z przedmiotu „Bazy danych” w ośrodkach o nazwie
CKMP i LBS? Podać ich identyfikator, Nazwisko oraz imię. Uwzględnić tylko tych
studentów, którzy zdawali egzaminy ze wskazanego przedmiotu w jednym i drugim
ośrodku. Uporządkować otrzymany wynik wg identyfikatora studenta. */
SELECT DISTINCT 
s.id_student,
s.nazwisko,
s.imie
FROM studenci s
INNER JOIN egzaminy e ON e.id_student = s.id_student
INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
WHERE p.nazwa_p = 'Bazy danych' AND o.nazwa_o = 'CKMP'
INTERSECT
SELECT DISTINCT 
s.id_student,
s.nazwisko,
s.imie
FROM studenci s
INNER JOIN egzaminy e ON e.id_student = s.id_student
INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
WHERE p.nazwa_p = 'Bazy danych' AND o.nazwa_o = 'LBS'
ORDER BY 1 DESC

/* 58
Którzy studenci zdawali egzaminy u egzaminatora o identyfikatorze '0001' oraz '0004'?
Podać identyfikator, imię i Nazwisko studenta. Uwzględnić tylko tych studentów, którzy
zdawali egzaminy zarówno u jednego jak i drugiego egzaminatora. Uporządkować
otrzymany wynik wg identyfikatora studenta. */
SELECT DISTINCT 
s.id_student,
s.nazwisko,
s.imie
FROM studenci s
INNER JOIN egzaminy e ON e.id_student = s.id_student
INNER JOIN egzaminatorzy egz ON egz.id_egzaminator = e.id_egzaminator
WHERE egz.id_egzaminator = '001'
INTERSECT
SELECT DISTINCT 
s.id_student,
s.nazwisko,
s.imie
FROM studenci s
INNER JOIN egzaminy e ON e.id_student = s.id_student
INNER JOIN egzaminatorzy egz ON egz.id_egzaminator = e.id_egzaminator
WHERE egz.id_egzaminator = '004'
ORDER BY 1

/* 59
W których ośrodkach przeprowadzono egzaminy z przedmiotu o nazwie Bazy danych,
a nie przeprowadzono egzaminu z przedmiotu o nazwie Arkusze kalkulacyjne? Podać
identyfikator oraz nazwę ośrodka. Rezultat uporządkować wg nazwy ośrodka.  */
SELECT DISTINCT
o.id_osrodek,
o.nazwa_o
FROM osrodki o 
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
WHERE UPPER(p.nazwa_p) = 'BAZY DANYCH'
MINUS
SELECT DISTINCT
o.id_osrodek,
o.nazwa_o
FROM osrodki o 
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
WHERE UPPER(p.nazwa_p) = 'ARKUSZE KALKULACYJNE'
ORDER BY 2

SELECT DISTINCT
o.id_osrodek,
o.nazwa_o
FROM osrodki o 
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
WHERE UPPER(p.nazwa_p) = 'BAZY DANYCH'
INTERSECT
SELECT DISTINCT
o.id_osrodek,
o.nazwa_o
FROM osrodki o 
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
WHERE UPPER(p.nazwa_p) <> 'ARKUSZE KALKULACYJNE'
ORDER BY 2

/* 60
W których ośrodkach poszczególni egzaminatorzy egzaminowali poszczególnych
studentów? Dla każdego egzaminatora wskazać studentów egzaminowanych przez niego
oraz miejsce przeprowadzenia egzaminu. Do identyfikacji egzaminatora i studenta użyć
ich identyfikatorów, imion i nazwisk. Natomiast do określenia ośrodka – identyfikatora i
nazwy ośrodka. Uporządkować rezultat w taki sposób, aby można było zapewnić
czytelność wyniku i możliwość spójnej i prawidłowej jego interpretacji. */
SELECT DISTINCT
eg.id_egzaminator || ' ' || eg.nazwisko || ' ' || eg.imie AS "Egzaminator",
s.id_student || ' ' || s.nazwisko || ' ' || s.imie AS "Student",
o.id_osrodek || ' ' || o.nazwa_o AS "Ośrodek"
FROM egzaminatorzy eg 
INNER JOIN egzaminy e ON eg.id_egzaminator = e.id_egzaminator
INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
INNER JOIN studenci s ON s.id_student = e.id_student
ORDER BY 1, 2

/* 61
Kiedy studenci zdawali egzaminy z poszczególnych przedmiotów? W odpowiedzi
uwzględnić także tych studentów, którzy jeszcze nie przystąpili do egzaminu. Dla każdego
studenta należy wskazać przedmiot oraz datę egzaminu z tego przedmiotu. Do
identyfikacji studenta użyć identyfikatora, Imienia i nazwiska. Natomiast dla przedmiotu –
nazwy przedmiotu. Ponadto uporządkować malejąco wynik zapytania według daty
egzaminu i zapewnić możliwość spójnej i poprawnej interpretacji otrzymanego wyniku. */
SELECT 
s.id_student AS "ID studenta",
s.nazwisko || ' ' || s.imie AS "Nazwisko i imię studenta",
p.nazwa_p AS "Przedmiot",
e.data_egz AS "Data egzaminu"
FROM studenci s 
LEFT JOIN egzaminy e ON e.id_student = s.id_student
INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
ORDER BY 1, 4 DESC

/* 62
Którzy egzaminatorzy nie przeprowadzili egzaminów w poszczególnych ośrodkach? Dla
każdego ośrodka podać identyfikator, imię i Nazwisko egzaminatora, który nie
egzaminował w danym ośrodku. Uporządkować rezultat według identyfikatora ośrodka
oraz identyfikatora egzaminatora. */
SELECT
o.id_osrodek,
o.nazwa_o,
egz.id_egzaminator,
egz.imie || ' ' || egz.nazwisko
FROM egzaminatorzy egz
CROSS JOIN osrodki o
MINUS
SELECT DISTINCT
o.id_osrodek,
o.nazwa_o,
egz.id_egzaminator,
egz.imie || ' ' || egz.nazwisko
FROM egzaminatorzy egz
INNER JOIN egzaminy e ON e.id_egzaminator = egz.id_egzaminator
INNER JOIN osrodki o ON e.id_osrodek = o.id_osrodek
ORDER BY 1, 3

/* 63
W których ośrodkach przeprowadzono egzaminy z przedmiotu o nazwie Bazy danych
i Arkusze kalkulacyjne, a nie przeprowadzono egzaminu z przedmiotu o nazwie
Przetwarzanie tekstów? Podać identyfikator oraz nazwę ośrodka. Rezultat uporządkować
wg nazwy ośrodka.  */
SELECT 
o.id_osrodek,
o.nazwa_o
FROM osrodki o 
INNER JOIN egzaminy e ON e.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
WHERE UPPER(p.nazwa_p) = 'BAZY DANYCH' 
INTERSECT
SELECT 
o.id_osrodek,
o.nazwa_o
FROM osrodki o 
INNER JOIN egzaminy e ON e.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
WHERE UPPER(p.nazwa_p) = 'ARKUSZE KALKULACYJNE'
MINUS
SELECT 
o.id_osrodek,
o.nazwa_o
FROM osrodki o 
INNER JOIN egzaminy e ON e.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
WHERE UPPER(p.nazwa_p) = 'PRZETWARZANIE TEKSTÓW' 
ORDER BY 2

/* 64
Który student zdawał egzaminy w okresie od 01 stycznia 2000 do 31 marca 2000, a nie
zdawał egzaminów w okresie od 1 lipca 2002 do 31 grudnia 2002? Podać jego
identyfikator, imię i Nazwisko. Otrzymany wynik uporządkować wg nazwiska i Imienia
studenta.  */
SELECT DISTINCT
s.id_student,
s.imie,
s.nazwisko
FROM studenci s 
INNER JOIN egzaminy e ON e.id_student = s.id_student
WHERE e.data_egz BETWEEN to_date('2005-01-01', 'yyyy-mm-dd') AND to_date('2005-03-31', 'yyyy-mm-dd')
MINUS 
SELECT DISTINCT
s.id_student,
s.imie,
s.nazwisko
FROM studenci s 
INNER JOIN egzaminy e ON e.id_student = s.id_student
WHERE e.data_egz BETWEEN to_date('2005-07-01', 'yyyy-mm-dd') AND to_date('2005-12-31', 'yyyy-mm-dd')
ORDER BY 3, 2

/* 65
Ile egzaminów przeprowadzono w każdym ośrodku? W odpowiedzi uwzględnić także te
ośrodki, w których egzaminu jeszcze nie przeprowadzono. Podać identyfikator i nazwę
ośrodka oraz liczbę egzaminów w każdym z nich. Nazwać odpowiednio kolumnę
z informacją o liczbie egzaminów. Uporządkować otrzymany rezultat nazwy ośrodka.  */
SELECT
o.id_osrodek,
o.nazwa_o,
COUNT(e.nr_egz) AS "Liczba egzaminów w ośrodku"
FROM osrodki o
LEFT JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
GROUP BY o.id_osrodek, o.nazwa_o
ORDER BY 2

/* 66
Ile egzaminów zdali poszczególni studenci? W odpowiedzi uwzględnić tylko tych
studentów, którzy przystąpili już do egzaminu. W odpowiedzi umieścić informację
identyfikującą studenta (identyfikator, Nazwisko, imię) oraz licznie zdanych egzaminów.
Nazwać odpowiednio kolumnę z informacją o liczbie egzaminów. Uporządkować
otrzymany rezultat według nazwiska i Imienia studenta.  */
SELECT 
s.id_Student,
s.nazwisko,
s.imie,
COUNT(*) AS "Liczba zdanych egzaminów przez studenta"
FROM studenci s 
INNER JOIN egzaminy e ON s.id_student = e.id_student 
WHERE zdal = 'T'
GROUP BY s.id_Student, s.nazwisko, s.imie
ORDER BY 2, 3

/* 67
W których ośrodkach przeprowadzono z przedmiotu o nazwie Bazy danych więcej niż 2
egzaminy? Podać identyfikator ośrodka oraz jego nazwę. Uporządkować otrzymany
rezultat według nazwy ośrodka. */
SELECT
o.id_osrodek,
o.nazwa_o,
COUNT(*) AS "Liczba egzaminów z baz danych"
FROM osrodki o 
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
WHERE UPPER(p.nazwa_p) = 'BAZY DANYCH'
GROUP BY o.id_osrodek, o.nazwa_o
HAVING COUNT(*) > 2
ORDER BY 2

/* 68
Ile egzaminów przeprowadzono w ośrodkach o nazwie CKMP oraz LBS. Dla każdego
ośrodka o podanej nazwie określić liczbę przeprowadzonych egzaminów. W odpowiedzi
umieścić informację o identyfikatorze ośrodka, jego nazwie oraz liczbie egzaminów
w każdym z w/w ośrodków. Nazwać odpowiednio kolumnę z informacją o liczbie
egzaminów. Uporządkować otrzymany rezultat według nazwy ośrodka.  */
SELECT
o.id_osrodek,
o.nazwa_o,
COUNT(e.nr_egz) AS "Liczba egzaminów w ośrodku"
FROM osrodki o 
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
WHERE o.nazwa_o IN ('CKMP', 'LBS')
GROUP BY o.id_osrodek, o.nazwa_o
ORDER BY 2

/* 69
Podać datę pierwszego i ostatniego egzaminu przeprowadzonego przez każdego
egzaminatora. W odpowiedzi uwzględnić także tych egzaminatorów, którzy jeszcze nie
przystąpili do egzaminu. Nazwać odpowiednio kolumny z informacją o podanych datach.
Uporządkować wynik zapytania wg nazwiska i Imienia egzaminatora.  */
SELECT
egz.id_egzaminator,
egz.imie,
egz.nazwisko,
MIN(e.data_egz) AS "Data pierwszego egzaminu",
MAX(e.data_egz) AS "Data ostatniego egzaminu"
FROM egzaminatorzy egz 
LEFT JOIN egzaminy e ON egz.id_egzaminator = e.id_egzaminator
GROUP BY egz.id_egzaminator, egz.imie, egz.nazwisko
ORDER BY 3, 2

/* 70
W których ośrodkach przeprowadzono więcej niż 4 egzaminy? Podać identyfikator
ośrodka, jego nazwę oraz miasto. Uporządkować rezultat według identyfikatora ośrodka.  */
SELECT
o.id_osrodek,
o.nazwa_o,
o.miasto
FROM osrodki o
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
GROUP BY o.id_osrodek, o.nazwa_o, o.miasto
HAVING COUNT(e.nr_egz) > 4
ORDER BY 1

/* 71
W ilu ośrodkach student o identyfikatorze '0000009' zdawał swoje egzaminy?
W odpowiedzi podać informację o Imieniu i nazwisku studenta oraz liczbie ośrodków.
Nazwać odpowiednio kolumnę z informacją o liczbie ośrodków. */
SELECT
s.imie,
s.nazwisko,
COUNT(DISTINCT e.id_osrodek) AS "Liczba ośrodków"
FROM studenci s 
INNER JOIN egzaminy e ON e.id_student = s.id_student
WHERE s.id_student = '0000009'
GROUP BY s.id_student, s.imie, s.nazwisko

/* 72
Którzy studenci zdawali egzaminy tylko w jednym ośrodku? Podać ich identyfikator,
Nazwisko i imię. Uporządkować wynik zapytania wg nazwiska i Imienia studenta. */
SELECT
s.id_student,
s.imie,
s.nazwisko,
COUNT(DISTINCT e.id_osrodek) AS "Liczba ośrodków"
FROM studenci s 
INNER JOIN egzaminy e ON e.id_student = s.id_student
GROUP BY s.id_student, s.imie, s.nazwisko
HAVING COUNT(DISTINCT e.id_osrodek) = 1
ORDER BY 3, 2

/* 73
Podać datę pierwszego i ostatniego egzaminu z przedmiotu o nazwie Bazy danych
w poszczególnych ośrodkach. Uwzględnić tylko te ośrodki, w których odbył się egzamin
z podanego przedmiotu. W odpowiedzi umieścić informację o ośrodku (identyfikator,
nazwa) oraz odpowiednich datach. Nazwać odpowiednio kolumny z informacją
o podanych datach.  */
SELECT
o.id_osrodek,
o.nazwa_o,
MIN(e.data_egz) AS "Data pierwszego egzaminu",
MAX(e.data_egz) AS "Data ostatniego egzaminu"
FROM osrodki o 
INNER JOIN egzaminy e ON e.id_osrodek = o.id_osrodek
INNER JOIN przedmioty p ON p.id_przedmiot = e.id_przedmiot
WHERE UPPER(p.nazwa_p) = 'BAZY DANYCH'
GROUP BY o.id_osrodek, o.nazwa_o

/* 74
Ile przedmiotów zdawał student o identyfikatorze '0000005' w ośrodku o nazwie CKMP?
Dla każdego ośrodka o podanej nazwie określić liczbę przedmiotów zdawanych przez tego
studenta. W odpowiedzi umieścić identyfikator i nazwę ośrodka oraz liczbę zdawanych
przedmiotów. Nazwać odpowiednio kolumnę z informacją o liczbie przedmiotów.
Uporządkować wynik zapytania wg identyfikatora ośrodka. */
SELECT 
o.id_osrodek,
o.nazwa_o,
COUNT(DISTINCT e.id_przedmiot) AS "Liczba zdawanych przedmiotów"
FROM osrodki o 
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
WHERE e.id_student = '0000005' AND o.nazwa_o = 'CKMP'
GROUP BY o.id_osrodek, o.nazwa_o
ORDER BY 1

/* 75
Ilu studentów zdawało egzaminy z każdego przedmiotu? Uwzględnić także te przedmioty,
z których jeszcze nie było żadnego egzaminu. Podać nazwę przedmiotu, a liczbę osób
zdających dany przedmiot odpowiednio opisać. Uporządkować rezultat zapytania wg
nazwy przedmiotu */
SELECT
p.nazwa_p,
COUNT(DISTINCT e.id_student) AS "Liczba studentów zdajacych przedmiot"
FROM egzaminy e 
RIGHT JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot 
GROUP BY p.id_przedmiot, p.nazwa_p
ORDER BY 1

/* 76
Ile egzaminów przeprowadzono w poszczególnych ośrodkach z poszczególnych
przedmiotów? Dla każdego przedmiotu, opisanego przez jego nazwę i ośrodka, opisanego
przez identyfikator i nazwę, podać liczbę egzaminów. W odpowiedzi uwzględnić również
te przedmioty, z których jeszcze nie przeprowadzono żadnego egzaminu. Uporządkować
otrzymany wynik wg nazwy przedmiotu oraz identyfikatora ośrodka. */
SELECT
p.nazwa_p,
o.id_osrodek,
o.nazwa_o,
COUNT(e.nr_egz) AS "Liczba egzaminow"
FROM przedmioty p 
LEFT JOIN egzaminy e on p.id_przedmiot = e.id_przedmiot
INNER JOIN osrodki o ON e.id_osrodek = o.id_osrodek
GROUP BY p.nazwa_p, o.id_osrodek, o.nazwa_o
ORDER BY 1, 2

/* 77
Który egzaminator egzaminował więcej niż 5 osób w ośrodku o nazwie CKMP? Dla
każdego ośrodka o podanej nazwie wskazać egzaminatora, podając jego identyfikator, imię
oraz Nazwisko. Uporządkować otrzymany rezultat według identyfikatora ośrodka oraz
nazwiska i Imienia egzaminatora. */
SELECT 
o.id_osrodek,
o.nazwa_o,
egz.id_egzaminator,
egz.imie,
egz.nazwisko,
COUNT(DISTINCT e.id_student)
FROM osrodki o 
INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
INNER JOIN egzaminatorzy egz ON e.id_egzaminator = egz.id_egzaminator
WHERE o.nazwa_o = 'CKMP'
GROUP BY o.id_osrodek, o.nazwa_o, egz.id_egzaminator, egz.imie, egz.nazwisko
HAVING COUNT(DISTINCT e.id_student) > 5
ORDER BY 1, 4, 5

/* 78
Podać datę pierwszego i ostatniego egzaminu zdanego przez poszczególnych studentów.
Uwzględnić tylko tych studentów, którzy przystąpili już do egzaminu. Podać ich
identyfikator, imię i Nazwisko. Otrzymany wynik uporządkować wg nazwiska i Imienia
studenta. */
SELECT 
s.id_Student,
s.imie,
s.nazwisko,
MIN(e.data_egz) AS "Data pierwszego egzaminu",
MAX(e.data_egz) AS "Data ostatniego egzaminu"
FROM egzaminy e 
INNER JOIN studenci s ON e.id_Student = s.id_student
GROUP BY s.id_Student, s.imie, s.nazwisko
ORDER BY 3, 2

/* 79
Z którego przedmiotu w ośrodku o nazwie CKMP przeprowadzono więcej niż 5
egzaminów? Dla każdego ośrodka o podanej nazwie wskazać przedmiot, podając jego
nazwę. Uporządkować otrzymany rezultat według identyfikatora ośrodka oraz nazwy
przedmiotu. */
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
HAVING COUNT(e.nr_egz) > 5
ORDER BY 1, 3

/* 80
W których ośrodkach egzaminator o nazwisku Muryjas egzaminował więcej niż 3 osoby?
Odpowiedź podać dla każdego egzaminatora o wymienionym nazwisku. W odpowiedzi
należy umieścić informację o egzaminatorze (identyfikator, imię i Nazwisko), o ośrodku
(identyfikator i nazwę) oraz liczbie egzaminowanych osób w danym ośrodku.
Uporządkować otrzymany rezultat według identyfikatora egzaminatora oraz nazwy
ośrodka. */
SELECT
egz.id_egzaminator,
egz.imie,
egz.nazwisko,
o.id_osrodek,
o.nazwa_o,
COUNT(DISTINCT e.id_Student) AS "Liczba egzaminowanych osób"
FROM egzaminatorzy egz
INNER JOIN egzaminy e ON egz.id_egzaminator = e.id_egzaminator
INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
WHERE egz.nazwisko = 'Muryjas'
GROUP BY egz.id_egzaminator, egz.imie, egz.nazwisko, o.id_osrodek, o.nazwa_o
HAVING COUNT(DISTINCT e.id_Student) > 3
ORDER BY 1, 5

/* 81
Ile egzaminów zdawali i ile zdali poszczególni studenci? Dla każdego studenta, który
przystąpił do egzaminu podać liczbę zdawanych przez niego egzaminów oraz liczbę
zdanych przez niego egzaminów. W odpowiedzi umieścić informację o studencie
(identyfikator, Nazwisko, imię), liczbie zdawanych i zdanych egzaminów. Opisać
odpowiednio prezentowane liczby egzaminów. */
SELECT
s.id_Student,
s.imie,
s.nazwisko,
COUNT(e.nr_egz) AS "Liczba podejść do egzaminów",
COUNT(e.punkty) AS "Liczba zdanych egzaminów"
FROM studenci s 
INNER JOIN egzaminy e ON s.id_student = e.id_student
GROUP BY s.id_Student, s.imie, s.nazwisko
ORDER BY 1