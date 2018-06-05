--Wstawienie danych do tabeli Restauracje
CREATE OR REPLACE PROCEDURE DodajRestauracje
(
	p_nazwa restauracje.nazwa%TYPE,
  	p_nazwa_ulicy restauracje.nazwa_ulicy%TYPE,
  	p_numer_ulicy restauracje.numer_ulicy%TYPE,
	p_miasto restauracje.miasto%TYPE,
  	x number,
  	y number
) AS
BEGIN
    INSERT INTO Restauracje (nazwa, nazwa_ulicy, numer_ulicy, miasto, lokalizacja)
             VALUES (p_nazwa, p_nazwa_ulicy, p_numer_ulicy, p_miasto, SDO_GEOMETRY(
              2001, --dwuwymiarowy punkt
              8307, --korzysta ze zdefiniowanego zakresu ukladu wspolrzednych geograficznych
              MDSYS.SDO_POINT_TYPE(x, y, NULL), 
              NULL, 
              NULL));
END;

BEGIN
  DodajRestauracje('Hot Spoon', 'Drewnowska', '58', 'Lodz', 19.447467, 51.780623);
  DodajRestauracje('Farina Bianco', 'Pilsudskiego', '14', 'Lodz', 19.461237, 51.760030);
  DodajRestauracje('Manekin', '6 Sierpnia', '1', 'Lodz', 19.456095, 51.768576);
  DodajRestauracje('In Centro', 'Piotrkowska', '153', 'Lodz', 19.458213, 51.760087);
END;

--Wstawienie danych do tabeli Kategorie_jedzenia
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Wloska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Europejska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Tajska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Srodziemnomorska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Azjatycka');

--Wstawienie danych do tabeli Kategorie_jedzenia_Restauracje
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (3, 1);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (5, 1);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (1, 2);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (2, 2);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (4, 2);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (2, 3);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (1, 4);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (4, 4);

--Wstawienie danych do tabeli Dania
INSERT INTO Dania (nazwa) VALUES ('Nalesniki mascarpone z jagodami');
INSERT INTO Dania (nazwa) VALUES ('Nalesniki z prazonymi jablkami'); 
INSERT INTO Dania (nazwa) VALUES ('Nalesniki z malinami');
INSERT INTO Dania (nazwa) VALUES ('Nalesniki z kurczakiem i szpinakiem');
INSERT INTO Dania (nazwa) VALUES ('Pad tai');
INSERT INTO Dania (nazwa) VALUES ('Pizza margherita'); 
INSERT INTO Dania (nazwa) VALUES ('Lasagne'); 
INSERT INTO Dania (nazwa) VALUES ('Makaron z kurczakiem i warzywami'); 

--Wstawienie danych do tabeli Wlasciciele
INSERT INTO Wlasciciele (imie, nazwisko, email, nr_telefonu) VALUES ('Jan', 'Kowalski', 'kowalski@example.com', '999111999');
INSERT INTO Wlasciciele (imie, nazwisko, email, nr_telefonu) VALUES ('Anna', 'Kowalska', 'kowalska@example.com', '888111999');
INSERT INTO Wlasciciele (imie, nazwisko, email, nr_telefonu) VALUES ('Adam', 'Brzoza', 'brzoza@example.com', '777111999');
INSERT INTO Wlasciciele (imie, nazwisko, email, nr_telefonu) VALUES ('Joanna', 'Debska', 'dembska@example.com', '333444999');

--Wstawienie danych do tabeli Wlasciciele_Restauracje
INSERT INTO Wlasciciele_Restauracje VALUES (1, 1);
INSERT INTO Wlasciciele_Restauracje VALUES (2, 2);
INSERT INTO Wlasciciele_Restauracje VALUES (3, 3);
INSERT INTO Wlasciciele_Restauracje VALUES (4, 4);

--Wstawienie danych do tabeli Klienci
INSERT INTO Klienci (imie, nazwisko, email, nr_telefonu, przyblizona_lokalizacja) VALUES ('Joanna', 'Kowalczyk', 'joanna.kow@gmail.com', '123456789', SDO_GEOMETRY(2001, 8307, MDSYS.SDO_POINT_TYPE(19.457454, 51.763440, NULL), NULL, NULL));
INSERT INTO Klienci (imie, nazwisko, email, nr_telefonu, przyblizona_lokalizacja) VALUES ('Wojciech', 'Wrobel', 'wrobel@example.com', '666444999', SDO_GEOMETRY(2001, 8307, MDSYS.SDO_POINT_TYPE(19.460091, 51.760736, NULL), NULL, NULL));
INSERT INTO Klienci (imie, nazwisko, email, nr_telefonu, przyblizona_lokalizacja) VALUES ('Katarzyna', 'Nowa', 'nowa@example.com', '777555999', SDO_GEOMETRY(2001, 8307, MDSYS.SDO_POINT_TYPE(19.453482, 51.761466, NULL), NULL, NULL));
INSERT INTO Klienci (imie, nazwisko, email, nr_telefonu, przyblizona_lokalizacja) VALUES ('Aleksandra', 'Szczesniak', 'szczesniak@example.com', '656555999', SDO_GEOMETRY(2001, 8307, MDSYS.SDO_POINT_TYPE(19.446444, 51.767548, NULL), NULL, NULL));
