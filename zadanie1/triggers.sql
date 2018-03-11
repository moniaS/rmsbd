-- 1 - Aktualizuj iloœæ sk³adników po wstawieniu rekordu do tabeli dostaw
CREATE OR REPLACE TRIGGER AktualizujIloscSkladnikow
AFTER INSERT
ON Dostawy
FOR EACH ROW
BEGIN
	update Skladniki
	set Ilosc_na_stanie = Ilosc_na_stanie + :new.Ilosc
	where ID = :new.ID_skladnika;
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
  v_imie := :new.imie;
  v_nazwisko := :new.nazwisko;
  v_data_urodzenia := :new.data_urodzenia;
  SELECT MONTHS_BETWEEN(TRUNC(sysdate), TO_DATE(v_data_urodzenia,'DD-MON-YYYY'))/12 INTO v_wiek FROM DUAL;
  if v_wiek < 18 then
    RAISE_APPLICATION_ERROR (-20000, 'Klient nie moze miec mniej niz 18 lat!');
  end if;
  if REGEXP_LIKE(v_imie, '[^A-Za-z]') or REGEXP_LIKE(v_nazwisko, '[^A-Za-z]') then
    RAISE_APPLICATION_ERROR (-20000, 'W imieniu lub nazwisku klienta wystepuja niedozwolone znaki!');  
  end if;  
END;

INSERT INTO Klienci (Imie, Nazwisko, Data_urodzenia, Kontakt, Czy_staly_klient) VALUES
 ('Adam88', 'Adamowicz99', '21-JAN-2017', '500-500-500', 0);