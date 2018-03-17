--1 - Dodawanie skladnika 
CREATE OR REPLACE PROCEDURE DodajSkladnik
(
	p_Nazwa VARCHAR2,
	p_Jednostka VARCHAR2
) AS
BEGIN
	INSERT INTO Skladniki (Nazwa, Ilosc_na_stanie, Jednostka)
	VALUES (p_Nazwa, 0, p_Jednostka);
END;

BEGIN
	DodajSkladnik('Czekoladki mleczne', 'g');
END;

--2 - Podanie udziału procentowego dostawców na podstawie tabeli Dostawy
CREATE OR REPLACE FUNCTION PodajUdzialProcentowyDostawcow
(
	id_d NUMBER
) RETURN BINARY_DOUBLE AS
	udzial_procentowy BINARY_DOUBLE;
BEGIN
	SELECT ROUND(COUNT(ID_dostawcy) / (SELECT COUNT(ID_dostawcy) FROM Dostawy), 4) INTO udzial_procentowy
	FROM Dostawy
	WHERE ID_dostawcy = id_d
	GROUP BY ID_dostawcy;
	RETURN udzial_procentowy * 100;
END;

SELECT id_dostawcy, PodajUdzialProcentowyDostawcow(id_dostawcy) udzial_procentowy FROM dostawy GROUP BY id_dostawcy;

--3 - Wypisanie brakujących składników oraz ich potencjalnych dostawców (kursory, pętla WHILE, instrukcje warunkowe)
CREATE OR REPLACE PROCEDURE WypiszBrakująceSkładniki
AS
	v_NazwaSkladnika VARCHAR2(50); 
	v_IDSkladnika NUMBER(10); 
	v_NazwaDostawcy VARCHAR2(50);
	v_Dostawcy VARCHAR2(50);
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
	FETCH cursorSkladniki INTO v_IDSkladnika, v_NazwaSkladnika;
	IF cursorSkladniki%FOUND THEN
		DBMS_OUTPUT.put_line('Brakuje składników:');
	ELSE  
		DBMS_OUTPUT.put_line('Wszystkie składniki są na stanie.');
	END IF;
	WHILE cursorSkladniki%FOUND LOOP
		OPEN cursorDostawcySkladnika(v_IDSkladnika);
		FETCH cursorDostawcySkladnika INTO v_NazwaDostawcy;
		IF (cursorDostawcySkladnika%FOUND) THEN 
			v_Dostawcy := v_NazwaDostawcy;
			FETCH cursorDostawcySkladnika INTO v_NazwaDostawcy;
		ELSE
			v_Dostawcy := 'Brak dostawców'; 
		END IF;
			
		WHILE cursorDostawcySkladnika%FOUND LOOP --Wstawianie nazw dostawców do zmiennej dostawcy
			v_Dostawcy := v_Dostawcy || ', ' || v_NazwaDostawcy;
			FETCH cursorDostawcySkladnika INTO v_NazwaDostawcy;
		END LOOP;
		CLOSE cursorDostawcySkladnika;

		DBMS_OUTPUT.put_line(v_NazwaSkladnika || '  -->  potencjalni dostawcy: ' || v_Dostawcy);

		FETCH cursorSkladniki INTO v_IDSkladnika, v_NazwaSkladnika;
	END LOOP; 
	CLOSE cursorSkladniki;
END;

UPDATE Skladniki SET Ilosc_na_stanie = 0 WHERE ID = 1;

EXECUTE RMSBD.WypiszBrakująceSkładniki;

--4 - Podanie profitu z dania na podstawie ceny składników i ceny dania (kursor, pętla WHILE)
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
	FETCH cursorSkladniki INTO v_IDSkladnika, v_WykorzystywanaIloscSkladnika;

	WHILE(cursorSkladniki%FOUND) LOOP
		SELECT ID_dostawcy INTO v_ID_Dostawcy FROM Dostawy WHERE ID_skladnika = v_IDSkladnika AND rownum = 1 ORDER BY Data_dostawy ASC;
		SELECT Cena INTO Cena_Skladnika FROM Dostawcy_Skladniki WHERE ID_dostawcy = v_ID_Dostawcy AND ID_skladnika = v_IDSkladnika;

		v_cena_skladnikow := v_cena_skladnikow + (Cena_Skladnika * v_WykorzystywanaIloscSkladnika);

		FETCH cursorSkladniki INTO v_IDSkladnika, v_WykorzystywanaIloscSkladnika;
	END LOOP;
	CLOSE cursorSkladniki;
	RETURN ROUND(v_cena_dania - v_cena_skladnikow, 2);
END;

SELECT Nazwa, ProfitZDania(ID) AS ProfitZDania FROM Dania;

--5 - Oblicz czas przygotowania zamówień (kursor, pętla FOR)
CREATE OR REPLACE FUNCTION ObliczCzasPrzygotZamowienia
(
	v_id_zamowienia NUMBER
) RETURN INTERVAL DAY TO SECOND AS
CURSOR cursorDaniaZamowienia IS
	SELECT id_dania from Zamowienia_Dania
	WHERE id_zamowienia = v_id_zamowienia;
	v_czas_przygotowania_calk INTERVAL DAY(0) TO SECOND(0) := '0 0:0:0.0';
	v_czas_przygotowania_dania INTERVAL DAY(0) TO SECOND(0) := '0 0:0:0.0';
BEGIN
	FOR danie IN cursorDaniaZamowienia
	LOOP
		SELECT czas_przygotowania INTO v_czas_przygotowania_dania FROM Dania
		WHERE id = danie.id_dania;
		v_czas_przygotowania_calk := v_czas_przygotowania_calk + v_czas_przygotowania_dania;
	END LOOP;
	RETURN v_czas_przygotowania_calk;
END;

SELECT ID, obliczczasprzygotzamowienia(ID) czas_przygotowania_zam FROM Zamowienia;

--6 -- Zmiana liczby dań w zamówienia (wyjątki)
CREATE OR REPLACE PROCEDURE ZmienLiczbeDanNaZamowieniu
(
	p_id_zamowienia NUMBER,
	p_id_dania NUMBER,
  p_liczba NUMBER
) AS
  Zamowienie_nie_odnalezione EXCEPTION;
  Za_duza_liczba_zamowionych_dan EXCEPTION;
BEGIN
  BEGIN
  IF p_liczba > 15 THEN
      RAISE Za_duza_liczba_zamowionych_dan;
  END IF;    
  UPDATE Zamowienia_Dania
  SET liczba = p_liczba
  WHERE id_dania = p_id_dania
  AND id_zamowienia = p_id_zamowienia;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          RAISE Zamowienie_nie_odnalezione;
  END;
  EXCEPTION
      WHEN Zamowienie_nie_odnalezione THEN
          DBMS_OUTPUT.PUT_LINE ('Nie ma zamowienia z wybranym daniem');
          DBMS_OUTPUT.PUT_LINE (SQLERRM);
          DBMS_OUTPUT.PUT_LINE (SQLCODE);
      WHEN Za_duza_liczba_zamowionych_dan THEN
          DBMS_OUTPUT.PUT_LINE ('Nie jestemy w stanie zrealizowac takiego duzego zamowienia :(');
          DBMS_OUTPUT.PUT_LINE (SQLERRM);
          DBMS_OUTPUT.PUT_LINE (SQLCODE);
END;

EXECUTE ZmienLiczbeDanNaZamowieniu(5, 1, 2);
EXECUTE ZmienLiczbeDanNaZamowieniu(1, 1, 20);

--7 -dodanie nowej dostawy - potrzebne przy schedulerze
create or replace 
PROCEDURE zaopatrzenie(
  p_id_dostawcy dostawy.id_dostawcy%TYPE,
  p_id_skladnika dostawy.id_skladnika%TYPE,
  p_ilosc dostawy.ilosc%TYPE
) as
begin
  insert into dostawy (id_dostawcy, id_skladnika, data_dostawy, ilosc)
  values (p_id_dostawcy, p_id_skladnika, sysdate, p_ilosc);
end;
begin
  zaopatrzenie(3, 3, 5);
end;

insert into dostawy (id_dostawcy, id_skladnika, data_dostawy, ilosc)
  values (5, 2, sysdate, 10);
