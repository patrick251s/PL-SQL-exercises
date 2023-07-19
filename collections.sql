/* 223
Utworzyć tabelę zagnieżdżoną o nazwie NT_Osrodki, której elementy będą rekordami.
Każdy rekord zawiera dwa pola: Id oraz Nazwa, odnoszące się odpowiednio do
identyfikatora i nazwy ośrodka. Następnie zainicjować tabelę, wprowadzając do jej
elementów kolejne ośrodki z tabeli Osrodki. Po zainicjowaniu wartości elementów należy
wyświetlić ich wartości. Dodatkowo określić i wyświetlić liczbę elementów powstałej
tabeli zagnieżdżonej. */
DECLARE
    TYPE recTypeOsr IS RECORD (id NUMBER, nazwa VARCHAR2(50)); --rekord tabeli
    TYPE colTypeOsr IS TABLE OF recTypeOsr; --tabela rekordow
    colOsr colTypeOsr := colTypeOsr(); --kolekcja o typie colTypeOsr
    CURSOR c1 IS SELECT id_osrodek, nazwa_osrodek FROM osrodki ORDER BY 1;
    i NUMBER := 1;
BEGIN
    FOR vc1 IN c1 LOOP
        colOsr.extend; --rozszerzenie musi być 
        colOsr(i).id := vc1.id_osrodek;
        colOsr(i).nazwa := vc1.nazwa_osrodek;
        i := i+1;
    END LOOP;
    FOR j IN colOsr.first..colOsr.last LOOP
        DBMS_OUTPUT.PUT_LINE(colOsr(j).id || ' ' || colOsr(j).nazwa);
    END LOOP;
END;

/* 224
Zmodyfikować kod źródłowy w poprzednim zadaniu tak, aby po zainicjowaniu tabeli
zagnieżdżonej usunąć z niej elementy, zawierające ośrodki, w których nie przeprowadzono
egzaminu. Dokonać sprawdzenia poprawności wykonania zadania, wyświetlając elementy
tabeli po wykonaniu operacji usunięcia. Zadanie rozwiązać z wykorzystaniem
podprogramów PL/SQL. */
--SPRAWDZIĆ SOBIE JAK ZACHOWUJE SIĘ USUWANIE
DECLARE
    TYPE recTypeOsr IS RECORD (id NUMBER, nazwa VARCHAR2(50)); --rekord tabeli
    TYPE colTypeOsr IS TABLE OF recTypeOsr; --tabela rekordow
    colOsr colTypeOsr := colTypeOsr(); --kolekcja o typie colTypeOsr
    CURSOR c1 IS SELECT id_osrodek, nazwa_osrodek FROM osrodki ORDER BY 1;
    i NUMBER := 1;
    pom NUMBER := 0 ;
BEGIN
    FOR vc1 IN c1 LOOP
        colOsr.extend; --rozszerzenie musi być 
        colOsr(i).id := vc1.id_osrodek;
        colOsr(i).nazwa := vc1.nazwa_osrodek;
        i := i+1;
    END LOOP;
    FOR j IN colOsr.first..colOsr.last LOOP
        SELECT COUNT(1) INTO pom FROM egzaminy WHERE ID_Osrodek = colOsr(j).id;
        IF pom < 1 THEN
            colOsr.DELETE(j);
        END IF;
    END LOOP;
    for j in colOsr.first..colOsr.last loop
        IF(colOsr.EXISTS(j)) 
            THEN dbms_output.put_line(colOsr(j).id || ' - ' || colOsr(j).nazwa) ;
        END IF;
    end loop;
END;

/* 225
Utworzyć tabelę bazy danych o nazwie Indeks. Tabela powinna zawierać informacje o
studencie (identyfikator, Nazwisko, imię), przedmiotach (nazwa przedmiotu), z których
student zdał już swoje egzaminy oraz datę zdanego egzaminu. Lista przedmiotów wraz z
datami dla danego studenta powinna być kolumną typu tabela zagnieżdżona. Dane w tabeli
Indeks należy wygenerować na podstawie zawartości tabeli Egzaminy, Studenci oraz Przedmioty.*/
CREATE TYPE Typ_ListaPrzedmiotow_Obj AS OBJECT (nazwa_przedmiot VARCHAR2(40), data_zdania DATE);
CREATE TYPE Typ_ListaPrzedmiotow_Table IS TABLE OF Typ_ListaPrzedmiotow_Obj;
CREATE TABLE Indeks ( 
    id_student VARCHAR2(20),
    nazwisko VARCHAR2(40),
    imie VARCHAR2(40),
    przedmioty Typ_ListaPrzedmiotow_Table) NESTED TABLE przedmioty STORE AS Przedmioty_tabela;
    
--ZROBIĆ FUNKCJĘ KTÓRA ZWRÓCI KOLEKCJĘ DLA STUDENTA    
DECLARE
    CURSOR c1 IS SELECT id_Student FROM studenci;
    listaPrzedmiotowStudenta Typ_ListaPrzedmiotow_Table := Typ_ListaPrzedmiotow_Table();
    FUNCTION getStudentCollection(studentID studenci,id_student%TYPE) RETURN Typ_ListaPrzedmiotow_Table IS
        listaPrzedmiotowStudenta Typ_ListaPrzedmiotow_Table := Typ_ListaPrzedmiotow_Table();
    BEGIN
    
    END getStudentCollection;
BEGIN
    FOR vc1 IN c1 LOOP
        
    END LOOP;
END;

DECLARE
    i NUMBER := 0 ;
    przed Typ_ListaPrzedmiotow_Table;
    cursor c_student IS SELECT DISTINCT E.id_student, S.nazwisko, S.imie
    FROM Egzaminy E JOIN Studenci S ON S.id_student = E.id_student ;
    cursor c_data (p_IdStud VARCHAR2) IS SELECT P.nazwa_przedmiot nazwaP, E.data_egzamin dataE
    FROM Egzaminy E JOIN Przedmioty P ON P.id_przedmiot = E.id_przedmiot WHERE Zdal = 'T' AND E.id_student = p_IdStud ;
BEGIN
    FOR vc1 IN c_student LOOP
        przed := Typ_ListaPrzedmiotow_Table();
        i := 0;
        FOR vc2 IN c_data(vc1.id_student) LOOP
            /*przed.EXTEND ;
            przed(i).nazwa_przedmiot := vc2.nazwaP ;
            przed(i).data_zdania := vc2.dataE ;*/
            DBMS_OUTPUT.PUT_LINE(i);
            i := i+1;
        END LOOP ;
        --INSERT INTO Indeks values (vc1.id_student, vc1.nazwisko, vc1.imie, przed) ;
    END LOOP ;
END ;

/* 232 zmodyfikowane
Utworzyć tabelę o zmiennym rozmiarze (o niezmiennym - nested) i nazwać ją VT_Studenci. Tabela powinna zawierać
elementy opisujące liczbę egzaminów każdego studenta. Zainicjować wartości elementów
na podstawie danych z tabel Studenci i Egzaminy. Zapewnić, by studenci umieszczeni w
kolejnych elementach uporządkowani byli wg liczby zdawanych egzaminów, od
największej do najmniejszej. Po zainicjowaniu tabeli, wyświetlić wartości znajdujące się w
poszczególnych jej elementach. 
*/
-- 1. deklaracja typu rekordowego, ktory opisze id studenta, nazwisko, imie, liczba egzaminow i liczba pkt
-- 2. deklaracja typu kolekcji, który będzie tabelą zagnieżdżona i określenie typu danych elementów kolekcji
-- 3. deklaracja zmiennej będącej kolekcją o typie zadeklarowanym w kroku nr 2
-- 4. można zainicjować kolekcję
-- 5. deklaracja kursora, który będzie generował dane przechowywane jako elementy kolekcji (opcjonalnie) albo użyć kursora niejawnego
-- 6. w pętli uzupełnić elementy kolekcji danymi z kursora
-- 7. wyświelić elementy kolekcji
declare
    type typ_rek_stud is record
                         (
                             id_student VARCHAR(7),
                             imie VARCHAR(40),
                             nazwisko VARCHAR(40),
                             liczba_egz number,
                             punkty number
                         );
    type typ_tab_stud is table of typ_rek_stud;
    tab_stud typ_tab_stud := typ_tab_stud();
    
    --Patryk Kaźmierak
    CURSOR c1 IS 
    SELECT s.id_student idS, s.nazwisko nazwisko, s.imie imie, COUNT(e.id_egzamin) liczbaEgz, COALESCE(SUM(e.punkty), 0) liczbaP 
    FROM studenci s LEFT JOIN egzaminy e ON s.id_student = e.id_student
    GROUP BY s.id_student, s.nazwisko, s.imie ORDER BY 5 DESC;
  
  -- Damian Flis
begin
    for vc1 in c1 loop
        tab_stud.EXTEND ;
        tab_stud(c1%rowcount) := typ_rek_stud(vc1.idS, vc1.nazwisko, vc1.imie, vc1.liczbaEgz, vc1.liczbaP) ;
    end loop ;
    
    for i in 1 .. tab_stud.count() loop
    dbms_output.put_line(
       tab_stud(i).id_student || ', '
        || tab_stud(i).imie || ', '
        || tab_stud(i).nazwisko || ', '
        || tab_stud(i).liczba_egz ||', '
        || tab_stud(i).punkty);
	end loop;
end ;

/* 234 nested table
Utworzyć tabelę w bazie danych o nazwie Przedmioty_Terminy. Tabela powinna zawierać
dwie kolumny: nazwę przedmiotu oraz tabelę o zmiennej długości, zawierającą daty
egzaminów z każdego przedmiotu. Następnie wstawić do tabeli Przedmioty_Terminy
rekordy na podstawie danych z tabeli Egzaminy i Przedmioty. Przed wstawieniem danych
do tabeli, należy je wyświetlić, porządkując wg nazwy przedmiotu. */
-- (nested table, uporządkować daty egzaminów z przedmiotu od najnowszej do nastarszej)
  -- 1. utworzenie w bazie danych typu kolekcji, której elementy będą typu DATE
  -- 2. utworzenie w bazie danych tabeli o nazwie Przedmioty_Terminy. Pierwsza kolumna to nazwa przedmiotu. Druga kolumna - kolekcją o typie uprzednio utworzonym.
  -- 3. deklaracja zmiennej o zadeklarowanym typie kolekcji
  -- 4. definicja kursora, który będzie zawierał przedmioty
  -- 5. dla każdego przedmiotu zbudujemy kolekcję dat egzaminów z tego przedmiotu (wyznaczenie kolekcji będzie zrealizowane w funkcji PL/SQL)
  -- 6. wstawienie rekordu z przedmiotem i datami do tabeli Przedmioty_Terminy, poprzedzone wyświetleniem wstawianych danych.
create or replace type listaDatEgzaminow is table of date;
create table Przedmioty_Terminy(nazwaPrzedmiot VARCHAR(100), daty listaDatEgzaminow) nested table daty store as analityka_egzaminatorzy_nt;
DECLARE
    mListaDat listaDatEgzaminow := listaDatEgzaminow();
    CURSOR c1 IS SELECT id_przedmiot FROM Przedmioty;
    FUNCTION zwrocDatyEgzaminow(idP VARCHAR) RETURN listaDatEgzaminow IS
        CURSOR c2 IS SELECT DISTINCT data_egzamin FROM Egzaminy WHERE id_przedmiot = idP ORDER BY 1 DESC;
        mListaDat2 listaDatEgzaminow := listaDatEgzaminow(); 
        i NUMBER;
    BEGIN
        FOR vc2 IN c2 LOOP
            mListaDat2.EXTEND;
            i := c2%ROWCOUNT;
            mListaDat2(i) := vc2.data_egzamin;
        END LOOP;
        RETURN mListaDat2;
    END zwrocDatyEgzaminow;
BEGIN
    FOR vc1 IN c1 LOOP
        mListaDat := zwrocDatyEgzaminow(vc1.id_przedmiot);
    END LOOP;
END;

/*
dod. zadanie nr 1 
(Utworzyć w bazie danych tabelę o nazwie EgzaminatorzyAnaliza. 
Tabela powinna zawierać informacje o liczbie egzaminów dla każdego egzaminatora przeprowadzonych w poszczególnych miesiącach dla kolejnych lat. 
W tabeli utworzyć 4 kolumny. Trzy pierwsze opisują egzaminatora (id, nazwisko, imie). 
czwarta kolumna opisuje rok, miesiąc i liczbę egzaminów danego egzaminatora w danym miesiącu danego roku. 
Dane dotyczące roku, miesiąca i liczby egzaminów należy umieścić w kolumnie będącej kolekcją typu tablica zagnieżdżona. 
Wprowadzić dane do tabeli EgzaminatorzyAnaliza na podstawie danych zgromadzonych tabelach Egzaminatorzy i Egzaminy. 
Następnie wyświetlić dane znajdujące się w tabeli EgzaminatorzyAnaliza.)
1. Utworzenie w bazie danych typu rekordowego, który opisze rok, miesiąc i liczbę egzaminów.
2. Utworzenie w bazie danych typu kolekcji, której elementy będą typu zdefiniowanego w 1 kroku.
3. Utworzenie tabeli w bazie danych, której kolumny opisują egzaminatora (3 pierwsze kolumny) i liczbę egzaminów w poszczególnych miesiącach kolejnych lat (czwarta kolumna będąca kolekcją).
4. Deklaracja kursora, który będzie opisywał poszczególnych egzaminatorów. Uwzględnić wszystkich egzaminatorów.
5. Dla każdego egzaminatora, otrzymanego w kursorze z p.4, tworzymy kolekcję danych o liczbie egzaminów w w poszczególnych miesiącach kolejnych lat.
6. Wstawiamy do tabeli dane o egzaminatorze i kolekcję otrzymaną w p. 5.
7. Po wstawieniu wszystkich egzaminatorów wyświetlić zawartość tabeli.
*/
CREATE TYPE Typ_DaneEgzaminu_Obj AS OBJECT (examYear VARCHAR(5), examMonth VARCHAR(3), examNumber INTEGER);
CREATE TYPE Typ_DaneEgzaminu_Table IS TABLE OF Typ_DaneEgzaminu_Obj;
CREATE TABLE EgzaminatorzyAnaliza(
id VARCHAR2(40),
imie VARCHAR2(50),
nazwisko VARCHAR2(50),
dane Typ_DaneEgzaminu_Table) NESTED TABLE dane STORE AS dane_egzaminu;
DECLARE
    CURSOR c1 IS SELECT id_egzaminator, nazwisko, imie FROM Egzaminatorzy;
    CURSOR c2(egzID VARCHAR2) IS 
        SELECT EXTRACT(YEAR FROM data_egzamin) examY, EXTRACT(MONTH FROM data_egzamin) examM, COUNT(id_egzamin) examNum FROM egzaminy 
        WHERE id_egzaminator = egzID 
        GROUP BY EXTRACT(YEAR FROM data_egzamin), EXTRACT(MONTH FROM data_egzamin)
        ORDER BY 1, 2;
    dane Typ_DaneEgzaminu_Table;
    i NUMBER := 0 ;
BEGIN
    FOR vc1 IN c1 LOOP
        i := 1;
        dane := Typ_DaneEgzaminu_Table();
        FOR vc2 IN c2(vc1.id_egzaminator) LOOP
            dane.EXTEND;
            dane(i) := Typ_DaneEgzaminu_Obj(vc2.examY, vc2.examM, vc2.examNum);
            i := i+1;
        END LOOP;
        INSERT INTO EgzaminatorzyAnaliza VALUES(vc1.id_egzaminator, vc1.imie, vc1.nazwisko, dane);
    END LOOP;
END;
SELECT ea.id, ea.imie, ea.nazwisko, nt.examyear, nt.exammonth, nt.examnumber FROM EgzaminatorzyAnaliza ea, TABLE(ea.dane) nt

/*zadanie nr 2 
(Utworzyć w bazie danych tabelę o nazwie StudenciAnaliza. 
Tabela powinna zawierać informacje o przedmiotach, z których student zdał egzamin i otrzymał odpowiednio największą i najmniejszą liczbę punktów.
W tabeli utworzyć 4 kolumny. Trzy pierwsze opisują studenta (id, nazwisko, imie). 
Czwarta kolumna opisuje przedmiot (nazwa) i liczbę otrzymanych punktów ze zdanego egzaminu. 
Dane dotyczące przedmiotu i liczby punktów należy umieścić w kolumnie będącej kolekcją typu tablica zagnieżdżona. 
Wprowadzić dane do tabeli StudenciAnaliza na podstawie danych zgromadzonych tabelach Studenci, Przedmioty i Egzaminy. 
Następnie wyświetlić dane znajdujące się w tabeli StudenciAnaliza.)
*/


/*zadanie nr 3 
Utworzyć w bazie danych tabelę o nazwie OsrodkiAnaliza. 
Tabela powinna zawierać informacje o ośrodku, roku i miesiącach z największą i najmniejszą liczbą egzaminów w danym ośrodku. 
W tabeli utworzyć 3 kolumny. Dwie pierwsze opisują ośrodek (id, nazwa). 
Trzecia kolumna opisuje rok, miesiąc i liczbę egzaminów w danym miesiącu danego roku. 
Dane dotyczące roku, miesiąca i liczby egzaminów należy umieścić w kolumnie będącej kolekcją typu tablica zagnieżdżona. 
Wprowadzić dane do tabeli OsrodkiAnaliza na podstawie danych zgromadzonych tabelach Osrodki i Egzaminy. 
Następnie wyświetlić dane znajdujące się w tabeli OsrodkiAnaliza.*/
CREATE OR REPLACE TYPE typ_rekordu_zad3 AS OBJECT (year VARCHAR2(10), month VARCHAR2(10), examNumber NUMBER);
CREATE OR REPLACE TYPE typ_kolekcji_zad3 IS TABLE OF typ_rekordu_zad3;
CREATE TABLE OsrodkiAnaliza (
    id_osrodek VARCHAR2(10),
    nazwa_osrodek VARCHAR2(50),
    dane typ_kolekcji_zad3 := typ_kolekcji_zad3();
) NESTED TABLE dane STORE AS dane_osrodka;
Propozycja:
declare
    cursor c1 is select distinct o.id_osrodek, nazwa_osrodek from osrodki o inner join egzaminy e
                                        on o.id_osrodek = e.id_osrodek ;
    function f1 (pido osrodki.id_osrodek%type) return typ_kolekcji_zad3 is
            cursor c2_Min is select extract(year from data_egzamin), extract(month from data_egzamin), count(*) LiczbaEx
                                from egzaminy e
                            where e.id_osrodek = pido 
                            group by extract(year from data_egzamin), extract(month from data_egzamin) 
                            having count(*) = ( select min(count(*))
                                                            from egzaminy e2
                                                            where id_osrodek = pido and extract(year from e2.data_egzamin) = extract(year from e.data_egzamin)
                                                            group by extract(month from e2.data_egzamin) 
                                                            )
                            union
                            select extract(year from data_egzamin), extract(month from data_egzamin), count(*) LiczbaEx
                                from egzaminy e
                            where e.id_osrodek = pido 
                            group by extract(year from data_egzamin), extract(month from data_egzamin) 
                            having count(*) = ( select max(count(*))
                                                            from egzaminy e2
                                                            where id_osrodek = pido and extract(year from e2.data_egzamin) = extract(year from e.data_egzamin)
                                                            group by extract(month from e2.data_egzamin) 
                                                            )
                            order by 1 ;
            colTime typ_kolekcji_zad3 ;
    begin
        for vc2 in c2_Min loop
            null;
            -- populate data for many years and selected month when min value in month and max value in month
        end loop ;
        
    end ;
begin
        for vc1 in c1 loop
                null;     
        end loop ;
end ;
