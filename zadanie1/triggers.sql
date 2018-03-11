-- 1 - Aktualizuj iloœæ sk³adników po wstawieniu rekordu do tabeli dostaw
CREATE OR REPLACE TRIGGER AktualizujIloscSkladnikow
AFTER INSERT
ON Dostawy
FOR EACH ROW
BEGIN
	UPDATE Skladniki
	SET Ilosc_na_stanie = Ilosc_na_stanie + :NEW.Ilosc
	WHERE ID = :NEW.ID_skladnika;
END;

SELECT * FROM Skladniki;
INSERT INTO Dostawy (ID_dostawcy, ID_skladnika, Data_dostawy, Ilosc) VALUES
((SELECT ID FROM Dostawcy WHERE Nazwa='Super Korpo'), 
(SELECT ID from Skladniki WHERE Nazwa='Czekolada'), TO_DATE('12-01-2017','MM-DD-YYYY'), 5);
SELECT * FROM Skladniki;

--2 - SprawdŸ czy wiek klienta, imiê i nazwisko s¹ poprawne
CREATE OR REPLACE TRIGGER SprawdzDaneKlienta
BEFORE INSERT
ON Klienci
FOR EACH ROW
DECLARE
	v_imie VARCHAR2(50);
	v_nazwisko VARCHAR(50);
	v_wiek NUMBER;
	v_data_urodzenia DATE;
BEGIN
	v_imie := :NEW.imie;
	v_nazwisko := :NEW.nazwisko;
	v_data_urodzenia := :NEW.data_urodzenia;
	SELECT MONTHS_BETWEEN(TRUNC(sysdate), TO_DATE(v_data_urodzenia,'DD-MON-YYYY'))/12 INTO v_wiek FROM DUAL;
	IF v_wiek < 18 THEN
		RAISE_APPLICATION_ERROR (-20000, 'Klient nie moze miec mniej niz 18 lat!');
	END IF;
	IF REGEXP_LIKE(v_imie, '[^A-Za-z]') OR REGEXP_LIKE(v_nazwisko, '[^A-Za-z]') THEN
		RAISE_APPLICATION_ERROR (-20000, 'W imieniu lub nazwisku klienta wystepuja niedozwolone znaki!');  
	END IF;  
END;

INSERT INTO Klienci (Imie, Nazwisko, Data_urodzenia, Kontakt, Czy_staly_klient) VALUES
 ('Adam88', 'Adamowicz99', '21-JAN-2017', '500-500-500', 0);