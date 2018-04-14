--Jako administrator nalezy stworzyc folder
CREATE DIRECTORY IMAGES AS '/home/oracle/Desktop/Images';
GRANT READ, WRITE ON DIRECTORY IMAGES TO rmsbd;

--Wstawienie danych do tabeli Restauracje
CREATE OR REPLACE PROCEDURE DodajRestauracje
(
	p_nazwa restauracje.nazwa%TYPE,
  p_nazwa_ulicy restauracje.nazwa_ulicy%TYPE,
  p_numer_ulicy restauracje.numer_ulicy%TYPE,
	p_miasto restauracje.miasto%TYPE,
	p_nazwa_pliku VARCHAR2
) AS
    obrazek ORDImage;
    ctx RAW(64) := NULL;
    row_id urowid;
BEGIN
    INSERT INTO Restauracje (nazwa, nazwa_ulicy, numer_ulicy, miasto, zdjecie)
             VALUES (p_nazwa, p_nazwa_ulicy, p_numer_ulicy, p_miasto, ORDImage.init('FILE', 'IMAGES', p_nazwa_pliku))
                                   RETURNING zdjecie, rowid INTO obrazek, row_id;
    obrazek.import(ctx); -- ORDImage.import wywo³uje ORDImage.setProperties;
    UPDATE Restauracje SET zdjecie = obrazek WHERE rowid = row_id;  --aktualizacja tabeli o atrybuty 
END;

BEGIN
  DodajRestauracje('Anatewka', '6 Sierpnia', '2/4', 'Lodz', 'anatewka.jpg');
  DodajRestauracje('Angelo', '6 Sierpnia', '1/3', 'Lodz', 'angelo.jpg');
  DodajRestauracje('Galicja', 'Ogrodowa', '19a', 'Lodz', 'galicja.jpg');
  DodajRestauracje('Hot Spoon', 'Drewnowska', '58', 'Lodz', 'hotspoon.jpg');
  DodajRestauracje('Lavash', 'Piotrkowska', '69', 'Lodz', 'lavash.jpg');
  DodajRestauracje('Manekin', '6 Sierpnia', '1', 'Lodz', 'manekin.jpg');
  DodajRestauracje('Otwarte Drzwi', 'Piotrkowska', '120', 'Lodz', 'otwartedrzwi.jpg');
  DodajRestauracje('Pozytyvka', 'Piotrkowska', '72', 'Lodz', 'pozytyvka.jpg');
  DodajRestauracje('Senoritas', 'Moniuszki', '1a', 'Lodz', 'senoritas.jpg');
END;

--Wstawienie danych do tabeli Kategorie_jedzenia
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Zydowska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Wloska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Polska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Europejska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Wschodnioeuropejska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Tajska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Srodkowowschodnia');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Armenska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Srodkowoeuropejska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Srodziemnomorska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Meksykanska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Lacinska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Japonska');
INSERT INTO Kategorie_jedzenia (nazwa) VALUES ('Azjatycka');

--Wstawienie danych do tabeli Kategorie_jedzenia_Restauracje
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (1, 1);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (2, 2);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (3, 3);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (4, 3);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (5, 3);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (14, 4);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (6, 4);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (7, 5);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (8, 5);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (9, 5);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (3, 6);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (9, 6);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (4, 6);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (10, 7);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (3, 8);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (4, 8);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (11, 9);
INSERT INTO Kategorie_jedzenia_Restauracje VALUES (12, 9);

--Wstawienie danych do tabeli Dania
INSERT INTO Dania (nazwa) VALUES ('Nalesniki mascarpone z jagodami');
INSERT INTO Dania (nazwa) VALUES ('Nalesniki z prazonymi jablkami'); 
INSERT INTO Dania (nazwa) VALUES ('Nalesniki z malinami');
INSERT INTO Dania (nazwa) VALUES ('Nalesniki z kurczakiem i szpinakiem');
INSERT INTO Dania (nazwa) VALUES ('Nalesniki po indyjsku');
INSERT INTO Dania (nazwa) VALUES ('Kreplach z kaczk¹ w sosie ¿urawinowym'); 
INSERT INTO Dania (nazwa) VALUES ('Lasagne'); 
INSERT INTO Dania (nazwa) VALUES ('Makaron z kurczakiem i warzywami'); 
INSERT INTO Dania (nazwa) VALUES ('Kebab po ormiañsku z kurczakiem'); 
INSERT INTO Dania (nazwa) VALUES ('Kebab po ormiañsku z wolowiny'); 

--Wstawianie danych do tabeli Dania_Restauracje
CREATE OR REPLACE PROCEDURE DodajDanieDoRestauracji
(
	p_id_dania Dania_Restauracje.id_dania%TYPE,
	p_id_restauracji Dania_Restauracje.id_restauracji%TYPE,
	p_nazwa_pliku VARCHAR2
) AS
    obrazek ORDImage;
    ctx RAW(64) := NULL;
    row_id urowid;
BEGIN
    INSERT INTO Dania_Restauracje (id_dania, id_restauracji, zdjecie)
             VALUES (p_id_dania, p_id_restauracji, ORDImage.init('FILE', 'IMAGES', p_nazwa_pliku))
                                   RETURNING zdjecie INTO obrazek;
    obrazek.import(ctx); -- ORDImage.import wywo³uje ORDImage.setProperties;
    UPDATE Dania_Restauracje SET zdjecie = obrazek WHERE id_dania = p_id_dania AND id_restauracji = p_id_restauracji;  --aktualizacja tabeli o atrybuty 
END;

BEGIN
DodajDanieDoRestauracji(6, 1, 'kreplach.jpg');
DodajDanieDoRestauracji(8, 2, 'lasagne-angelo.jpg');
DodajDanieDoRestauracji(7, 2, 'makaron-kur-angelo.jpg'); 
DodajDanieDoRestauracji(1, 8, 'nalesniki-jag-pozytyvka.jpg');
DodajDanieDoRestauracji(2, 8, 'nalesniki-jab-pozytyvka.jpg');
DodajDanieDoRestauracji(3, 8, 'nalesniki-mal-pozytyvka.jpg');
DodajDanieDoRestauracji(4, 8, 'nalesniki-kur-pozytyvka.jpg');
DodajDanieDoRestauracji(1, 6, 'nalesniki-jag-manekin.jpg');
DodajDanieDoRestauracji(2, 6, 'nalesniki-jab-manekin.jpg');
DodajDanieDoRestauracji(3, 6, 'nalesniki-mal-manekin.jpg');
DodajDanieDoRestauracji(4, 6, 'nalesniki-kur-manekin.jpg');
DodajDanieDoRestauracji(5, 6, 'nalesniki-ind-manekin.jpg');
DodajDanieDoRestauracji(7, 6, 'makaron-kur-angelo.jpg');
DodajDanieDoRestauracji(9, 5, 'kebab-kur-lavash.jpg');
DodajDanieDoRestauracji(10, 5, 'kebab-wol-lavash.jpg');
END;