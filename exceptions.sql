/* 206
Podać informację, z których przedmiotów nie przeprowadzono egzaminu. Wyświetlić
nazwę przedmiotu. Uporządkować wyświetlane informacje wg nazwy przedmiotu. Zadanie
wykonać wykorzystując wyjątek systemowy. */
DECLARE
    CURSOR c1 IS SELECT id_przedmiot, nazwa_przedmiot FROM przedmioty;
    x NUMBER;
BEGIN
FOR vc1 IN c1 LOOP
    BEGIN
    SELECT DISTINCT 1 INTO x FROM egzaminy WHERE id_przedmiot = vc1.id_przedmiot;
    -- Jeśli select nic nie zwróci to występuje wyjatek
    EXCEPTION
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(vc1.nazwa_przedmiot);
    END;
END LOOP;
END;

/* 207
Który egzaminator i kiedy egzaminował więcej niż 5 osób w ciągu jednego dnia? Podać
identyfikator, Nazwisko i imię egzaminatora, a także informacje o liczbie egzaminowanych
osób oraz dniu, w których takie zdarzenie miało miejsce. Zadanie wykonać wykorzystując
wyjątek użytkownika. */
DECLARE
my_exception EXCEPTION;
CURSOR c1 IS 
    SELECT e.id_egzaminator idEgzaminator, egz.nazwisko nazwisko, egz.imie imie, e.data_egzamin dataEgz, COUNT(DISTINCT e.id_student) exams_num FROM egzaminy e 
    INNER JOIN egzaminatorzy egz ON e.id_egzaminator = egz.id_egzaminator
    GROUP BY e.id_egzaminator, egz.nazwisko, egz.imie, e.data_egzamin
    ORDER BY 1;
BEGIN
    FOR vc1 IN c1 LOOP
    BEGIN
        IF vc1.exams_num > 4 THEN 
            RAISE my_exception;
        END IF;
        EXCEPTION
            WHEN my_exception THEN
                DBMS_OUTPUT.PUT_LINE(vc1.idEgzaminator || ' ' || vc1.nazwisko || ' ' || vc1.imie || ' ' || vc1.dataEgz || ' ' || vc1.exams_num);
    END;
    END LOOP;
END;

/* 209
Przeprowadzić kontrolę, czy w ośrodku (ośrodkach) o nazwie LBS przeprowadzono
egzaminy. Dla każdego ośrodka o podanej nazwie, w którym odbył się egzamin, wyświetlić
odpowiedni komunikat podający liczbę egzaminów. Jeśli nie ma ośrodka o podanej nazwie,
wyświetlić komunikat o treści "Ośrodek o podanej nazwie nie istnieje". Jeśli w ośrodku nie
było egzaminu, należy wyświetlić komunikat "Ośrodek nie uczestniczył w egzaminach". Do
rozwiązania zadania wykorzystać wyjątki systemowe i/lub wyjątki użytkownika. */
-- no data found 2 razy można
-- 
DECLARE
    CURSOR c1 IS 
    SELECT o.id_osrodek idOsrodek, o.nazwa_osrodek nazwaOsrodek,  COUNT(*) liczbaEgzaminow FROM osrodki o LEFT JOIN egzaminy e ON o.id_osrodek = e.id_osrodek
    WHERE nazwa_osrodek = 'LBS' 
    GROUP BY o.id_osrodek, o.nazwa_osrodek;
    
    exNotExist exception;
    ex0Exams exception;
    isPlaceExist BOOLEAN := FALSE;
BEGIN
    FOR vc1 IN c1 LOOP
    BEGIN
        isPlaceExist := TRUE;
        IF vc1.liczbaEgzaminow = 0 THEN
            RAISE ex0Exams;
        END IF;
        DBMS_OUTPUT.put_line('Ośrodek ' || vc1.nazwaOsrodek || ' o id  '|| vc1.idOsrodek || ': ' || vc1.liczbaEgzaminow);
        EXCEPTION
            WHEN ex0Exams THEN
                DBMS_OUTPUT.Put_line('Ośrodek ' || vc1.nazwaOsrodek || ' o id  '|| vc1.idOsrodek ||' nie uczestniczył w egzaminach');
    END;
    END LOOP;
    
    IF isPlaceExist = FALSE THEN
        RAISE exNotExist;
    END IF;
    
    EXCEPTION 
        WHEN exNotExist THEN 
        DBMS_OUTPUT.Put_line('Ośrodek o podanej nazwie nie istnieje');
END;

insert into osrodki VALUES(30, 'POLLUB', 'Lublin');

DECLARE   
    mex1 EXCEPTION;   
    x NUMBER;   
    id NUMBER;   
    nazwa VARCHAR2(255) := 'LBS'; 
    CURSOR C1 IS SELECT id_osrodek FROM osrodki WHERE UPPER(nazwa_osrodek) = nazwa;
BEGIN   
    BEGIN   
    SELECT DISTINCT 1 INTO id FROM osrodki WHERE nazwa_osrodek = nazwa;   
    EXCEPTION  
        WHEN NO_DATA_FOUND THEN RAISE mex1;  
    END;  
    for vc1 in c1 LOOP
        SELECT COUNT(e.id_egzamin) INTO x FROM egzaminy e WHERE e.id_osrodek = vc1.id_osrodek;  
        if x > 0 then
            DBMS_OUTPUT.put_line('W ośrodku o ID=' || vc1.id_osrodek || ' odbyło się '|| x ||' egzaminów');   
        else
            DBMS_OUTPUT.put_line('Ośrodek o ID=' || vc1.id_osrodek||' nie uczestniczył w egzaminach');
        end if;
    END LOOP;
    
    EXCEPTION     
        WHEN mex1 THEN DBMS_OUTPUT.put_line('Ośrodek o podanej nazwie nie istnieje');   
END;
