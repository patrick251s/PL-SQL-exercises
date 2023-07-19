/* 191
Wskazać tych studentów, którzy zdawali egzaminy w ciągu trzech ostatnich dni
egzaminowania. W odpowiedzi umieścić datę egzaminu oraz dane identyfikujące studenta
tj. identyfikator, imię i Nazwisko.*/
DECLARE
    CURSOR c1 IS SELECT DISTINCT data_egzamin FROM egzaminy ORDER BY 1 DESC ;
    CURSOR c2(pdata_egzamin DATE) IS SELECT DISTINCT s.id_student, nazwisko, imie FROM studenci s INNER JOIN egzaminy e
                        ON s.id_student = e.id_student
                        WHERE data_egzamin = pdata_egzamin ;
    vstudent VARCHAR2(100) ;
BEGIN
    FOR vc1 IN c1 LOOP
        EXIT WHEN c1%rowcount > 3 ; /*Rowcount startuje od 1*/
        DBMS_OUTPUT.put_line(vc1.data_egzamin) ;
        FOR vc2 IN c2(vc1.data_egzamin) LOOP
                vstudent := vc2.id_student || ' - ' || vc2.nazwisko || ' ' || vc2.imie ;
                DBMS_OUTPUT.put_line(vstudent) ;
        END LOOP ;
    END LOOP ;
END ;

DECLARE
    CURSOR c1 IS SELECT DISTINCT data_egzamin FROM egzaminy ORDER BY 1 DESC FETCH FIRST 3 ROWS ONLY ;
    CURSOR c2(pdata_egzamin DATE) IS SELECT DISTINCT s.id_student, nazwisko, imie FROM studenci s INNER JOIN egzaminy e
                        ON s.id_student = e.id_student
                        WHERE data_egzamin = pdata_egzamin ;
    vstudent VARCHAR2(100) ;
BEGIN
    FOR vc1 IN c1 LOOP
        DBMS_OUTPUT.put_line(vc1.data_egzamin) ;
        FOR vc2 IN c2(vc1.data_egzamin) LOOP
                vstudent := vc2.id_student || ' - ' || vc2.nazwisko || ' ' || vc2.imie ;
                DBMS_OUTPUT.put_line(vstudent) ;
        END LOOP ;
    END LOOP ;
END;

/*190
Wskazać trzy przedmioty, z których przeprowadzono najwięcej egzaminów. 
W odpowiedzi umieścić nazwę przedmiotu oraz liczbę egzaminów.
*/
/* Szukamy tych przedmiotów, z ktorych liczba egzaminow byla rowna liczba trzech najbardziej licznych egzaminow */ 
DECLARE
    CURSOR c1 IS SELECT DISTINCT COUNT(*) exam_n FROM egzaminy e GROUP BY e.id_przedmiot ORDER BY 1 DESC FETCH FIRST 3 ROWS ONLY; 
    CURSOR c2(exam_number INTEGER) IS SELECT e.id_przedmiot id_p, p.nazwa_przedmiot nazwa_p, COUNT(*) e_number FROM egzaminy e INNER JOIN przedmioty p ON e.id_przedmiot=p.id_przedmiot
                                      GROUP BY e.id_przedmiot, p.nazwa_przedmiot
                                      HAVING COUNT(*) = exam_number;
BEGIN
    FOR vc1 IN c1 LOOP
        FOR vc2 IN c2(vc1.exam_n) LOOP
            DBMS_OUTPUT.put_line(vc2.id_p || ' ' || vc2.nazwa_p || ' ' || vc2.e_number) ;
        END LOOP;
    END LOOP;
END;


/*195 
Wyświetlić informację o liczbie egzaminów zdawanych z poszczególnych przedmiotów
przez poszczególnych studentów. Rezultat należy wyświetlić w takiej postaci, aby na
początku wyświetlały się dane o studencie (identyfikator, Nazwisko, imię), a następnie
informacje o liczbie egzaminów z poszczególnych przedmiotów. */
DECLARE
    CURSOR c IS SELECT id_student, nazwisko, imie FROM studenci;
    CURSOR c2(studentID studenci.id_student%TYPE) IS SELECT p.nazwa_przedmiot nazwaP, COUNT(*) exam_numbers FROM egzaminy e INNER JOIN przedmioty p ON e.id_przedmiot = p.id_przedmiot
    WHERE e.id_Student = studentID GROUP BY e.id_student, p.nazwa_przedmiot;
BEGIN
    FOR dane_student IN c LOOP 
        DBMS_OUTPUT.PUT_LINE(dane_student.id_student || ' ' || dane_student.nazwisko || ' ' || dane_student.imie);
        FOR dane_przedm IN c2(dane_student.id_student) LOOP
            DBMS_OUTPUT.PUT_LINE(dane_przedm.nazwaP || ' ' || dane_przedm.exam_numbers);
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
END;