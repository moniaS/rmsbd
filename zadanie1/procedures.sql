--1
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

--2
CREATE OR REPLACE FUNCTION PodajUdzialProcentowyDostawcow
(
	id_dostawcy NUMBER
) RETURN BINARY_DOUBLE AS
 udzial_procentowy binary_double;
 
BEGIN
	select round((cast(count(ID_dostawcy) as binary_double) / (select cast(count(ID_dostawcy) as binary_double) from Dostawy)), 4) into udzial_procentowy
	from Dostawy
	where ID_dostawcy = id_dostawcy;
	return udzial_procentowy * 100;
END;
