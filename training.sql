/*Zadanie 1
Który student zdawał w jednym miesiącu więcej niż 10 egzaminów? Zadanie należy rozwiązać przy użyciu techniki wyjątków (jeśli to konieczne, można dodatkowo zastosować kursory). 
W odpowiedzi proszę umieścić pełne dane studenta (identyfikator, nazwisko, imię), rok i nazwę miesiąca oraz liczbę egzaminów.
*/
DECLARE
    ex EXCEPTION;
    monthname VARCHAR2(20);
    CURSOR c1 IS 
    SELECT s.id_student idStudent, s.imie imie, s.nazwisko nazwisko, EXTRACT(MONTH FROM e.data_egzamin) miesiac, COUNT(e.id_egzamin) liczba_egzaminow 
    FROM studenci s INNER JOIN egzaminy e ON s.id_student = e.id_student
    GROUP BY s.id_student, s.imie, s.nazwisko, EXTRACT(MONTH FROM e.data_egzamin) ORDER BY 1;
BEGIN 
    FOR vc1 IN c1 LOOP
    BEGIN
        IF vc1.liczba_egzaminow > 10 THEN
            RAISE ex;
        END IF;
        EXCEPTION
            WHEN ex THEN
                monthname := to_char(to_date(vc1.miesiac, 'MM'), 'Month');
                DBMS_OUTPUT.PUT_LINE(vc1.idStudent || ' ' || vc1.imie || ' ' || vc1.nazwisko || ' ' || 'miesiac:' || monthname || ' Liczba_egzaminow: ' || vc1.liczba_egzaminow);
    END;
    END LOOP;
END;

/*Zadanie 2
Dla każdego studenta wyznaczyć liczbę jego egzaminów. Jeśli student nie zdawał żadnego egzaminu, wyświetlić liczbę 0 (zero). 
Liczbę egzaminów danego studenta należy wyznaczyć przy pomocy funkcji PL/SQL. 
Wynik w postaci listy studentów i liczby ich egzaminów przedstawić w postaci posortowanej wg nazwiska i imienia studenta.
*/
DECLARE
    CURSOR c1 IS SELECT id_student, imie, nazwisko FROM studenci ORDER BY 3, 2;
    FUNCTION getStudentExam(idS studenci.id_student%TYPE) RETURN NUMBER IS
        examN NUMBER;
    BEGIN
        SELECT COUNT(id_egzamin) INTO examN FROM egzaminy WHERE id_student = idS;
        RETURN examN;
    END getStudentExam;
BEGIN
    FOR vc1 IN c1 LOOP
        DBMS_OUTPUT.PUT_LINE(vc1.id_student||' '||vc1.nazwisko||' '||vc1.imie||' Liczba egzaminow = '||getStudentExam(vc1.id_student));
    END LOOP;
END;

/*Zadanie 3
Utworzyć kolekcję typu tablica zagnieżdżona i nazwać ją NT_Studenci. 
Kolekcja powinna zawierać elementy opisujące datę ostatniego egzaminu poszczególnych studentów. 
Zainicjować wartości elementów kolekcji na podstawie danych z tabel Studenci i Egzaminy. 
Do opisu studenta należy użyć jego identyfikatora, nazwiska i imienia. 
Zapewnić, by elementy kolekcji uporządkowane były wg daty egzaminu, od najstarszej do najnowszej (tzn. pierwszy element kolekcji zawiera studenta, który zdawał najwcześniej egzamin). 
Po zainicjowaniu kolekcji, wyświetlić wartości znajdujące się w poszczególnych jej elementach.
*/
DECLARE 
    TYPE recType IS RECORD (id_student VARCHAR2(20), nazwisko VARCHAR2(50), imie VARCHAR2(50), data_ost_egz DATE);
    TYPE NT_Studenci IS TABLE OF recType;
    CURSOR c1 IS 
        SELECT DISTINCT s.id_student idS, s.imie imie, s.nazwisko nazwisko, MAX(e.data_egzamin) last_data FROM studenci s 
        INNER JOIN egzaminy e ON s.id_student = e.id_student
        GROUP BY s.id_student, s.imie, s.nazwisko
        ORDER BY 4;
    kolekcja NT_Studenci := NT_Studenci();
    i NUMBER := 1;
BEGIN
    FOR vc1 IN c1 LOOP
        kolekcja.EXTEND;
        kolekcja(i) := recType(vc1.idS, vc1.nazwisko, vc1.imie, vc1.last_data);
        i := i+1;
    END LOOP;
    FOR j IN 1 .. kolekcja.COUNT() LOOP
        DBMS_OUTPUT.PUT_LINE(kolekcja(j).id_student||' ' ||kolekcja(j).imie||' ' ||kolekcja(j).nazwisko||'   Data ostatniego egzaminu: '||kolekcja(j).data_ost_egz);
	END LOOP;
END;


/*Zadanie 4
Utworzyć w bazie danych tabelę o nazwie EgzaminatorzyAnaliza. 
Tabela powinna zawierać informacje o liczbie studentów egzaminowanych przez poszczególnych egzaminatorów w kolejnych miesiącach w poszczególnych latach.
W tabeli utworzyć 4 kolumny. 
Trzy pierwsze kolumny będą opisywać egzaminatora, tj. jego ID, nazwisko i imię.
Czwarta kolumna będzie opisywać rok, miesiąc i liczbę osób egzaminowanych przez danego egzaminatora w danym miesiącu danego roku. 
Dane dotyczące roku, miesiąca i liczby studentów należy umieścić w kolumnie będącej kolekcją typu tablica zagnieżdżona. 
Wprowadzić dane do tabeli EgzaminatorzyAnaliza na podstawie danych zgromadzonych tabelach Egzaminatorzy i Egzaminy.
Następnie wyświetlić dane znajdujące się w tabeli EgzaminatorzyAnaliza. 
*/
CREATE OR REPLACE TYPE type_object_exam IS OBJECT (rok VARCHAR2(20), miesiac VARCHAR2(50), liczba_osob NUMBER);
CREATE OR REPLACE TYPE type_table_exam IS TABLE OF type_object_exam;
CREATE TABLE EgzaminatorzyAnaliza2(
    id_egzaminator VARCHAR2(20),
    imie VARCHAR2(50),
    nazwisko VARCHAR2(50),
    kolekcja type_table_exam
) NESTED TABLE kolekcja STORE AS EgzaminatorzyAnalizaStored;
DECLARE
    kolekcja type_table_exam;
    CURSOR c1 IS SELECT id_egzaminator, imie, nazwisko FROM egzaminatorzy;
    FUNCTION getStudentNumber(idEgzaminator egzaminatorzy.id_egzaminator%TYPE) RETURN type_table_exam IS
        CURSOR c2 IS 
            SELECT EXTRACT(YEAR FROM data_egzamin) rok, EXTRACT(MONTH FROM data_egzamin) miesiac, COUNT(DISTINCT id_student) liczba_s 
            FROM egzaminy 
            WHERE id_egzaminator = idEgzaminator
            GROUP BY EXTRACT(YEAR FROM data_egzamin), EXTRACT(MONTH FROM data_egzamin)
            ORDER BY 1, 2;
        kolekcja type_table_exam := type_table_exam();
        i NUMBER := 1;
    BEGIN
        FOR vc2 IN c2 LOOP
            kolekcja.EXTEND;
            kolekcja(i) := type_object_exam(vc2.rok, vc2.miesiac, vc2.liczba_s);
            i := i+1;
        END LOOP;
        RETURN kolekcja;
    END getStudentNumber;
BEGIN
    FOR vc1 IN c1 LOOP
        kolekcja := getStudentNumber(vc1.id_egzaminator);
        INSERT INTO EgzaminatorzyAnaliza2 VALUES (vc1.id_egzaminator, vc1.imie, vc1.nazwisko, kolekcja);
    END LOOP;
END;

SELECT ea.id_egzaminator, ea.imie, ea.nazwisko, nt.rok, nt.miesiac, nt.liczba_osob FROM EgzaminatorzyAnaliza2 ea, TABLE(ea.kolekcja) nt;

/*Zadanie 5
Proszę wskazać tych egzaminatorów, którzy przeprowadzili egzaminy w dwóch ostatnich dniach egzaminowania z każdego przedmiotu. 
Jeśli z danego przedmiotu nie było egzaminu, proszę wyświetlić komunikat "Brak egzaminów".
W odpowiedzi należy umieścić nazwę przedmiotu, datę egzaminu (w formacie DD-MM-YYYY) oraz identyfikator, nazwisko i imię egzaminatora. 
Zadanie należy wykonać z użyciem kursora. 
*/
DECLARE
    CURSOR c1 IS SELECT p.id_przedmiot idP, p.nazwa_przedmiot nazwaP FROM przedmioty p;
    CURSOR c2(idP NUMBER) IS SELECT DISTINCT data_egzamin FROM egzaminy WHERE id_przedmiot = idP ORDER BY 1 DESC FETCH FIRST 2 ROWS ONLY;
    CURSOR c3(idP NUMBER, dataE VARCHAR2) IS 
        SELECT DISTINCT eg.id_egzaminator, eg.imie, eg.nazwisko FROM egzaminatorzy eg INNER JOIN egzaminy e ON eg.id_egzaminator = e.id_egzaminator 
        WHERE e.id_przedmiot = idP AND e.data_egzamin = dataE;
    data_egzaminu DATE;
    idE VARCHAR2(10);
    imie VARCHAR2(50);
    nazwisko VARCHAR2(50);
    czy_byl_egzamin_data BOOLEAN;
BEGIN
    FOR vc1 IN c1 LOOP
       OPEN c2(vc1.idP);
       IF c2%ISOPEN THEN
            czy_byl_egzamin_data := FALSE;
            LOOP
                FETCH c2 INTO data_egzaminu;
                EXIT WHEN c2%NOTFOUND;
                czy_byl_egzamin_data := TRUE;
                OPEN c3(vc1.idP, data_egzaminu);
                IF c3%ISOPEN THEN
                    LOOP
                        FETCH c3 INTO idE, imie, nazwisko;
                        EXIT WHEN c3%NOTFOUND;
                        DBMS_OUTPUT.put_line(vc1.nazwaP||' '||to_char(data_egzaminu, 'dd-mm-yyyy')||' '||idE||' '||imie||' '||nazwisko);  
                    END LOOP;
                END IF;
                CLOSE c3;
            END LOOP;
       END IF;
       IF czy_byl_egzamin_data = FALSE THEN
            DBMS_OUTPUT.put_line(vc1.nazwaP||' brak egzaminow!'); 
       END IF;
       CLOSE c2;
    END LOOP;
END;
/*
Dla każdego ośrodka, w którym odbył się egzamin, wyznaczyć liczbę studentów, którzy byli egzaminowani w danym ośrodku w kolejnych latach. 
Liczbę egzaminowanych studentów należy wyznaczyć przy pomocy funkcji PL/SQL.
Wynik w postaci listy ośrodków i w/w liczb przedstawić w postaci posortowanej wg nazwy ośrodka i numeru roku.
*/
DECLARE
    stuNum NUMBER;
    CURSOR c1 IS SELECT o.id_osrodek idOsrodek, o.nazwa_osrodek nazwaO, extract(year from e.data_egzamin) eYear FROM osrodki o INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek ORDER BY 1,2, 3;
    FUNCTION getExamNumByOsrodek(idOsrodek osrodki.id_osrodek%TYPE, examYear VARCHAR2) RETURN NUMBER IS
        stuN number;
        CURSOR c2 IS SELECT e.id_osrodek, extract(year from e.data_egzamin), COUNT(DISTINCT e.id_student) stuNumber  FROM egzaminy e 
        WHERE e.id_osrodek = idOsrodek AND extract(year from e.data_egzamin) = examYear GROUP BY e.id_osrodek, extract(year from e.data_egzamin);
    BEGIN
        FOR vc2 IN c2 LOOP
            stuN := vc2.stuNumber;
        END LOOP;
        RETURN stuN;
    END getExamNumByOsrodek;
BEGIN
    FOR vc1 IN c1 LOOP 
        stuNum := getExamNumByOsrodek(vc1.idOsrodek, vc1.eYear);
        DBMS_OUTPUT.put_line('W ośrodek o ID=' || vc1.idOsrodek || ' egzaminowano '|| stuNum ||' studentow w roku ' || vc1.eYear);   
    END LOOP;
END;

/* zad3
Utworzyć w bazie danych tabelę o nazwie Analityka. 
Tabela powinna zawierać informacje o liczbie egzaminów poszczególnych egzaminatorów w poszczególnych ośrodkach. 
W tabeli utworzyć 4 kolumny. Trzy pierwsze kolumny opisują egzaminatora (identyfikator, imię i nazwisko). 
Czwarta kolumna o nazwie Osrodki opisuje ośrodek (identyfikator oraz nazwa) oraz liczbę egzaminów danego egzaminatora w tym ośrodku. 
Dane dotyczące ośrodka i liczby egzaminów należy umieścić w kolumnie będącej kolekcją typu tablica zagnieżdżona. 
Wprowadzić dane do tabeli Analityka na podstawie danych zgromadzonych w tabelach Egzaminy, Osrodki i Egzaminatorzy.
Następnie wyświetlić dane znajdujące się w tabeli Analityka.
*/
CREATE OR REPLACE TYPE Typ_OsrodekDane_Obj AS OBJECT (osrodekID NUMBER, osrodekNazwa VARCHAR(50), examNumber NUMBER);
CREATE OR REPLACE TYPE Typ_OsrodekDane_Table IS TABLE OF Typ_OsrodekDane_Obj;
DROP TABLE Analityka3;
CREATE TABLE Analityka3(
id VARCHAR2(40),
imie VARCHAR2(50),
nazwisko VARCHAR2(50),
dane_zagn Typ_OsrodekDane_Table) NESTED TABLE dane_zagn STORE AS dane_osrodka_zagn;
DECLARE
    tab_zag Typ_OsrodekDane_Table;
    CURSOR c1 IS SELECT eg.id_egzaminator idEg, eg.imie imie, eg.nazwisko nazwisko FROM egzaminatorzy eg INNER JOIN egzaminy e ON eg.id_egzaminator = e.id_egzaminator;
    FUNCTION getExamNumber(idEgzaminator VARCHAR2) RETURN Typ_OsrodekDane_Table IS
        CURSOR c2 IS 
        SELECT o.id_osrodek idO, o.nazwa_osrodek nazwaO, COUNT(e.id_egzamin) examN FROM egzaminatorzy eg INNER JOIN egzaminy e ON eg.id_egzaminator = e.id_egzaminator INNER JOIN osrodki o ON e.id_osrodek = e.id_osrodek 
        WHERE e.id_egzaminator = idEgzaminator GROUP BY o.id_osrodek, o.nazwa_osrodek ORDER BY 1, 2, 3;
        tab_zag Typ_OsrodekDane_Table := Typ_OsrodekDane_Table();
        i NUMBER := 0;
    BEGIN
        FOR vc2 IN c2 LOOP
            i := i+1;
            tab_zag.EXTEND;
            tab_zag(i) := Typ_OsrodekDane_Obj(vc2.idO, vc2.nazwaO, vc2.examN);
        END LOOP;
        RETURN tab_zag;
    END getExamNumber;
BEGIN
    FOR vc1 IN c1 LOOP 
        tab_zag := getExamNumber(vc1.idEg);
        INSERT INTO Analityka3 VALUES (vc1.idEg, vc1.imie, vc1.nazwisko, tab_zag);
    END LOOP;
END;
SELECT a.id, a.imie, a.nazwisko, nt.osrodekID, nt.osrodekNazwa, nt.examNumber FROM Analityka3 a, TABLE(a.dane_zagn) nt;

/* zad 1
Utworzyć kolekcję typu tablica zagnieżdżona i nazwać ją NT_Studenci. 
Kolekcja powinna zawierać elementy opisujące liczbę egzaminów każdego studenta oraz liczbę zdobytych punktów przez studenta. 
Zainicjować wartości elementów kolekcji na podstawie danych z tabel Studenci i Egzaminy. 
Zapewnić, by studenci umieszczeni w kolejnych elementach uporządkowani byli wg liczby zdawanych egzaminów, od największej do najmniejszej 
(tzn. pierwszy element kolekcji zawiera studenta, który miał najwięcej egzaminów). 
Po zainicjowaniu kolekcji, wyświetlić wartości znajdujące się w poszczególnych jej elementach.
*/
DECLARE
    i NUMBER := 0;
    type typ_rekord_studenci is record
                         (
                             id_student VARCHAR(10),
                             imie VARCHAR(40),
                             nazwisko VARCHAR(50),
                             liczba_egzaminow number,
                             liczba_punktow number
                         );
    type typ_table_studenci is table of typ_rekord_studenci;
    tablica typ_table_studenci := typ_table_studenci();
    --COALESCE W PRZYPADKU KIEDY W SUM WYSTAPILBY NULL - WTEDY ZAMIENIA GO NA 0
    CURSOR c1 IS 
    SELECT s.id_student idS, s.imie im, s.nazwisko naz, COUNT(e.id_egzamin) examN, COALESCE(SUM(e.punkty), 0) points FROM studenci s LEFT JOIN egzaminy e ON s.id_student = e.id_student
    GROUP BY s.id_student, s.imie, s.nazwisko
    ORDER BY 4 DESC;
BEGIN
    FOR vc1 IN c1 LOOP
        i := i+1;
        tablica.extend;
        tablica(i) := typ_rekord_studenci(vc1.idS, vc1.im, vc1.naz, vc1.examN, vc1.points);
    END LOOP;
    
    for i in 1 .. tablica.count() loop
    dbms_output.put_line(
       tablica(i).id_student || ', '
        || tablica(i).imie || ', '
        || tablica(i).nazwisko || ', '
        ||'liczba egzaminow: '|| tablica(i).liczba_egzaminow ||', '
        ||'suma punktów: '|| tablica(i).liczba_punktow);
	end loop;
END;

/* zad 5
Który student zdawał z przedmiotu "Bazy danych" więcej niż 10 egzaminów w ciągu jednego roku? 
Zadanie należy rozwiązać przy pomocy wyjątków (dodatkowo można wykorzystać kursory). 
W odpowiedzi proszę podać pełne dane studenta (identyfikator, nazwisko, imię), rok (w formacie YYYY) oraz liczbę egzaminów.
*/
DECLARE
    ex EXCEPTION;
    CURSOR c1 IS 
    SELECT s.id_student idS, s.imie im, s.nazwisko naz, EXTRACT(YEAR FROM e.data_egzamin) rok, COUNT(e.id_egzamin) liczbaE FROM studenci s INNER JOIN egzaminy e ON s.id_student = e.id_student
    INNER JOIN przedmioty p ON p.id_przedmiot=e.id_przedmiot WHERE UPPER(p.nazwa_przedmiot) = 'BAZY DANYCH'
    GROUP BY s.id_student, s.imie, s.nazwisko, EXTRACT(YEAR FROM e.data_egzamin) ORDER BY 1;
BEGIN 
    FOR vc1 IN c1 LOOP
    BEGIN
        IF vc1.liczbaE > 10 THEN
            RAISE ex;
        END IF;
        EXCEPTION
            WHEN ex THEN
                DBMS_OUTPUT.PUT_LINE(vc1.ids || ' ' || vc1.naz || ' ' || vc1.im || ' ' || 'rok:' || vc1.rok || ' liczba_egzaminow=' || vc1.liczbaE);
    END;
    END LOOP;
END;

/* zad4
Proszę wskazać tych egzaminatorów, którzy przeprowadzili egzaminy w dwóch ostatnich dniach egzaminowania z każdego przedmiotu. 
Jeśli z danego przedmiotu nie było egzaminu, proszę wyświetlić komunikat "Brak egzaminów". 
W odpowiedzi należy umieścić nazwę przedmiotu, datę egzaminu (w formacie DD-MM-YYYY) oraz identyfikator, nazwisko i imię egzaminatora. 
Zadanie należy wykonać z użyciem kursora.
*/
DECLARE
    CURSOR c1 IS SELECT DISTINCT p.id_przedmiot idP, p.nazwa_przedmiot nazwaP FROM przedmioty p LEFT JOIN egzaminy e ON p.id_przedmiot = e.id_przedmiot ORDER BY 1;
    CURSOR c2(idP NUMBER) IS SELECT DISTINCT data_egzamin dataE FROM egzaminy WHERE id_przedmiot = idP ORDER BY 1 DESC FETCH FIRST 2 ROWS ONLY;
    CURSOR c3(idP NUMBER, dataE VARCHAR2) IS SELECT DISTINCT eg.id_egzaminator idEgzaminator, eg.imie imie, eg.nazwisko naz FROM egzaminatorzy eg INNER JOIN egzaminy e ON eg.id_egzaminator = e.id_egzaminator WHERE e.id_przedmiot = idP AND e.data_egzamin = dataE;
    FUNCTION isExamNumberGreatThanZeroBySubject(idP NUMBER) RETURN BOOLEAN IS
        examNumber NUMBER;
    BEGIN
        SELECT COUNT(id_egzamin) INTO examNumber FROM egzaminy WHERE id_przedmiot = idP;
        IF examNumber > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END isExamNumberGreatThanZeroBySubject;
BEGIN
    FOR vc1 IN c1 LOOP
       IF isExamNumberGreatThanZeroBySubject(vc1.idP) = FALSE THEN
            DBMS_OUTPUT.PUT_LINE('Z przedmiotu '|| vc1.nazwaP||' nie bylo egzaminow');
       END IF;
       FOR vc2 IN c2(vc1.idP) LOOP
            FOR vc3 IN c3(vc1.idP, vc2.dataE) LOOP
                DBMS_OUTPUT.PUT_LINE(vc1.nazwaP || ' '|| to_char(vc2.dataE, 'DD-MM-YYYY') || ' id:' || vc3.idEgzaminator || ' '||vc3.imie||' '||vc3.naz); 
            END LOOP;
       END LOOP;
    END LOOP;
END;

DECLARE
    CURSOR c1 IS SELECT DISTINCT p.id_przedmiot idP, p.nazwa_przedmiot nazwaP FROM przedmioty p LEFT JOIN egzaminy e ON p.id_przedmiot = e.id_przedmiot ORDER BY 1;
    CURSOR c2(idP NUMBER) IS SELECT DISTINCT data_egzamin dataE FROM egzaminy WHERE id_przedmiot = idP ORDER BY 1 DESC FETCH FIRST 2 ROWS ONLY;
    CURSOR c3(idP NUMBER, dataE VARCHAR2) IS SELECT DISTINCT eg.id_egzaminator idEgzaminator, eg.imie imie, eg.nazwisko naz FROM egzaminatorzy eg INNER JOIN egzaminy e ON eg.id_egzaminator = e.id_egzaminator WHERE e.id_przedmiot = idP AND e.data_egzamin = dataE;
    data_egzaminu DATE;
    i NUMBER;
BEGIN
    FOR vc1 IN c1 LOOP
       OPEN c2(vc1.idP);
       i := 0;
       LOOP
           IF c2%ISOPEN THEN
                FETCH c2 INTO data_egzaminu;
                EXIT WHEN c2%NOTFOUND;
                i := i+1;
                FOR vc3 IN c3(vc1.idP, data_egzaminu) LOOP
                    DBMS_OUTPUT.PUT_LINE(vc1.nazwaP || ' '|| to_char(data_egzaminu, 'DD-MM-YYYY') || ' id:' || vc3.idEgzaminator || ' '||vc3.imie||' '||vc3.naz); 
                END LOOP;
           END IF;
        END LOOP;
       IF i = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Z przedmiotu '|| vc1.nazwaP||' nie bylo egzaminow');
       END IF;
       CLOSE c2;
    END LOOP;
END;

/* zad 1
Utworzyć kolekcję typu tablica zagnieżdżona i nazwać ją NT_Studenci. 
Kolekcja powinna zawierać elementy opisujące liczbę egzaminów każdego studenta oraz liczbę zdobytych punktów przez studenta. 
Zainicjować wartości elementów kolekcji na podstawie danych z tabel Studenci i Egzaminy. 
Zapewnić, by studenci umieszczeni w kolejnych elementach uporządkowani byli wg liczby zdawanych egzaminów, od największej do najmniejszej 
(tzn. pierwszy element kolekcji zawiera studenta, który miał najwięcej egzaminów). 
Po zainicjowaniu kolekcji, wyświetlić wartości znajdujące się w poszczególnych jej elementach.
*/
DECLARE
    i NUMBER := 0;
    type typ_rekord_studenci is record
                         (
                             id_student VARCHAR(10),
                             imie VARCHAR(40),
                             nazwisko VARCHAR(50),
                             liczba_egzaminow number,
                             liczba_punktow number
                         );
    type typ_table_studenci is table of typ_rekord_studenci;
    tablica typ_table_studenci := typ_table_studenci();
	
    --COALESCE W PRZYPADKU KIEDY W SUM WYSTAPILBY NULL - WTEDY ZAMIENIA GO NA 0
    CURSOR c1 IS 
    SELECT s.id_student idS, s.imie im, s.nazwisko naz, COUNT(e.id_egzamin) examN, COALESCE(SUM(e.punkty), 0) points FROM studenci s LEFT JOIN egzaminy e ON s.id_student = e.id_student
    GROUP BY s.id_student, s.imie, s.nazwisko
    ORDER BY 4 DESC;
BEGIN
    FOR vc1 IN c1 LOOP
        i := i+1;
        tablica.extend;
        tablica(i) := typ_rekord_studenci(vc1.idS, vc1.im, vc1.naz, vc1.examN, vc1.points);
    END LOOP;
    
    for i in 1 .. tablica.count() loop
    dbms_output.put_line(
       tablica(i).id_student || ', '
        || tablica(i).imie || ', '
        || tablica(i).nazwisko || ', '
        ||'liczba egzaminow: '|| tablica(i).liczba_egzaminow ||', '
        ||'suma punktów: '|| tablica(i).liczba_punktow);
	end loop;
END;

/* zad 2
Dla każdego ośrodka, w którym odbył się egzamin, wyznaczyć liczbę studentów, którzy byli egzaminowani w danym ośrodku w kolejnych latach. 
Liczbę egzaminowanych studentów należy wyznaczyć przy pomocy funkcji PL/SQL.
Wynik w postaci listy ośrodków i w/w liczb przedstawić w postaci posortowanej wg nazwy ośrodka i numeru roku.
*/
DECLARE
    stuNum NUMBER;
    CURSOR c1 IS SELECT o.id_osrodek idOsrodek, o.nazwa_osrodek nazwaO, extract(year from e.data_egzamin) eYear FROM osrodki o INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek ORDER BY 1,2, 3;
    FUNCTION getExamNumByOsrodek(idOsrodek osrodki.id_osrodek%TYPE, examYear VARCHAR2) RETURN NUMBER IS
        stuN number;
        CURSOR c2 IS SELECT e.id_osrodek, extract(year from e.data_egzamin), COUNT(DISTINCT e.id_student) stuNumber  FROM egzaminy e 
        WHERE e.id_osrodek = idOsrodek AND extract(year from e.data_egzamin) = examYear GROUP BY e.id_osrodek, extract(year from e.data_egzamin);
    BEGIN
        FOR vc2 IN c2 LOOP
            stuN := vc2.stuNumber;
        END LOOP;
        RETURN stuN;
    END getExamNumByOsrodek;
BEGIN
    FOR vc1 IN c1 LOOP 
        stuNum := getExamNumByOsrodek(vc1.idOsrodek, vc1.eYear);
        DBMS_OUTPUT.put_line('W ośrodek o ID=' || vc1.idOsrodek || ' egzaminowano '|| stuNum ||' studentow w roku ' || vc1.eYear);   
    END LOOP;
END;

/* zad 3
Utworzyć w bazie danych tabelę o nazwie Analityka. Tabela powinna zawierać informacje o liczbie egzaminów poszczególnych egzaminatorów w poszczególnych ośrodkach. W tabeli utworzyć 4 kolumny. Trzy pierwsze kolumny opisują egzaminatora (identyfikator, imię i nazwisko). Czwarta kolumna o nazwie Osrodki opisuje ośrodek (identyfikator oraz nazwa) oraz liczbę egzaminów danego egzaminatora w tym ośrodku. Dane dotyczące ośrodka i liczby egzaminów należy umieścić w kolumnie będącej kolekcją typu tablica zagnieżdżona. Wprowadzić dane do tabeli Analityka na podstawie danych zgromadzonych w tabelach Egzaminy, Osrodki i Egzaminatorzy.
Następnie wyświetlić dane znajdujące się w tabeli Analityka.
*/

CREATE OR REPLACE TYPE Typ_OsrodekDane_Obj AS OBJECT (osrodekID NUMBER, osrodekNazwa VARCHAR(50), examNumber NUMBER);
CREATE OR REPLACE TYPE Typ_OsrodekDane_Table IS TABLE OF Typ_OsrodekDane_Obj;
DROP TABLE Analityka3;
CREATE TABLE Analityka3(
id VARCHAR2(40),
imie VARCHAR2(50),
nazwisko VARCHAR2(50),
dane_zagn Typ_OsrodekDane_Table) NESTED TABLE dane_zagn STORE AS dane_osrodka_zagn;
DECLARE
    tab_zag Typ_OsrodekDane_Table;
    CURSOR c1 IS SELECT eg.id_egzaminator idEg, eg.imie imie, eg.nazwisko nazwisko FROM egzaminatorzy eg INNER JOIN egzaminy e ON eg.id_egzaminator = e.id_egzaminator;
    FUNCTION getExamNumber(idEgzaminator VARCHAR2) RETURN Typ_OsrodekDane_Table IS
        CURSOR c2 IS 
        SELECT o.id_osrodek idO, o.nazwa_osrodek nazwaO, COUNT(e.id_egzamin) examN FROM egzaminatorzy eg INNER JOIN egzaminy e ON eg.id_egzaminator = e.id_egzaminator INNER JOIN osrodki o ON e.id_osrodek = e.id_osrodek 
        WHERE e.id_egzaminator = idEgzaminator GROUP BY o.id_osrodek, o.nazwa_osrodek ORDER BY 1, 2, 3;
        tab_zag Typ_OsrodekDane_Table := Typ_OsrodekDane_Table();
        i NUMBER := 0;
    BEGIN
        FOR vc2 IN c2 LOOP
            i := i+1;
            tab_zag.EXTEND;
            tab_zag(i) := Typ_OsrodekDane_Obj(vc2.idO, vc2.nazwaO, vc2.examN);
        END LOOP;
        RETURN tab_zag;
    END getExamNumber;
BEGIN
    FOR vc1 IN c1 LOOP 
        tab_zag := getExamNumber(vc1.idEg);
        INSERT INTO Analityka3 VALUES (vc1.idEg, vc1.imie, vc1.nazwisko, tab_zag);
    END LOOP;
END;
SELECT a.id, a.imie, a.nazwisko, nt.osrodekID, nt.osrodekNazwa, nt.examNumber FROM Analityka3 a, TABLE(a.dane_zagn) nt

/* zad4
Proszę wskazać tych egzaminatorów, którzy przeprowadzili egzaminy w dwóch ostatnich dniach egzaminowania z każdego przedmiotu. 
Jeśli z danego przedmiotu nie było egzaminu, proszę wyświetlić komunikat "Brak egzaminów". 
W odpowiedzi należy umieścić nazwę przedmiotu, datę egzaminu (w formacie DD-MM-YYYY) oraz identyfikator, nazwisko i imię egzaminatora. 
Zadanie należy wykonać z użyciem kursora.
*/
DECLARE
    CURSOR c1 IS SELECT p.id_przedmiot idP, p.nazwa_przedmiot nazwaP FROM przedmioty p;
    CURSOR c2(idP NUMBER) IS SELECT DISTINCT data_egzamin FROM egzaminy WHERE id_przedmiot = idP ORDER BY 1 DESC FETCH FIRST 2 ROWS ONLY;
    CURSOR c3(idP NUMBER, dataE VARCHAR2) IS 
        SELECT DISTINCT eg.id_egzaminator, eg.imie, eg.nazwisko FROM egzaminatorzy eg INNER JOIN egzaminy e ON eg.id_egzaminator = e.id_egzaminator 
        WHERE e.id_przedmiot = idP AND e.data_egzamin = dataE;
    data_egzaminu DATE;
    idE VARCHAR2(10);
    imie VARCHAR2(50);
    nazwisko VARCHAR2(50);
    czy_byl_egzamin_data BOOLEAN;
    czy_byl_egzamin BOOLEAN;
BEGIN
    FOR vc1 IN c1 LOOP
       OPEN c2(vc1.idP);
       IF c2%ISOPEN THEN
            czy_byl_egzamin_data := FALSE;
            LOOP
                FETCH c2 INTO data_egzaminu;
                EXIT WHEN c2%NOTFOUND;
                czy_byl_egzamin_data := TRUE;
                OPEN c3(vc1.idP, data_egzaminu);
                IF c3%ISOPEN THEN
                    czy_byl_egzamin := FALSE;
                    LOOP
                        FETCH c3 INTO idE, imie, nazwisko;
                        EXIT WHEN c3%NOTFOUND;
                        czy_byl_egzamin := TRUE;
                        DBMS_OUTPUT.put_line(to_char(data_egzaminu, 'dd-mm-yyyy')||' '||vc1.nazwaP||' '||idE||' '||imie||' '||nazwisko);  
                    END LOOP;
                END IF;
                IF czy_byl_egzamin = FALSE THEN
                    DBMS_OUTPUT.put_line(vc1.nazwaP||' brak egzaminow!'); 
                END IF;
                CLOSE c3;
            END LOOP;
       END IF;
       IF czy_byl_egzamin_data = FALSE THEN
            DBMS_OUTPUT.put_line(vc1.nazwaP||' brak egzaminow!'); 
       END IF;
       CLOSE c2;
    END LOOP;
END;

/* zad 5
Który student zdawał z przedmiotu "Bazy danych" więcej niż 10 egzaminów w ciągu jednego roku? 
Zadanie należy rozwiązać przy pomocy wyjątków (dodatkowo można wykorzystać kursory). 
W odpowiedzi proszę podać pełne dane studenta (identyfikator, nazwisko, imię), rok (w formacie YYYY) oraz liczbę egzaminów.
*/
DECLARE
    ex EXCEPTION;
    CURSOR c1 IS 
    SELECT s.id_student idS, s.imie im, s.nazwisko naz, EXTRACT(YEAR FROM e.data_egzamin) rok, COUNT(e.id_egzamin) liczbaE FROM studenci s INNER JOIN egzaminy e ON s.id_student = e.id_student
    GROUP BY s.id_student, s.imie, s.nazwisko, EXTRACT(YEAR FROM e.data_egzamin) ORDER BY 1;
BEGIN 
    FOR vc1 IN c1 LOOP
    BEGIN
        IF vc1.liczbaE > 10 THEN
            RAISE ex;
        END IF;
        EXCEPTION
            WHEN ex THEN
                DBMS_OUTPUT.PUT_LINE(vc1.ids || ' ' || vc1.naz || ' ' || vc1.im || ' ' || 'rok:' || vc1.rok || ' liczba_egzaminow=' || vc1.liczbaE);
    END;
    END LOOP;
END;
/* zad 1
Dla kazddego roku, w ktorym odbyly sie egzaminy, prosze wskazac tego studenta, ktołry zdal‚ najwiecej egzaminow w danym roku. 
Dodatkowo, nalezy podac sumaryczna liczbe punktow uzyskanych z tych egzaminow przez studenta. 
W odpowiedzi umies›cic informacje o roku (w formacie YYYY) oraz pelne informacje o studencie (identyfikator, nazwisko, imie). 
Zadanie nalezy rozwiazac z uzyciem kursora.
*/
DECLARE
    CURSOR c1 IS SELECT DISTINCT EXTRACT(YEAR FROM data_egzamin) rok FROM egzaminy ORDER BY 1;
    CURSOR c2(rok VARCHAR2) IS 
    SELECT s.id_student idS, s.imie imie, s.nazwisko naz, COUNT(id_egzamin) passedExams FROM egzaminy e INNER JOIN studenci s ON e.id_student = s.id_student
    WHERE e.zdal = 'T' AND EXTRACT(YEAR FROM data_egzamin) = rok
    GROUP BY s.id_student, s.imie, s.nazwisko
    HAVING COUNT(id_egzamin) = (
        SELECT MAX(COUNT(id_egzamin)) FROM egzaminy 
        WHERE zdal = 'T' AND EXTRACT(YEAR FROM data_egzamin) = rok
        GROUP BY id_student
    );
BEGIN
    FOR vc1 IN c1 LOOP
        FOR vc2 IN c2(vc1.rok) LOOP
            DBMS_OUTPUT.PUT_LINE('Rok: '||vc1.rok||' ID:'||vc2.idS||' '||vc2.imie||' '||vc2.naz||' Liczba zdanych egzaminow = '||vc2.passedExams);
        END LOOP;
    END LOOP;
END;

/* zad 2
Utworzyc w bazie danych tabele o nazwie PrzedmiotyAnaliza. 
Tabela powinna zawierac informacje o liczbie egzaminow z poszczegolnych przedmiotow przeprowadzonych w poszczegolnych miesiacach dla kolejnych lat. 
W tabeli utworzyc 2 kolumny. Pierwsza z nich opisuje przedmiot (nazwa przedmiotu). Druga kolumna opisuje rok, miesiac i liczbe egzaminow z danego przedmiotu w danym miesiacu danego roku. 
Dane dotyczace roku, miesiaca i liczby egzaminow nalezy umiescic w kolumnie bedacej kolekcja typu tablica zagniezdzona. 
Wprowadzic dane do tabeli PrzedmiotyAnaliza na podstawie danych zgromadzonych tabelach Przedmioty i Egzaminy.
Nastepnie wyswietlic dane znajdujace sie w tabeli PrzedmiotyAnaliza.
*/
CREATE OR REPLACE TYPE type_obj_10 is OBJECT (rok VARCHAR2(8), miesiac VARCHAR2(30), liczba_egz NUMBER);
CREATE OR REPLACE TYPE type_table_10 is TABLE OF type_obj_10;
CREATE TABLE PA(
    nazwa_przedmiotu VARCHAR2(50),
    kolekcja type_table_10
) NESTED TABLE kolekcja STORE AS xxx;
DECLARE
    dane type_table_10;
    i NUMBER := 0;
    CURSOR c1 IS SELECT id_przedmiot, nazwa_przedmiot FROM przedmioty;
    FUNCTION getSubjectData(idP przedmioty.id_przedmiot%TYPE) RETURN type_table_10 IS
        dane type_table_10 := type_table_10();
        i NUMBER := 0;
        CURSOR c2 IS 
        SELECT EXTRACT(YEAR FROM data_egzamin) year, EXTRACT(MONTH FROM data_egzamin) month, COUNT(id_egzamin) examNum FROM egzaminy 
        WHERE id_przedmiot = idP
        GROUP BY EXTRACT(YEAR FROM data_egzamin), EXTRACT(MONTH FROM data_egzamin) ORDER BY 1, 2;
    BEGIN
        FOR vc2 IN c2 LOOP
           i := i+1;
           dane.EXTEND;
           dane(i) := type_obj_10(vc2.year, vc2.month, vc2.examNum);
        END LOOP;
        RETURN dane;
    END getSubjectData;
BEGIN
    FOR vc1 IN c1 LOOP
        dane := getSubjectData(vc1.id_przedmiot);
        INSERT INTO PA VALUES (vc1.nazwa_przedmiot, dane);
    END LOOP;
END;
SELECT p.nazwa_przedmiotu, nt.miesiac, nt.rok, nt.liczba_egz FROM PA p, TABLE(p.kolekcja) nt;

/* zad 3
Utworzyc kolekcje typu tablica zagniezdzona i nazwac ja NT_Egzaminatorzy. 
Kolekcja powinna zawieraÄ‡ elementy, z ktorych kazdy opisuje egzaminatora oraz liczbe studentow przeegzaminowanych przez niego. 
Do opisu egzaminatora prosze uzyc identyfikatora, nazwiska i imienia. 
Zainicjowac wartosci elementow kolekcji na podstawie danych z tabel Egzaminatorzy i Egzaminy.
Zapewnic, by egzaminatorzy umieszczeni w kolejnych elementach uporzsdkowani byli wg liczby egzaminowanych osob, od najwiekszej do najmniejszej 
(tzn. pierwszy element kolekcji zawiera egzaminatora, ktory egzaminowal‚ najwiecej osob). 
Po zainicjowaniu kolekcji, wys›wietlic wartosci znajdujace sie w poszczegolnych jej elementach.
*/
DECLARE 
    TYPE recType IS RECORD (idEgz egzaminatorzy.id_egzaminator%TYPE, nazwisko VARCHAR2(50), imie VARCHAR2(50), liczba_s NUMBER);
    TYPE NT_Egzaminatorzy IS TABLE OF recType;
    CURSOR c1 IS 
    SELECT egz.id_egzaminator idEgz, egz.nazwisko naz, egz.imie im, COUNT(DISTINCT id_student) liczba_s FROM egzaminatorzy egz 
    LEFT JOIN egzaminy e ON egz.id_egzaminator = e.id_egzaminator
    GROUP BY egz.id_egzaminator, egz.nazwisko, egz.imie 
    ORDER BY 4 DESC, 1;
    
    kolekcja NT_Egzaminatorzy := NT_Egzaminatorzy();
    i NUMBER := 1;
BEGIN
    FOR vc1 IN c1 LOOP
        kolekcja.EXTEND;
        kolekcja(i) := recType(vc1.idEgz, vc1.naz, vc1.im, vc1.liczba_s);
        i := i+1;
    END LOOP;
    FOR j IN 1 .. kolekcja.COUNT() LOOP
        DBMS_OUTPUT.PUT_LINE(kolekcja(j).idEgz||' ' ||kolekcja(j).nazwisko||' ' ||kolekcja(j).imie||' Liczba egzaminowanych studentow = ' ||kolekcja(j).liczba_s);
	END LOOP;
END;

/* zad 4
Ktory student nie zdawal‚ jeszcze egzaminu z przedmiotu "Bazy danych"? 
W rozwiazaniu zadania wykorzystac technike wyjatkow (dodatkowo mozna takze uzyc kursory).
W odpowiedzi umiescic pelne dane studenta (identyfikator, nazwisko, imie).
*/
DECLARE
    CURSOR c1 IS SELECT id_student, imie, nazwisko FROM studenci;
    n NUMBER;
BEGIN
    FOR vc1 IN c1 LOOP
        BEGIN
            SELECT DISTINCT 1 INTO n FROM egzaminy e INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
            WHERE UPPER(p.nazwa_przedmiot) = 'BAZY DANYCH' AND e.id_student = vc1.id_student;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('Student '||vc1.imie||' '||vc1.nazwisko||' nie zdawal egzaminu z baz danych');
        END;
    END LOOP;
END;

/* zad 5
Dla kazdego osrodka, w ktorym odbyl sie egzamin, wyznaczyc liczbe studentow, ktorzy byli egzaminowani w danym osrodku w kolejnych latach. 
Liczbe egzaminowanych studentow nalezy wyznaczyc przy pomocy funkcji PL/SQL. 
Wynik w postaci listy osrodkow i w/w liczb przedstawic w postaci posortowanej wg nazwy osrodka i numeru roku.
*/
DECLARE
    CURSOR c1 IS 
    SELECT DISTINCT o.id_osrodek idO, o.nazwa_osrodek nazwaO, EXTRACT(YEAR FROM e.data_egzamin) rok FROM osrodki o INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek ORDER BY 2, 1, 3;
    FUNCTION getStudentNumber(idO osrodki.id_osrodek%TYPE, rok VARCHAR2) RETURN NUMBER IS
        n NUMBER;
    BEGIN
        SELECT COUNT(DISTINCT id_student) INTO n FROM egzaminy WHERE id_osrodek = idO AND EXTRACT(YEAR FROM data_egzamin) = rok;
        RETURN n;
    END getStudentNumber;
BEGIN 
    FOR vc1 IN c1 LOOP
        DBMS_OUTPUT.PUT_LINE('W '||vc1.rok||' w osrodku o nazwie: '||vc1.nazwaO||' i ID:'||vc1.idO||' egzaminowano '||getStudentNumber(vc1.idO, vc1.rok)||' studentow' );
    END LOOP;
END;

/* zad 1
Dla każdego ośrodka, w którym odbyl sie egzamin, wyznaczyc liczbe studentow, ktorzy byli egzaminowani w danym osrodku w kolejnych latach. 
Liczbe egzaminowanych studentow nalezy wyznaczyc przy pomocy funkcji PL/SQL. 
Wynik w postaci listy osrodkow i w/w liczb przedstawix w postaci posortowanej wg nazwy osrodka i numeru roku.
*/
DECLARE
    CURSOR c1 IS 
        SELECT DISTINCT o.id_osrodek idO, o.nazwa_osrodek nazwaO, EXTRACT(YEAR FROM e.data_egzamin) rok FROM osrodki o 
        INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek 
        ORDER BY 2, 1, 3;
    FUNCTION getStudentNumber(idO osrodki.id_osrodek%TYPE, rok VARCHAR2) RETURN NUMBER IS
        n NUMBER;
    BEGIN
        SELECT COUNT(DISTINCT id_student) INTO n FROM egzaminy WHERE id_osrodek = idO AND EXTRACT(YEAR FROM data_egzamin) = rok; 
        RETURN n;
    END getStudentNumber;
BEGIN
    FOR vc1 IN c1 LOOP
        DBMS_OUTPUT.PUT_LINE('Ośrodek '||vc1.nazwaO||' id:'||vc1.idO||' '||' rok:'||vc1.rok||' liczba egzaminowanych studentow:'||getStudentNumber(vc1.idO, vc1.rok));
    END LOOP;
END;

/* zad 2
Utworzyc kolekcje typu tablica zagniezdzona i nazwac ja NT_Osrodki. 
Kolekcja powinna zawierac elementy opisujace date egzaminu oraz identyfikator i nazwe osrodka. 
Elementami kolekcji beda dane o tych osrodkach, w ktorych przeprowadzono egzamin w trzech ostatnich dniach egzaminowania, oraz dane o dacie egzaminu
Zainicjowac wartosci elementow kolekcji na podstawie danych z tabel Osrodki i Egzaminy. 
Zapewnic, by dane umieszczane byly w takiej kolejnosci, aby na poczatku znalazly sie daty najpozniejsze egzaminoww.
Po zainicjowaniu kolekcji, wyswietlic wartosci znajdujace sie w poszczegolnych jej elementach.
*/
DECLARE
    TYPE recType IS RECORD (idO osrodki.id_osrodek%TYPE, nazwaO VARCHAR2(50), data_e DATE);
    TYPE NT_Osrodki IS TABLE OF recType;
    --TU UWAGA NA DATY, GDY BYLO BEZ TO_CHAR DISTNICT NIE DZIALAL - ALE TYLKO DO TYCH DAT, KTRE SAM DODAWALEM
    CURSOR c1 IS SELECT DISTINCT data_egzamin data_e FROM egzaminy ORDER BY 1 DESC FETCH FIRST 3 ROWS ONLY;
    CURSOR c2(data_e DATE) IS 
        SELECT DISTINCT o.id_osrodek idO, o.nazwa_osrodek nazwaO FROM osrodki o 
        INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek 
        WHERE e.data_egzamin = data_e;
    kolekcja NT_Osrodki := NT_Osrodki();
    i NUMBER := 1; 
BEGIN
    FOR vc1 IN c1 LOOP
        FOR vc2 IN c2(vc1.data_e) LOOP
            kolekcja.EXTEND;
            kolekcja(i) := recType(vc2.idO, vc2.nazwaO, vc1.data_e);
            i := i+1;
        END LOOP;
    END LOOP;
    FOR j IN 1 .. kolekcja.COUNT() LOOP
        DBMS_OUTPUT.PUT_LINE(kolekcja(j).idO||' ' ||kolekcja(j).nazwaO||' ' ||kolekcja(j).data_e);
	END LOOP;
END;

/* zad 3
Dla kazdego osrodka, w ktorym przeprowadzono egzaminy, prosze wskazac tych studentow, ktorzy byli egzaminowani w ciagu trzech ostatnich dni egzaminowania w danym osrodku. 
Wyswietlic identyfikator i nazwe osrodka, date egzaminu (w formacie DD-MM-YYYY) oraz identyfikator, imie i nazwisko studenta.
Zadanie nalezy rozwiazac z uzyciem kursora.
*/
DECLARE
    CURSOR c1 IS SELECT DISTINCT o.id_osrodek idO, o.nazwa_osrodek nazwaO FROM osrodki o INNER JOIN egzaminy e ON o.id_osrodek = e.id_osrodek;
    CURSOR c2(idOsr osrodki.id_osrodek%TYPE) IS
        SELECT DISTINCT data_egzamin FROM egzaminy WHERE id_osrodek = idOsr ORDER BY 1 DESC FETCH FIRST 3 ROWS ONLY;
    CURSOR c3(idOsr osrodki.id_osrodek%TYPE, dzien DATE) IS 
        SELECT DISTINCT s.id_student idS, s.imie im, s.nazwisko naz FROM studenci s INNER JOIN egzaminy e ON s.id_Student = e.id_student 
        WHERE e.id_osrodek = idOsr AND e.data_egzamin = dzien;
    idS VARCHAR2(20);
    imie VARCHAR2(50);
    nazwisko VARCHAR2(50);
    czy_student_byl BOOLEAN;
BEGIN
    FOR vc1 IN c1 LOOP
        FOR vc2 IN c2(vc1.idO) LOOP
            FOR vc3 IN c3(vc1.idO, vc2.data_egzamin) LOOP
                DBMS_OUTPUT.PUT_LINE(vc1.idO|| ' '||vc1.nazwaO||' '||to_char(vc2.data_egzamin, 'dd-mm-yyyy')||' '||vc3.idS||' '||vc3.im||' ' ||vc3.naz);
            END LOOP;
            /*OPEN c3(vc1.idO, vc2.data_egzamin);
            IF c3%ISOPEN THEN
                czy_student_byl := FALSE;
                LOOP
                    FETCH c3 INTO idS, imie, nazwisko;
                    EXIT WHEN c3%NOTFOUND;
                    czy_student_byl := TRUE;
                    DBMS_OUTPUT.PUT_LINE(vc1.idO|| ' '||vc1.nazwaO||' '||to_char(vc2.data_egzamin, 'dd-mm-yyyy')||' '||idS||' '||imie||' ' ||nazwisko);
                END LOOP;
                IF czy_student_byl = FALSE THEN
                    DBMS_OUTPUT.PUT_LINE(vc1.idO|| ' '||vc1.nazwaO||' brak egzaminow!');
                END IF;
            END IF;
            CLOSE c3;*/
        END LOOP;
    END LOOP;
END;

/* zad 4
Ktory egzaminator przeprowadzil‚ wiecej niz 50 egzaminow w tym samym osrodku w jednym roku? 
Zadanie nalezy rozwiazac przy uzyciu techniki wyjatkow (jesli to konieczne, mozna dodatkowo zastosowac kursory). 
W odpowiedzi prosze umiescic pelne dane o osrodku (identyfikator, nazwa), informacje o roku (w formacie YYYY), 
pelne dane egzaminatora (identyfikator, nazwisko, imie) oraz liczbe egzaminow.
Zadanie nalezy wykonac, wykorzystujac technike wyjatkow.
*/
DECLARE
    CURSOR c1 IS 
    SELECT egz.id_egzaminator idE, egz.imie imie, egz.nazwisko nazwisko, o.id_osrodek idO, o.nazwa_osrodek nazwaO, EXTRACT(YEAR FROM e.data_egzamin) rok, COUNT(e.id_egzamin) liczba_egz 
    FROM egzaminatorzy egz 
    INNER JOIN egzaminy e ON egz.id_egzaminator = e.id_egzaminator
    INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
    GROUP BY egz.id_egzaminator, egz.imie, egz.nazwisko, o.id_osrodek, o.nazwa_osrodek, EXTRACT(YEAR FROM e.data_egzamin)
    ORDER BY 1, 4, 6;
    
    ex EXCEPTION;
BEGIN
    FOR vc1 IN c1 LOOP
        BEGIN
            IF vc1.liczba_egz > 9 THEN
                RAISE ex;
            END IF;
            EXCEPTION
                WHEN ex THEN DBMS_OUTPUT.PUT_LINE(vc1.idO|| ' '||vc1.nazwaO||' '||vc1.rok||' '||vc1.idE||' '||vc1.imie||' '||vc1.nazwisko||' '|| vc1.liczba_egz);
        END;
    END LOOP;
END;


/* zad 5
UtworzyÄ‡ w bazie danych tabelÄ™ o nazwie EgzaminatorzyAnaliza. 
Tabela powinna zawieraÄ‡ informacje o liczbie studentow egzaminowanych przez poszczegolnych egzaminatorow w kolejnych miesiÄ…cach w poszczegolnych latach.
W tabeli utworzyÄ‡ 4 kolumny. Trzy pierwsze kolumny bÄ™dÄ… opisywaÄ‡ egzaminatora, tj. jego ID, nazwisko i imiÄ™. 
Czwarta kolumna bÄ™dzie opisywaÄ‡ rok, miesiÄ…c i liczbÄ™ osob egzaminowanych przez danego egzaminatora w danym miesiÄ…cu danego roku.Â 
Dane dotyczÄ…ce roku, miesiÄ…ca i liczby studentow nalezyÂ umieĹ›ciÄ‡ w kolumnie bÄ™dÄ…cej kolekcjÄ… typu tablica zagniezdzona. 
WprowadziÄ‡ dane do tabeliÂ EgzaminatorzyAnalizaÂ na podstawie danych zgromadzonych tabelach EgzaminatorzyÂ iÂ Egzaminy.
NastÄ™pnie wyĹ›wietliÄ‡ dane znajdujÄ…ce siÄ™ w tabeliÂ EgzaminatorzyAnaliza.Â 
*/
CREATE OR REPLACE TYPE temp_object_type IS OBJECT (rok VARCHAR2(10), miesiac VARCHAR2(20), liczba_osob NUMBER);
CREATE OR REPLACE TYPE temp_table_type2 IS TABLE OF temp_object_type;
CREATE TABLE EgzaminatorzyAnalizaPrzedKolosem(
    id_egzaminator VARCHAR2(20),
    imie VARCHAR2(50),
    nazwisko VARCHAR2(50),
    kolekcja temp_table_type2
) NESTED TABLE kolekcja STORE AS EAPKStored;

DECLARE
    kolekcja temp_table_type2;
    CURSOR c1 IS SELECT id_egzaminator, imie, nazwisko FROM egzaminatorzy;
    FUNCTION getStudentNumber(idEgzaminator egzaminatorzy.id_egzaminator%TYPE) RETURN temp_table_type2 IS
        kolekcja temp_table_type2 := temp_table_type2();
        CURSOR c2 IS 
            SELECT EXTRACT(YEAR FROM e.data_egzamin) rok, EXTRACT(MONTH FROM e.data_egzamin) miesiac, COUNT(DISTINCT e.id_student) liczba_s 
            FROM egzaminy e
            WHERE e.id_egzaminator = idEgzaminator
            GROUP BY EXTRACT(YEAR FROM e.data_egzamin), EXTRACT(MONTH FROM e.data_egzamin)
            ORDER BY 1, 2;
        i NUMBER := 1;
    BEGIN
        FOR vc2 IN c2 LOOP
            kolekcja.EXTEND;
            kolekcja(i) := temp_object_type(vc2.rok, vc2.miesiac, vc2.liczba_s);
            i := i+1;
        END LOOP;
        RETURN kolekcja;
    END;
BEGIN
    FOR vc1 IN c1 LOOP
        kolekcja := getStudentNumber(vc1.id_egzaminator);
        INSERT INTO EgzaminatorzyAnalizaPrzedKolosem VALUES (vc1.id_egzaminator, vc1.imie, vc1.nazwisko, kolekcja);
    END LOOP;
END;

SELECT ea.id_egzaminator, ea.imie, ea.nazwisko, nt.rok, nt.miesiac, nt.liczba_osob FROM EgzaminatorzyAnalizaPrzedKolosem ea, TABLE(ea.kolekcja) nt;

/*Zadanie 1.
Utworzyć kolekcję typu tablica zagnieżdżona i nazwać ją NT_Studenci.
W kolekcji należy umieścić elementy, z których każdy opisuje studenta oraz 
całkowitą liczbę punktów zdobytych przez niego ze wszystkich egzaminów.
Do opisu studenta należy użyć jego identyfikatora, nazwiska i imienia.
Zainicjować wartości elementów kolekcji na podstawie danych z tabel Studenci i Egzaminy.
Zapewnić, by dane umieszczane były w takiej kolejności, aby na początku znaleźli się studenci, 
którzy zdobyli największą liczbę punktów.
Po zainicjowaniu kolekcji, wyświetlić wartości znajdujące się w poszczególnych jej elementach.*/
DECLARE
    TYPE recType IS RECORD (idS VARCHAR2(10), imie VARCHAR2(50), nazwisko VARCHAR2(50), liczba_p NUMBER);
    TYPE NT_Studenci IS TABLE OF recType;
    CURSOR c1 IS 
        SELECT s.id_student idS, s.imie imie, s.nazwisko nazwisko, COALESCE(SUM(e.punkty), 0) liczba_p FROM studenci s 
        LEFT JOIN egzaminy e ON s.id_student = e.id_student
        GROUP BY s.id_student, s.imie, s.nazwisko
        ORDER BY 4 DESC;
    kolekcja NT_Studenci := NT_Studenci();
    i NUMBER := 1;
BEGIN 
    FOR vc1 IN c1 LOOP
        kolekcja.EXTEND;
        kolekcja(i) := recType(vc1.idS, vc1.imie, vc1.nazwisko, vc1.liczba_p);
        i := i+1;
    END LOOP;
    FOR j IN 1 .. kolekcja.COUNT() LOOP
        DBMS_OUTPUT.PUT_LINE(kolekcja(j).idS||' ' ||kolekcja(j).imie||' ' ||kolekcja(j).nazwisko||' Liczba punktow: '||kolekcja(j).liczba_p);
	END LOOP;
END;

/*Zadanie 3.
Dla każdego przedmiotu wskazać tych studentów, którzy zdawali egzamin w ostatnim dniu egzaminowania z tego przedmiotu.
Jeśli nikt nie zdawał egzaminu z danego przedmiotu, należy wyświetlić odpowiedni komunikat.
W rozwiązaniu zadania należy wykorzystać podprogram (funkcja lub procedura) PL/SQL, 
który umożliwi wyznaczenie daty ostatniego dnia egzaminowania z danego przedmiotu.*/
DECLARE
    exam_date DATE;
    CURSOR c1 IS SELECT id_przedmiot, nazwa_przedmiot FROM przedmioty;
    CURSOR c2(idP przedmioty.id_przedmiot%TYPE) IS
        SELECT DISTINCT s.id_student idS, s.imie imie, s.nazwisko nazwisko FROM studenci s 
        INNER JOIN egzaminy e ON s.id_student = e.id_student 
        WHERE e.id_przedmiot = idP ORDER BY 1;
    FUNCTION getLastDate(idP przedmioty.id_przedmiot%TYPE) RETURN DATE IS
        exam_date DATE;
    BEGIN
        SELECT DISTINCT data_egzamin INTO exam_date FROM egzaminy WHERE id_przedmiot = idP ORDER BY 1 DESC FETCH FIRST 1 ROW ONLY;
        RETURN exam_date;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RETURN null;
    END getLastDate;
BEGIN
    FOR vc1 IN c1 LOOP
        exam_date := getLastDate(vc1.id_przedmiot);
        IF exam_date IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Brak egzaminow z przedmiotu '||vc1.nazwa_przedmiot||' '||vc1.id_przedmiot);
        ELSE
            FOR vc2 IN c2(vc1.id_przedmiot) LOOP
                DBMS_OUTPUT.PUT_LINE(vc1.id_przedmiot||' '||vc1.nazwa_przedmiot||' '||exam_date||' '||vc2.idS||' '||vc2.imie||' '||vc2.nazwisko);
            END LOOP;
        END IF;
    END LOOP;
END;

/*Zadanie 4.
Utworzyć w bazie danych tabelę o nazwie Analityka. 
Tabela powinna zawierać informacje o liczbie egzaminów poszczególnych egzaminatorów w poszczególnych ośrodkach.
W tabeli utworzyć 4 kolumny. Trzy pierwsze kolumny opisują egzaminatora (identyfikator, imię i nazwisko).
Czwarta kolumna o nazwie Osrodki opisuje ośrodek (identyfikator oraz nazwa) oraz liczbę egzaminów danego egzaminatora w tym ośrodku.
Dane dotyczące ośrodka i liczby egzaminów należy umieścić w kolumnie będącej kolekcją typu tablica zagnieżdżona.
Wprowadzić dane do tabeli Analityka na podstawie danych zgromadzonych w tabelach Egzaminy, Osrodki i Egzaminatorzy.
Następnie wyświetlić dane znajdujące się w tabeli Analityka.*/
CREATE OR REPLACE TYPE temp_record_type IS OBJECT (idO VARCHAR2(20), nazwaO VARCHAR2(50), liczba_e NUMBER);
CREATE OR REPLACE TYPE temp_table_type IS TABLE OF temp_record_type;
CREATE TABLE AnalitykaPrzedKolosem (
    id_egzaminator VARCHAR2(10),
    imie VARCHAR2(50),
    nazwisko VARCHAR2(50),
    kolekcja temp_table_type
) NESTED TABLE kolekcja STORE AS tempStored;
DECLARE 
    kolekcja temp_table_type;
    CURSOR c1 IS SELECT id_egzaminator idEgz, imie, nazwisko FROM egzaminatorzy;
    FUNCTION getExaminerExams(idEgzaminator egzaminatorzy.id_egzaminator%TYPE) RETURN temp_table_type IS
        CURSOR c2 IS 
            SELECT o.id_osrodek idO, o.nazwa_osrodek nazwaO, COUNT(e.id_egzamin) liczba_e
            FROM egzaminy e INNER JOIN osrodki o ON o.id_osrodek = e.id_osrodek
            WHERE e.id_egzaminator = idEgzaminator
            GROUP BY o.id_osrodek, o.nazwa_osrodek
            ORDER BY 1;
        kolekcja temp_table_type := temp_table_type();
        i NUMBER := 1;
    BEGIN
        FOR vc2 IN c2 LOOP
            kolekcja.EXTEND;
            kolekcja(i) := temp_record_type(vc2.idO, vc2.nazwaO, vc2.liczba_e);
            i := i+1;
        END LOOP;
        RETURN kolekcja;
    END;
BEGIN
    FOR vc1 IN c1 LOOP
        DBMS_OUTPUT.PUT_LINE(vc1.nazwisko);
        kolekcja := getExaminerExams(vc1.idEgz);
        INSERT INTO AnalitykaPrzedKolosem VALUES (vc1.idEgz, vc1.imie, vc1.nazwisko, kolekcja);
    END LOOP;
END;

SELECT a.id_egzaminator, a.imie, a.nazwisko, nt.idO, nt.nazwaO, nt.liczba_e FROM AnalitykaPrzedKolosem a, TABLE(a.kolekcja) nt;

SELECT * FROM egzaminatorzy;
TRUNCATE TABLE AnalitykaPrzedKolosem;
INSERT INTO egzaminatorzy VALUES('0011', 'Thurnbichler', 'Thomas', 'Krakow');

/* Zadanie 5
Dla każdego ośrodka wskazać tych studentów, którzy zdawali egzamin w tym ośrodku w kolejnych latach. 
W rozwiązaniu zadania wykorzystać podprogram (funkcję lub procedurę) PL/SQL, 
który umożliwia kontrolę uczestnictwa studenta w egzaminie przeprowadzonym w danym ośrodku i w danym roku. */
DECLARE
    CURSOR c1 IS SELECT id_osrodek, nazwa_osrodek FROM osrodki;
    PROCEDURE showStudents(idO osrodki.id_osrodek%TYPE, nazwaO VARCHAR2) IS 
        CURSOR c2 IS 
            SELECT DISTINCT s.id_student idS, s.imie imie, s.nazwisko nazwisko, EXTRACT(YEAR FROM e.data_egzamin) rok
            FROM studenci s INNER JOIN egzaminy e ON s.id_student = e.id_student 
            WHERE e.id_osrodek = idO ORDER BY 4, 1, 3;
    BEGIN
        FOR vc2 IN c2 LOOP
            DBMS_OUTPUT.PUT_LINE(idO||' '||nazwaO||' '||vc2.rok||' '||vc2.idS||' '||vc2.imie||' '||vc2.nazwisko);
        END LOOP;
    END showStudents;
BEGIN
    FOR vc1 IN c1 LOOP
        showStudents(vc1.id_osrodek, vc1.nazwa_osrodek);
    END LOOP;
END;

/*Zadanie 2
Utworzyć w bazie danych tabelę o nazwie StudExamDates. 
Tabela powinna zawierać informacje o studentach oraz datach zdanych egzaminów z poszczególnych przedmiotów. 
W tabeli utworzyć cztery kolumny. 
Trzy kolumny będą opisywać studenta (identyfikator, imię i nazwisko). 
Czwarta - przedmiot (nazwa przedmiotu) oraz datę zdanego egzaminu z tego przedmiotu. 
Dane dotyczące przedmiotu i daty egzaminu należy umieścić w kolumnie będącej kolekcją typu tabela zagnieżdżona. 
Wprowadzić dane do tabeli StudExamDates na podstawie danych zgromadzonych w tabelach Egzaminy, Studenci i Przedmioty. 
Następnie wyświetlić dane znajdujące się w tabeli StudExamDates. 
*/
CREATE OR REPLACE TYPE student_object_type IS OBJECT (nazwa_przedmiot VARCHAR2(50), data_zdania DATE);
CREATE OR REPLACE TYPE student_table_type IS TABLE OF student_object_type;
CREATE TABLE StudExamDatesPrzedKolosem(
    id_student VARCHAR(20),
    imie VARCHAR2(50),
    nazwisko VARCHAR2(50),
    kolekcja student_table_type
) NESTED TABLE kolekcja STORE AS studexamDatesPrzedKolosemStored;
DECLARE
    kolekcja student_table_type;
    CURSOR c1 IS SELECT id_student, imie, nazwisko FROM studenci;
    FUNCTION getStudentPassedExamsDate(idStudent studenci.id_student%TYPE) RETURN student_table_type IS
        CURSOR c2 IS
            SELECT p.nazwa_przedmiot nazwaP, e.data_egzamin dataE FROM egzaminy e 
            INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
            WHERE e.id_student = idStudent AND e.zdal = 'T'
            ORDER BY 1;
        kolekcja student_table_type := student_table_type();
        i NUMBER := 1;
    BEGIN
        FOR vc2 IN c2 LOOP
            kolekcja.EXTEND;
            kolekcja(i) := student_object_type(vc2.nazwaP, vc2.dataE);
            i := i+1;
        END LOOP;
        RETURN kolekcja;
    END;
BEGIN
    FOR vc1 IN c1 LOOP
        kolekcja := getStudentPassedExamsDate(vc1.id_student);
        INSERT INTO StudExamDatesPrzedKolosem VALUES (vc1.id_student, vc1.imie, vc1.nazwisko, kolekcja);
    END LOOP;
END;

SELECT s.id_student, s.imie, s.nazwisko, nt.nazwa_przedmiot, nt.data_zdania FROM StudExamDatesPrzedKolosem s, TABLE(s.kolekcja) nt;

/*
Wypisa桷szystkich student󷠫t󲺹 brali udziaӠw egzaminach w kazdym osrodku
*/
DECLARE
    CURSOR c1 IS SELECT id_osrodek, nazwa_osrodek FROM osrodki;
    CURSOR c2(idO osrodki.id_osrodek%TYPE) IS 
        SELECT DISTINCT s.id_student idS, s.imie imie, s.nazwisko nazwisko FROM studenci s INNER JOIN egzaminy e ON s.id_student = e.id_student WHERE e.id_osrodek = idO;
BEGIN
    FOR vc1 IN c1 LOOP
        FOR vc2 IN c2(vc1.id_osrodek) LOOP
            DBMS_OUTPUT.PUT_LINE(vc1.id_osrodek||' '||vc1.nazwa_osrodek||' '||vc2.idS||' '||vc2.imie||' '||vc2.nazwisko);
        END LOOP;
    END LOOP;
END;





