--1 - Dodawanie skladnika 
CREATE OR REPLACE PROCEDURE DodajSkladnik
(
	p_Nazwa varchar2,
	p_Jednostka VARCHAR2
) AS
BEGIN
	INSERT INTO Skladniki (Nazwa, Ilosc_na_stanie, Jednostka)
	VALUES (p_Nazwa, 0, p_Jednostka);
END;

begin
DodajSkladnik('Czekoladki mleczne', 'g');
end;

--2 - Podanie udziału procentowego dostawców na podstawie tabeli Dostawy
CREATE OR REPLACE FUNCTION PodajUdzialProcentowyDostawcow
(
	id_d NUMBER
) RETURN BINARY_DOUBLE AS
 udzial_procentowy binary_double;
 liczba_dostaw_dostawcy number;
 liczba_wszystkich_dostaw number;
BEGIN
	select round(count(ID_dostawcy) / (select count(ID_dostawcy) from Dostawy), 4) into udzial_procentowy
	from Dostawy
	where ID_dostawcy = id_d
	group by ID_dostawcy;
	return udzial_procentowy * 100;
END;

select id_dostawcy, PodajUdzialProcentowyDostawcow(id_dostawcy) udzial_procentowy from dostawy group by id_dostawcy;

--3 - Wypisanie brakujących składników oraz ich potencjalnych dostawców (kursory, pętle, instrukcje warunkowe)
CREATE OR REPLACE PROCEDURE WypiszBrakująceSkładniki
AS
 v_NazwaSkladnika varchar2(50); 
 v_IDSkladnika NUMBER(10); 
 v_NazwaDostawcy varchar2(50);
 v_Dostawcy varchar2(50);

  --Deklaracja kursora dla składników  
	CURSOR cursorSkladniki IS
	SELECT ID, Nazwa FROM Skladniki	
  WHERE Ilosc_na_stanie = 0;
  --Deklaracja kursora dla dostawców składnika
  CURSOR cursorDostawcySkladnika (IDSkl NUMBER) IS
		SELECT d.Nazwa FROM Dostawcy d, Dostawcy_Skladniki ds
		WHERE d.ID = ds.ID_dostawcy AND ds.ID_skladnika = IDSkl;
  BEGIN
	OPEN cursorSkladniki;
  FETCH cursorSkladniki into v_IDSkladnika, v_NazwaSkladnika;
  IF cursorSkladniki%found 
    THEN  DBMS_OUTPUT.put_line('Brakuje składników:');
  ELSE  
    DBMS_OUTPUT.put_line('Wszystkie składniki są na stanie.');
  END IF;
	WHILE cursorSkladniki%found LOOP
		OPEN cursorDostawcySkladnika(v_IDSkladnika);
		FETCH cursorDostawcySkladnika into v_NazwaDostawcy;
		IF (cursorDostawcySkladnika%FOUND)
			THEN 
				v_Dostawcy := v_NazwaDostawcy;
				FETCH cursorDostawcySkladnika into v_NazwaDostawcy;
		ELSE
		 v_Dostawcy := 'Brak dostawców'; END IF;
			
		WHILE cursorDostawcySkladnika%FOUND LOOP --Wstawianie nazw dostawców do zmiennej dostawcy
			v_Dostawcy := v_Dostawcy || ', ' || v_NazwaDostawcy;
			FETCH cursorDostawcySkladnika into v_NazwaDostawcy;
		END LOOP;
		CLOSE cursorDostawcySkladnika;

		DBMS_OUTPUT.put_line(v_NazwaSkladnika || '  -->  potencjalni dostawcy: ' || v_Dostawcy);

		FETCH cursorSkladniki into v_IDSkladnika, v_NazwaSkladnika;
	END LOOP; 
	CLOSE cursorSkladniki;
END;

update Skladniki set Ilosc_na_stanie = 0 where ID = 1;

execute RMSBD.WypiszBrakująceSkładniki;

--4 - Podanie profitu z dania na podstawie ceny składników i ceny dania (kursory, pętle, instrukcje warunkowe)
CREATE OR REPLACE FUNCTION ProfitZDania
(
	p_id_dania NUMBER
) RETURN BINARY_DOUBLE AS
 v_cena_dania BINARY_DOUBLE;
 v_cena_skladnikow BINARY_DOUBLE;
 v_IDSkladnika NUMBER(10);
 v_WykorzystywanaIloscSkladnika BINARY_DOUBLE;
 v_ID_Dostawcy NUMBER(10);
 Cena_Skladnika BINARY_DOUBLE;
 CURSOR cursorSkladniki IS
 SELECT ID_skladnika, Ilosc FROM Dania_Skladniki
 WHERE ID_dania = p_id_dania;
 
 BEGIN
	v_cena_skladnikow := 0;
	SELECT Cena INTO v_cena_dania FROM Dania WHERE ID = p_id_dania;

	OPEN cursorSkladniki;
	FETCH cursorSkladniki into v_IDSkladnika, v_WykorzystywanaIloscSkladnika;

	WHILE(cursorSkladniki%FOUND)
	loop
		SELECT ID_dostawcy INTO v_ID_Dostawcy FROM Dostawy WHERE ID_skladnika = v_IDSkladnika AND rownum = 1 ORDER BY Data_dostawy ASC;
		SELECT Cena INTO Cena_Skladnika FROM Dostawcy_Skladniki WHERE ID_dostawcy = v_ID_Dostawcy AND ID_skladnika = v_IDSkladnika;

		v_cena_skladnikow := v_cena_skladnikow + (Cena_Skladnika * v_WykorzystywanaIloscSkladnika);

		FETCH cursorSkladniki into v_IDSkladnika, v_WykorzystywanaIloscSkladnika;
	end loop;
	CLOSE cursorSkladniki;
		DBMS_OUTPUT.put_line(v_cena_dania);
		DBMS_OUTPUT.put_line(v_cena_skladnikow);

	RETURN round(v_cena_dania - v_cena_skladnikow, 2);
END;

SELECT Nazwa, ProfitZDania(ID) as ProfitZDania FROM Dania;
