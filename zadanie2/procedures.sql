--Procedura dodajaca zdjecie do wybranej restauracji
set serveroutput on
CREATE OR REPLACE PROCEDURE DodajZdjecieDoRestauracji
(
	p_id_restauracji Restauracje.id%TYPE,
	p_nazwa_pliku VARCHAR2
) AS
    obrazek ORDImage;
    ctx RAW(64) := NULL;
    row_id urowid;
BEGIN
    UPDATE Restauracje 
    SET zdjecie = ORDImage.init('FILE', 'IMAGES', p_nazwa_pliku) WHERE id = p_id_restauracji
    RETURNING zdjecie, rowid INTO obrazek, row_id;
    obrazek.import(ctx); -- ORDImage.import wywo³uje ORDImage.setProperties;
    UPDATE Restauracje SET zdjecie = obrazek WHERE rowid = row_id;  --aktualizacja tabeli o atrybuty 
	
    SELECT zdjecie INTO obrazek FROM Restauracje WHERE id = p_id_restauracji;
    DBMS_OUTPUT.PUT_LINE('Wysokosc obrazka wynosi ' || obrazek.getHeight());
    DBMS_OUTPUT.PUT_LINE('Szerokosc obrazka wynosi ' || obrazek.getWidth());
    DBMS_OUTPUT.PUT_LINE('Rozmiar obrazka wynosi ' || obrazek.getContentLength() || ' bajtow');
    DBMS_OUTPUT.PUT_LINE('Rodzaj pliku to ' || obrazek.getFileFormat());
    DBMS_OUTPUT.PUT_LINE('Rodzaj obrazka to ' || obrazek.getContentFormat());
    DBMS_OUTPUT.PUT_LINE('Rodzaj kompresji to ' || obrazek.getCompressionFormat());
END;

BEGIN
  DodajZdjecieDoRestauracji(9, 'senoritas.jpg');
END;

--Procedura modyfikujaca zdjecie restauracji (powiekszenie, skala szarosci na 8 bitach, obrot o 90 stopni, rozjasnienie)
ALTER TABLE Restauracje ADD zmodyfikowane_zdjecie ORDImage;

CREATE OR REPLACE PROCEDURE ModyfikujZdjecieRestauracji
(
  p_id_restauracji Restauracje.id%TYPE
) AS
    obrazek ORDimage;
    obrazek_zmodyfikowany ORDImage;
BEGIN
    UPDATE Restauracje set zmodyfikowane_zdjecie = ORDImage.init() WHERE id = p_id_restauracji;
    SELECT zdjecie, zmodyfikowane_zdjecie INTO obrazek, obrazek_zmodyfikowany FROM Restauracje
    WHERE id = p_id_restauracji FOR UPDATE of zdjecie, zmodyfikowane_zdjecie;
    obrazek.processCopy('scale 1.2', obrazek_zmodyfikowany);
    obrazek_zmodyfikowany.process('contentFormat=8bitgreyscale');
    obrazek_zmodyfikowany.process('rotate 90');
    obrazek_zmodyfikowany.process('gamma=1.5');
    UPDATE Restauracje set zmodyfikowane_zdjecie = obrazek_zmodyfikowany WHERE id = p_id_restauracji;
END;

BEGIN
  ModyfikujZdjecieRestauracji(9);
END;

--Procedura eksportu zmodyfikowanego zdjecia restauracji
CREATE OR REPLACE PROCEDURE EksportZmodZdjecieRestauracji
(
	p_id_restauracji Restauracje.id%TYPE
)
AS
    obrazek ORDIMAGE;
    ctx raw(64) :=null;
BEGIN
    SELECT zmodyfikowane_zdjecie INTO obrazek FROM Restauracje WHERE id = p_id_restauracji;
    obrazek.export(ctx, 'FILE', 'IMAGES', 'modyfikacja' || p_id_restauracji || '.jpg');
END;

BEGIN
  EksportZmodZdjecieRestauracji(9);
END;

--Procedura eksportu wszystkich zmodyfikowanych zdjec restauracji (z kursorem)
CREATE OR REPLACE PROCEDURE EksportZmodZdjeciaRestauracji
AS 
	id_restauracji Restauracje.id%TYPE;
	zmodyfikowane_zdjecie Restauracje.zmodyfikowane_zdjecie%TYPE;
	CURSOR cursorRestauracje IS
	SELECT id FROM Restauracje;
BEGIN
	OPEN cursorRestauracje;
	FETCH cursorRestauracje INTO id_restauracji;

	WHILE(cursorRestauracje%FOUND) LOOP
		EksportZmodZdjecieRestauracji(id_restauracji);
		FETCH cursorRestauracje INTO id_restauracji;
	END LOOP;
	CLOSE cursorRestauracje;
END;

BEGIN
	EksportZmodZdjeciaRestauracji();
END;

--Procedura modyfikujaca zdjecie dania z restauracji (znak wodny)
CREATE OR REPLACE PROCEDURE ModyfikujZdjecieDaniaRest
(
  p_id_dania Dania_Restauracje.id_dania%TYPE,
  p_id_restauracji Dania_Restauracje.id_restauracji%TYPE
) AS
    obrazek ORDimage;
    obrazek_zmodyfikowany ORDImage;
    dodany_tekst Restauracje.nazwa%TYPE;
    wlasnosci ordsys.ord_str_list;
    logi VARCHAR2(2000);
BEGIN
    SELECT zdjecie INTO obrazek FROM Dania_Restauracje
    WHERE id_restauracji = p_id_restauracji AND id_dania = p_id_dania FOR UPDATE of zdjecie;
    obrazek_zmodyfikowany := obrazek;
    SELECT nazwa INTO dodany_tekst FROM Restauracje WHERE id = p_id_restauracji;
    wlasnosci := ordsys.ord_str_list(
                   'font_name=Times New Roman',
                   'font_style=bold',
                   'font_size=50',
                   'text_color=red',
                   'position_x=100',
                   'position_y=100',
                   'transparency=0.6');
   obrazek.applyWatermark(dodany_tekst, obrazek_zmodyfikowany, logi, wlasnosci);
   UPDATE Restauracje set zdjecie = obrazek_zmodyfikowany WHERE id = p_id_restauracji;
END;

BEGIN
  ModyfikujZdjecieDaniaRest(6, 1);
END;

--Procedura eksportu zmodyfikowanego zdjecia dania z restauracji
CREATE OR REPLACE PROCEDURE EksportZmodZdjecieDania
(
	p_id_dania Dania_Restauracje.id_dania%TYPE,
	p_id_restauracji Dania_Restauracje.id_restauracji%TYPE
)
AS
    obrazek ORDIMAGE;
    ctx raw(64) :=null;
BEGIN
    SELECT zdjecie INTO obrazek FROM Dania_Restauracje WHERE id_restauracji = p_id_restauracji AND id_dania = p_id_dania;
    obrazek.export(ctx, 'FILE', 'IMAGES', 'modyfikacja_danie' || p_id_dania || '_restauracja' || p_id_restauracji || '.jpg');
END;

BEGIN
  EksportZmodZdjecieDania(6, 1);
END;