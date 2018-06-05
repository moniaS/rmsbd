-------------------RESTAURACJE----------------------------------
CREATE TABLE Restauracje (
	ID NUMBER(10) NOT NULL  PRIMARY KEY,
	Nazwa VARCHAR2(50 CHAR) NOT NULL,
  	Nazwa_ulicy VARCHAR2(50 CHAR) NOT NULL,
  	Numer_ulicy VARCHAR2(10 CHAR) NOT NULL,
 	Miasto VARCHAR2(20 CHAR) NOT NULL,
 	Lokalizacja "SDO_GEOMETRY",
 	Powierzchnia "SDO_GEOMETRY"
);

CREATE SEQUENCE Restauracje_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Restauracje_seq_tr
 BEFORE INSERT ON Restauracje FOR EACH ROW
 WHEN (NEW.ID IS NULL)
BEGIN
 SELECT Restauracje_seq.NEXTVAL INTO :NEW.ID FROM DUAL;
END;

--zdefiniowanie zakresu wspolrzednych danych w tabeli Restauracje
--wymagane aby dla kazdej kombinacji tabela-kolumna dla ktorej chcemy utworzyc Spatial index
insert into user_sdo_geom_metadata 
	(table_name,column_name,diminfo,srid)
	values (
		'Restauracje','Lokalizacja',
		sdo_dim_array(
			sdo_dim_element('X',19.416744, 19.484454, 0.05),
			sdo_dim_element('Y',51.754124, 51.791678, 0.05)
		),
		8307 -- SRID dla 'Longitude / Latitude (WGS 84)' uklad wspolrzednych
	); 

CREATE INDEX rest_lok_spatial_index
   ON Restauracje(Lokalizacja)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX;



insert into user_sdo_geom_metadata 
(table_name,column_name,diminfo,srid)
values (
	'Restauracje','Powierzchnia',
	sdo_dim_array( 
		sdo_dim_element('X',19.416744, 19.484454, 0.05),
		sdo_dim_element('Y',51.754124, 51.791678, 0.05)
	),
	8307
); 

CREATE INDEX rest_pow_spatial_index
   ON Restauracje(powierzchnia)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX;


-----------------KLIENCI----------------------------------------
CREATE TABLE Klienci(
	ID NUMBER(10) NOT NULL PRIMARY KEY,
  	Imie VARCHAR2(30 CHAR),
  	Nazwisko VARCHAR2(30 CHAR),
  	Email VARCHAR2(50 CHAR) NOT NULL,
  	Nr_telefonu VARCHAR2(10 CHAR),
  	Przyblizona_lokalizacja "SDO_GEOMETRY"
);

CREATE SEQUENCE Klienci_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Klienci_seq_tr
 BEFORE INSERT ON Klienci FOR EACH ROW
 WHEN (NEW.ID IS NULL)
BEGIN
 SELECT Klienci_seq.NEXTVAL INTO :NEW.ID FROM DUAL;
END;


--zdefiniowanie zakresu wspolrzednych danych w tabeli Klienci dla kolumny Przyblizona_lokalizacja
--wymagane dla kazdej kombinacji tabela-kolumna dla ktorej chcemy utworzyc Spatial index
insert into user_sdo_geom_metadata 
	(table_name,column_name,diminfo,srid)
	values (
		'Klienci','Przyblizona_lokalizacja',
		sdo_dim_array( 
			sdo_dim_element('X',19.416744, 19.484454, 0.05),
			sdo_dim_element('Y',51.754124, 51.791678, 0.05)
		),
		8307
	); 

CREATE INDEX klienci_lok_spatial_index
   ON Klienci(Przyblizona_lokalizacja)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-----------------WLASCICIELE-------------------------------------
CREATE TABLE Wlasciciele (
	ID NUMBER(10) NOT NULL  PRIMARY KEY,
	Imie VARCHAR2(50 CHAR) NOT NULL,
  	Nazwisko VARCHAR2(50 CHAR) NOT NULL,
  	Email VARCHAR2(50 CHAR) NOT NULL,
  	Nr_telefonu VARCHAR2(10 CHAR)
);

CREATE SEQUENCE Wlasciciele_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Wlasciciele_seq_tr
 BEFORE INSERT ON Wlasciciele FOR EACH ROW
 WHEN (NEW.ID IS NULL)
BEGIN
 SELECT Wlasciciele_seq.NEXTVAL INTO :NEW.ID FROM DUAL;
END;


---------------KATEGORIE JEDZENIA--------------------------------
CREATE TABLE Kategorie_jedzenia (
	ID NUMBER(10) NOT NULL  PRIMARY KEY,
	Nazwa VARCHAR2(50 CHAR) NOT NULL
);

CREATE SEQUENCE Kategorie_jedzenia_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Kategorie_jedzenia_seq
 BEFORE INSERT ON Kategorie_jedzenia FOR EACH ROW
 WHEN (NEW.ID IS NULL)
BEGIN
 SELECT Kategorie_jedzenia_seq.NEXTVAL INTO :NEW.ID FROM DUAL;
END;



---------------DANIA----------------------------------------------
CREATE TABLE Dania (
	ID NUMBER(10) NOT NULL  PRIMARY KEY,
	Nazwa VARCHAR2(50 CHAR) NOT NULL
);

CREATE SEQUENCE Dania_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Dania_seq_tr
 BEFORE INSERT ON Dania FOR EACH ROW
 WHEN (NEW.ID IS NULL)
BEGIN
 SELECT Dania_seq.NEXTVAL INTO :NEW.ID FROM DUAL;
END;


---------------------Dania_Restauracje-----------------------------
CREATE TABLE Dania_Restauracje (
	ID_dania NUMBER(10) NOT NULL,
  ID_restauracji NUMBER(10) NOT NULL,
  CONSTRAINT DR1 PRIMARY KEY (ID_dania, ID_restauracji),
	CONSTRAINT DR2 FOREIGN KEY (ID_dania) REFERENCES Dania (ID),
	CONSTRAINT DR3 FOREIGN KEY (ID_restauracji) REFERENCES Restauracje (ID)
);

--------------------Kategorie_jedzenia_Restauracje-------------------
CREATE TABLE Kategorie_jedzenia_Restauracje (
	ID_kategorii NUMBER(10) NOT NULL,
  ID_restauracji NUMBER(10) NOT NULL,
  CONSTRAINT KR1 PRIMARY KEY (ID_kategorii, ID_restauracji),
	CONSTRAINT KR2 FOREIGN KEY (ID_kategorii) REFERENCES Kategorie_jedzenia (ID),
	CONSTRAINT KR3 FOREIGN KEY (ID_restauracji) REFERENCES Restauracje (ID)
);

-----------------------Wlasciciele_Restauracje-----------------------
CREATE TABLE Wlasciciele_Restauracje (
	ID_wlasciciela NUMBER(10) NOT NULL,
  ID_restauracji NUMBER(10) NOT NULL,
  CONSTRAINT WR1 PRIMARY KEY (ID_wlasciciela, ID_restauracji),
	CONSTRAINT WR2 FOREIGN KEY (ID_wlasciciela) REFERENCES Wlasciciele (ID),
	CONSTRAINT WR3 FOREIGN KEY (ID_restauracji) REFERENCES Restauracje (ID)
);