/* 276
Dla tabeli Egzaminy zdefiniować trigger dla operacji wstawiania nowego rekordu. Będzie
on automatycznie wstawiał datę systemową w polu Data_Egzamin w przypadku, gdy
wartości takiej nie podano w instrukcji INSERT. */
insert into studenci (id_student, nazwisko, imie) values ('0909091','Mitchell','Pete');
CREATE OR REPLACE TRIGGER BIns_Egzaminy BEFORE INSERT ON Egzaminy
    FOR EACH ROW
        BEGIN
            select sysdate into :new.data_egzamin from dual ;
            select max(id_egzamin)+1 into :new.id_egzamin from egzaminy ;
            IF :new.Zdal = 'T' THEN
                :new.punkty := dbms_random.value(3, 5.01) ;
            else
                :new.punkty := dbms_random.value(2, 3) ;
            END IF ;
END ;
insert into egzaminy(id_student, id_przedmiot, id_egzaminator, id_osrodek, zdal) values ('0909091', 1, '0004', 1, 'T');
SELECT * FROM egzaminy ORDER BY id_egzamin DESC;

/* 283
Utworzyć tabelę o nazwie TLOEgzaminy, która będzie zawierać informacje o liczbie
egzaminów przeprowadzonych w poszczególnych ośrodkach. Następnie zdefiniować
odpowiedni wyzwalacz dla tabeli Egzaminy, który w momencie wstawienia nowego
egzaminu spowoduje aktualizację danych w tabeli TLOEgzaminy */
----------
CREATE TABLE TLOEgzaminy
AS (
    Select o.id_osrodek, count(*) as "liczbaEgzaminow" from osrodki o inner join egzaminy eg 
    on o.id_osrodek = eg.id_osrodek
    group by o.id_osrodek
);

CREATE OR REPLACE TRIGGER BU_TLOEgzaminy BEFORE INSERT ON Egzaminy FOR EACH ROW
DECLARE 
    newExamNumber NUMBER;
BEGIN
    SELECT liczbaEgzaminow+1 INTO newExamNumber FROM TLOEgzaminy WHERE id_osrodek = :new.id_osrodek;
    UPDATE TLOEgzaminy SET liczbaEgzaminow = newExamNumber WHERE id_osrodek = :new.id_osrodek;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN INSERT INTO TLOEgzaminy VALUES (:new.id_osrodek, 1);

END BU_TLOEgzaminy;

insert into egzaminy(id_student, id_przedmiot, id_egzaminator, id_osrodek, zdal) 
        values ('0909091', 2, '0004', 1, 'T') ;

/* 281
Dla tabeli Egzaminy zdefiniować odpowiedni wyzwalacz, który zrealizuje aktualizację
danych w tabeli Studenci w kolumnie Nr_ECDL oraz Data_ECDL. Wartość Nr_ECDL
powinna być równa identyfikatorowi studenta, a Data_ECDL – dacie ostatniego zdanego
egzaminu. Wartości te należy wstawić tylko dla tych studentów, którzy zdali już wszystkie
przedmioty (tj. te, które znajdują się w tabeli Przedmioty). Modyfikacja danych w tabeli
Studenci powinna odbyć się automatycznie po zdaniu przez studenta ostatniego egzaminu i
wprowadzeniu danych na ten temat. W rozwiązaniu zastosować podprogramy typu funkcja
i procedura (samodzielnie określić strukturę kodu źródłowego w PL/SQL). */
CREATE OR REPLACE TRIGGER AI_StudentECDL BEFORE INSERT ON Egzaminy FOR EACH ROW
DECLARE
    lastPassedStudentExamDate DATE;

    FUNCTION isStudentPassAllExams(idStudent studenci.id_student%TYPE) RETURN BOOLEAN IS
        allDistinctSubjectsNum NUMBER;
        passedExamsNumberByStudent NUMBER;
    BEGIN
        SELECT COUNT(*) INTO allDistinctSubjectsNum FROM Przedmioty;
        SELECT COUNT(*) INTO passedExamsNumberByStudent FROM Egzaminy WHERE id_student = idStudent AND zdal = 'T';
        IF allDistinctSubjectsNum = passedExamsNumberByStudent THEN 
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END isStudentPassAllExams;
    
    FUNCTION getStudentLastPassedExam(idStudent studenci.id_student%TYPE) RETURN DATE IS
        lastPassedStudentExamDate DATE;
    BEGIN 
        SELECT MAX(data_egzamin) INTO lastPassedStudentExamDate FROM Egzaminy WHERE id_student = idStudent AND zdal = 'T';
        RETURN lastPassedStudentExamDate;
    END getStudentLastPassedExam;
    
    PROCEDURE saveStudentECDL(idStudent studenci.id_student%TYPE, lastExamDate DATE) IS
    BEGIN
        UPDATE Studenci SET nr_ecdl = idStudent, data_ecdl = lastExamDate WHERE id_student = idStudent;
    END saveStudentECDL;
BEGIN 
    IF isStudentPassAllExams(:new.id_student) THEN
        lastPassedStudentExamDate := getStudentLastPassedExam(:new.id_student);
    END IF;
END;

SELECT id_student, COUNT(*) FROM Egzaminy WHERE zdal = 'T' GROUP BY id_student;
SELECT id_przedmiot FROM Egzaminy WHERE zdal = 'T' AND id_Student = '0000015' ORDER BY 1;
--Student 0000015 nie zdal przedmiotu 22 I 23
SELECT COUNT(*) FROM przedmioty;
SELECT * FROM Przedmioty;
SELECT * FROM Egzaminy ORDER BY id_egzamin DESC;
SELECT * FROM Osrodki;
SELECT * FROM Studenci;
INSERT INTO Egzaminy VALUES (2963, '0000001', 13, '0001', '2022-12-08', 3, 'T', 4.91);
INSERT INTO Egzaminy VALUES (2964, '0000015', 22, '0001', '2022-12-07', 3, 'T', 4.91);
INSERT INTO Egzaminy VALUES (2965, '0000015', 23, '0001', '2022-12-08', 3, 'T', 4.91);
DELETE FROM Egzaminy WHERE id_egzamin IN (2964, 2965);

--Sposob Sylwka dziala z before ale tam trzeba dodac -1 do liczby egzaminow i 

/* 284
Utworzyć tabelę o nazwie TLSEgzaminy, która będzie zawierać informacje o liczbie
egzaminów zdawanych przez poszczególnych studentów. Tabela powinna zawierać 4
kolumny (identyfikator studenta, Nazwisko, imię, liczba egzaminów). Następnie
zdefiniować odpowiedni wyzwalacz dla tabeli Egzaminy, który w momencie wstawienia
nowego egzaminu spowoduje aktualizację danych w tabeli TLSEgzaminy. Aktualizacja
danych w tabeli TLSEgzaminy powinna odbywać się z wykorzystaniem procedury. */
CREATE TABLE TLSEgzaminy AS
SELECT s.id_student id_student, s.nazwisko nazwisko, s.imie imie, COUNT(*) liczbaEgzaminow 
FROM studenci s LEFT JOIN egzaminy e ON s.id_student = e.id_student
GROUP BY s.id_student, s.nazwisko, s.imie;

SELECT * FROM TLSEgzaminy;

CREATE OR REPLACE TRIGGER AI_TLSEgzaminy BEFORE INSERT ON Egzaminy FOR EACH ROW
DECLARE
    imie varchar2(50);
    nazwisko varchar2(50);
    idStudent studenci.id_student%TYPE;
    PROCEDURE updateTLS(idStudent studenci.id_student%TYPE) IS
    BEGIN
        UPDATE TLSEgzaminy SET liczbaEgzaminow = liczbaEgzaminow+1 WHERE id_student = :new.id_student;
    END updateTLS;
BEGIN
    SELECT id_student INTO idStudent FROM TLSEgzaminy WHERE id_Student = :new.id_Student;
    updateTLS(:new.id_Student);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            SELECT s.imie, s.nazwisko INTO imie, nazwisko FROM studenci s WHERE s.id_Student = :new.id_Student;
            INSERT INTO TLSEgzaminy VALUES(:new.id_Student, nazwisko, imie, 1);
END;
