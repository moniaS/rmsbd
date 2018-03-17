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

--2 - SprawdŸ, czy wiek klienta, imiê i nazwisko s¹ poprawne
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

 -- 3 - Aktualizuj ilosc skladnikow po otrzymaniu nowego zamowienia
 --brakuje rzucic wyjatkiem gdy nie ma wystarczajaco skladnikow -- dokoncze wieczorem :)
CREATE OR REPLACE TRIGGER AktuSkladnikiPoZamowieniu
AFTER INSERT
ON ZAMOWIENIA_DANIA
FOR EACH ROW
DECLARE
  p_skladnik_id skladniki.id%TYPE;
  p_danie_id dania.id%TYPE;
  p_ile_skladnikow NUMBER;
  p_ilosc_na_stanie skladniki.ilosc_na_stanie%TYPE; --potrzebne aby sprawdzic czy jest na stanie wystarczajaco skladnikow
  p_ilosc_dan zamowienia_dania.liczba%TYPE;
  CURSOR cursorSkladniki (idDanie dania.id%TYPE) IS
  SELECT ID_skladnika, Ilosc from Dania_Skladniki
  where id_dania = idDanie;
  zaMaloSkladnikow EXCEPTION;
BEGIN
  p_danie_id := :NEW.id_dania;
  p_ilosc_dan := :NEW.liczba;
  OPEN cursorSkladniki(p_danie_id);
  FETCH cursorSkladniki INTO p_skladnik_id, p_ile_skladnikow;
  WHILE(cursorSkladniki%FOUND) loop
    select ilosc_na_stanie into p_ilosc_na_stanie from skladniki
    where id = p_skladnik_id;
    --DBMS_OUTPUT.PUT_LINE ('Na stanie jest:  ' || p_ilosc_na_stanie || ' skladnikow' );
    if p_ilosc_na_stanie < p_ile_skladnikow * p_ilosc_dan then
      raise zaMaloSkladnikow;
    else
      --DBMS_OUTPUT.PUT_LINE ('Zuzyto ' || p_ile_skladnikow * p_ilosc_dan || ' skladnikow o id ' || p_skladnik_id);
      update skladniki
      set ilosc_na_stanie = ilosc_na_stanie - p_ile_skladnikow * p_ilosc_dan
      where id = p_skladnik_id;
      FETCH cursorSkladniki INTO p_skladnik_id, p_ile_skladnikow;
    end if;
  end loop;
  close cursorSkladniki;
  
  exception
    when zaMaloSkladnikow then
      DBMS_OUTPUT.PUT_LINE ('Za malo skladnikow aby przygotowac danie');
end;

--wstawic nowe zamowienie
insert into zamowienia(data_zamowienia, id_klienta, cena)
values ('01-JAN-2017', 2, 0.0);

--okreslic jakie dania w zamowieniu - przy wykonaniu tego wywolamy trigger
insert into zamowienia_dania(id_zamowienia, id_dania, liczba)
values (21, 4, 10);

--funkcje pomocnicze
update skladniki set ilosc_na_stanie = 21 where id = 2;
delete from zamowienia_dania where id_dania = 4 and id_zamowienia = 21;

