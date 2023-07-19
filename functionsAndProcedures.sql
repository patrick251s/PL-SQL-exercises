/* 209
Przeprowadzić kontrolę, czy w ośrodku (ośrodkach) o nazwie LBS przeprowadzono
egzaminy. Dla każdego ośrodka o podanej nazwie, w którym odbył się egzamin, wyświetlić
odpowiedni komunikat podający liczbę egzaminów. Jeśli nie ma ośrodka o podanej nazwie,
wyświetlić komunikat o treści "Ośrodek o podanej nazwie nie istnieje". Jeśli w ośrodku nie
było egzaminu, należy wyświetlić komunikat "Ośrodek nie uczestniczył w egzaminach". Do
rozwiązania zadania wykorzystać wyjątki systemowe i/lub wyjątki użytkownika. */
--FUNKCJA
DECLARE   
    mex1 EXCEPTION;   
    x NUMBER;      
    nazwa VARCHAR2(255) := 'LBS'; 
    CURSOR C1 IS SELECT id_osrodek FROM osrodki WHERE UPPER(nazwa_osrodek) = nazwa;
    function ifExamExists(pnazwa varchar2) RETURN BOOLEAN IS
        id NUMBER;
        BEGIN
            SELECT DISTINCT 1 INTO id FROM osrodki WHERE nazwa_osrodek = pnazwa;   
            return true;
            EXCEPTION  
                WHEN NO_DATA_FOUND THEN return false;
        END ifExamExists;
BEGIN     
    IF ifExamExists(nazwa) then
        for vc1 in c1 LOOP
            SELECT COUNT(e.id_egzamin) INTO x FROM egzaminy e WHERE e.id_osrodek = vc1.id_osrodek;  
            if x > 0 then
                DBMS_OUTPUT.put_line('W ośrodku o ID=' || vc1.id_osrodek || ' odbyło się '|| x ||' egzaminów');   
            else
                DBMS_OUTPUT.put_line('Ośrodek o ID=' || vc1.id_osrodek||' nie uczestniczył w egzaminach');
            end if;
        END LOOP;
    ELSE
        DBMS_OUTPUT.put_line('Ośrodek o podanej nazwie nie istnieje');   
    END IF;
END;

--PROCEDURA
DECLARE   
    ifExists boolean;   
    x NUMBER;      
    nazwa VARCHAR2(255) := 'LBS'; 
    CURSOR C1 IS SELECT id_osrodek FROM osrodki WHERE UPPER(nazwa_osrodek) = nazwa;
    procedure ifExamExists(pnazwa varchar2, p_ifexists out boolean) IS
        id NUMBER;
        BEGIN
            SELECT DISTINCT 1 INTO id FROM osrodki WHERE nazwa_osrodek = pnazwa;   
            p_ifexists := true;
            EXCEPTION  
                WHEN NO_DATA_FOUND THEN p_ifexists := false;
        END ifExamExists;
BEGIN     
    ifExamExists(nazwa, ifExists);
    if ifExists then
        for vc1 in c1 LOOP
            SELECT COUNT(e.id_egzamin) INTO x FROM egzaminy e WHERE e.id_osrodek = vc1.id_osrodek;  
            if x > 0 then
                DBMS_OUTPUT.put_line('W ośrodku o ID=' || vc1.id_osrodek || ' odbyło się '|| x ||' egzaminów');   
            else
                DBMS_OUTPUT.put_line('Ośrodek o ID=' || vc1.id_osrodek||' nie uczestniczył w egzaminach');
            end if;
        END LOOP;
    ELSE
        DBMS_OUTPUT.put_line('Ośrodek o podanej nazwie nie istnieje');   
    END IF;
END;

SELECT * FROM studenci;
SELECT s.id_student, s.imie, s.nazwisko, SUM(punkty) FROM egzaminy e RIGHT JOIN studenci s ON e.id_student = s.id_student GROUP BY s.id_student, s.imie, s.nazwisko;
--Jesli student istnieje i nic nie pisal to ma null
SELECT s.id_student, s.imie, s.nazwisko, SUM(punkty) FROM egzaminy e RIGHT JOIN studenci s ON e.id_student = s.id_student 
WHERE s.id_student = '0000023' GROUP BY s.id_student, s.imie, s.nazwisko;
--Jesli student nie istnieje to nic nie zwraca
SELECT s.id_student, s.imie, s.nazwisko, SUM(punkty) FROM egzaminy e RIGHT JOIN studenci s ON e.id_student = s.id_student 
WHERE s.id_student = '0000024' GROUP BY s.id_student, s.imie, s.nazwisko;
--Funkcja SUM zwróci null jeśli nic nie ma, zatem nie można użyć no data found
/*257. 
Wyświetlić informację o liczbie punktów uzyskanych z egzaminów przez każdego
studenta. W odpowiedzi należy uwzględnić również tych studentów, którzy jeszcze nie
zdawali egzaminów. Liczbę punktów należy wyznaczyć używając funkcji. Jeżeli student
nie zdawał egzaminu, należy wyświetlić odpowiedni komunikat. Zadanie należy
zrealizować, wykorzystując kod PL/SQL. */
DECLARE
    pointsFromFunction FLOAT;
    CURSOR c1 IS SELECT id_student FROM studenci;
    FUNCTION getSumStudentPoints(idStudent studenci.id_student%TYPE) RETURN FLOAT IS
        totalPoints FLOAT;
    BEGIN
        SELECT NVL(ROUND(SUM(punkty), 2), -1) INTO totalPoints FROM egzaminy WHERE id_student = idStudent;
        RETURN totalPoints;
    END getSumStudentPoints;
BEGIN
    FOR vc1 IN c1 LOOP
        pointsFromFunction := getSumStudentPoints(vc1.id_student);
        IF pointsFromFunction = -1 THEN
            DBMS_OUTPUT.put_line('Student o ID=' || vc1.id_student || ' nie zdawal żadnego egzaminu');
        ELSE
            DBMS_OUTPUT.put_line('Student o ID=' || vc1.id_student || ' uzyskal ' || pointsFromFunction || ' punktów');
        END IF;
    END LOOP;
END;

DECLARE
    pointsFromFunction FLOAT;
    CURSOR c1 IS SELECT id_student FROM studenci;
    FUNCTION getSumStudentPoints(idStudent studenci.id_student%TYPE) RETURN FLOAT IS
        totalPoints FLOAT;
    BEGIN
        SELECT ROUND(SUM(punkty), 2) INTO totalPoints FROM egzaminy WHERE id_student = idStudent;
        IF totalPoints IS NULL THEN
            RETURN -1;
        END IF;
        RETURN totalPoints;
    END getSumStudentPoints;
BEGIN
    FOR vc1 IN c1 LOOP
        pointsFromFunction := getSumStudentPoints(vc1.id_student);
        IF pointsFromFunction = -1 THEN
            DBMS_OUTPUT.put_line('Student o ID=' || vc1.id_student || ' nie zdawal żadnego egzaminu');
        ELSE
            DBMS_OUTPUT.put_line('Student o ID=' || vc1.id_student || ' uzyskal ' || pointsFromFunction || ' punktów');
        END IF;
    END LOOP;
END;

DECLARE
    pointsFromFunction FLOAT;
    CURSOR c1 IS SELECT id_student FROM studenci;
    FUNCTION getSumStudentPoints(idStudent studenci.id_student%TYPE) RETURN FLOAT IS
        totalPoints FLOAT;
    BEGIN
        SELECT ROUND(SUM(punkty), 2) INTO totalPoints FROM egzaminy WHERE id_student = idStudent;
        RETURN totalPoints;
    END getSumStudentPoints;
BEGIN
    FOR vc1 IN c1 LOOP
        pointsFromFunction := getSumStudentPoints(vc1.id_student);
        IF pointsFromFunction IS NULL THEN
            DBMS_OUTPUT.put_line('Student o ID=' || vc1.id_student || ' nie zdawal żadnego egzaminu');
        ELSE
            DBMS_OUTPUT.put_line('Student o ID=' || vc1.id_student || ' uzyskal ' || pointsFromFunction || ' punktów');
        END IF;
    END LOOP;
END;

/* 258
Dla tabeli Egzaminy utworzyć odpowiedni wyzwalacz, który w przypadku zmiany
wartości w kolumnie Zdal z Y na N lub N na Y spowoduje automatyczną zmianę liczby
punktów w kolumnie Punkty (dla Y – wartość od 3 do 5 punktów, dla N – wartość 2 do
2.99). Powyższą operację należy przeprowadzić w podprogramie (samodzielnie
zdecydować, czy będzie to funkcja czy procedura). */

CREATE OR REPLACE TRIGGER changePointsTrigger BEFORE UPDATE OF zdal ON egzaminy FOR EACH ROW
DECLARE
    randomPoints FLOAT;
    PROCEDURE updatePoints(examChar egzaminy.zdal%TYPE, randomPoints OUT FLOAT) IS
    BEGIN
        IF :new.zdal = 'N' THEN
            randomPoints := ROUND(DBMS_RANDOM.VALUE(2, 3), 2);
        ELSE 
            randomPoints := ROUND(DBMS_RANDOM.VALUE(3, 5), 2)+0.01;
        END IF;
        :new.punkty := randomPoints;
    END updatePoints;
BEGIN
    IF :old.zdal != :new.zdal THEN
        updatePoints(:new.zdal, randomPoints);
        IF randomPoints IS NULL THEN
            DBMS_OUTPUT.put_line('Student o ID=' || :new.id_student || ' nie zdawal żadnego egzaminu');
        ELSE
            DBMS_OUTPUT.put_line('Student o ID=' || :new.id_student || ' uzyskal ' || randomPoints || ' punktów w egzaminie o ID='|| :new.id_egzamin);
        END IF;
    END IF;
END; 

SELECT * FROM egzaminy WHERE id_egzamin < 8;
UPDATE egzaminy SET zdal = 'N' WHERE id_egzamin = 3;

/* 261
W tabeli Studenci dokonać aktualizacji danych w kolumnie Nr_ECDL oraz Data_ECDL.
Wartość Nr_ECDL powinna być równa identyfikatorowi studenta, a Data_ECDL – dacie
ostatniego zdanego egzaminu. Wartości te należy wstawić tylko dla tych studentów,
którzy zdali już wszystkie przedmioty. W rozwiązaniu zastosować podprogramy typu
funkcja i procedura (samodzielnie określić strukturę kodu źródłowego w PL/SQL). */
SELECT * FROM studenci;

DECLARE
    numberOfSubjects INTEGER;
    lastStudentExamDate DATE;
    CURSOR c1 IS SELECT id_Student FROM studenci FOR UPDATE;
    FUNCTION getAllSubject RETURN INTEGER IS
    subjectsNumber INTEGER;
    BEGIN
        SELECT COUNT(*) INTO subjectsNumber FROM przedmioty;
        RETURN subjectsNumber;
    END getAllSubject;
    FUNCTION isStudentPassedAllExams(idStudent studenci.id_student%TYPE, allExamsNumber INTEGER) RETURN BOOLEAN IS
    passedExams INTEGER;
    BEGIN
        SELECT COUNT(*) INTO passedExams FROM egzaminy WHERE id_student = idStudent AND zdal = 'T';
        IF passedExams = allExamsNumber THEN
            RETURN TRUE;
        ELSE 
            RETURN FALSE;
        END IF;
    END;
    FUNCTION getLastPassedStudentExam(idStudent studenci.id_student%TYPE) RETURN DATE IS
    lastDate DATE;
    BEGIN
        SELECT MAX(data_egzamin) INTO lastDate FROM egzaminy WHERE id_Student = idStudent;
        RETURN lastDate;
    END;
    PROCEDURE saveNewData(idStudent studenci.id_student%TYPE, lastStudentExamDate DATE) IS 
    BEGIN
        UPDATE studenci SET nr_ecdl = idStudent, data_ecdl = lastStudentExamDate WHERE id_Student = idStudent;
    END;
BEGIN
     numberOfSubjects := getAllSubject;  
     FOR vc1 IN c1 LOOP
        IF isStudentPassedAllExams(vc1.id_student, numberOfSubjects) THEN
            lastStudentExamDate := getLastPassedStudentExam(vc1.id_student);
            saveNewData(vc1.id_Student, lastStudentExamDate);
        END IF;
     END LOOP;
END;

/* 267
Utworzyć procedurę składowaną, która dokona weryfikacji poprawności daty ECDL w
tabeli Studenci. Proces ten polegać będzie na sprawdzeniu, czy data ta jest większa od
bieżącej daty systemowej. Jeśli tak, wówczas należy zmodyfikować taką wartość,
wstawiając bieżącą datę systemową do tabeli Studenci. */
CREATE OR REPLACE PROCEDURE isECDLCorrect(bool IN OUT BOOLEAN, myDate DATE) IS
BEGIN
    IF myDate > SYSDATE THEN
        bool := TRUE;
    END IF;
END isECDLCorrect;

DECLARE
    bool BOOLEAN DEFAULT FALSE;
    CURSOR c1 IS SELECT id_Student, data_ecdl FROM studenci FOR UPDATE OF data_ecdl;
BEGIN
    FOR vc1 IN c1 LOOP
        bool := FALSE;
        isECDLCorrect(bool, vc1.data_ecdl);
        IF bool THEN
            UPDATE studenci SET data_ecdl = SYSDATE WHERE CURRENT OF c1;
        END IF;
    END LOOP;
END;

SELECT * FROM studenci;
UPDATE studenci SET data_ecdl = TO_DATE('02-12-2022', 'dd-mm-yyyy') WHERE id_Student = '0000001';

/* 270 */
CREATE OR REPLACE FUNCTION hasExamPassed(id_stud varchar2, id_przed varchar2) RETURN BOOLEAN IS
    t NUMBER;
BEGIN
    SELECT 1 into t from egzaminy WHERE id_student = id_stud AND id_przedmiot = id_przed AND zdal = 'T';
    RETURN TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN FALSE;
END;
