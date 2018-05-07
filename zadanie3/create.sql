-- Tworzenie tabeli Wlasciciele
CREATE TABLE Wlasciciele (
	ID NUMBER(10) NOT NULL  PRIMARY KEY,
	Wlasciciel_spec XMLTYPE;
);

CREATE SEQUENCE Wlasciciele_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Wlasciciele_seq_tr
 BEFORE INSERT ON Wlasciciele FOR EACH ROW
 WHEN (NEW.ID IS NULL)
BEGIN
 SELECT Wlasciciele_seq.NEXTVAL INTO :NEW.ID FROM DUAL;
END;

-- Tworzenie tabeli Kategorie_jedzenia
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

-- Tworzenie tabeli Dania
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

-- Tworzenie tabeli Restauracje
CREATE TABLE Restauracje (
	ID NUMBER(10) NOT NULL  PRIMARY KEY,
	Restauracja_spec CLOB;
);

CREATE SEQUENCE Restauracje_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Restauracje_seq_tr
 BEFORE INSERT ON Restauracje FOR EACH ROW
 WHEN (NEW.ID IS NULL)
BEGIN
 SELECT Restauracje_seq.NEXTVAL INTO :NEW.ID FROM DUAL;
END;

-- Tworzenie tabeli Dania_Restauracje
CREATE TABLE Dania_Restauracje (
	ID_dania NUMBER(10) NOT NULL,
  ID_restauracji NUMBER(10) NOT NULL,
  Zdjecie ORDimage,
  Zdjecie_sygnatura ORDImageSignature,
  CONSTRAINT DR1 PRIMARY KEY (ID_dania, ID_restauracji),
	CONSTRAINT DR2 FOREIGN KEY (ID_dania) REFERENCES Dania (ID),
	CONSTRAINT DR3 FOREIGN KEY (ID_restauracji) REFERENCES Restauracje (ID)
);

-- Tworzenie tabeli Kategorie_jedzenia_Restauracje
CREATE TABLE Kategorie_jedzenia_Restauracje (
	ID_kategorii NUMBER(10) NOT NULL,
  ID_restauracji NUMBER(10) NOT NULL,
  CONSTRAINT KR1 PRIMARY KEY (ID_kategorii, ID_restauracji),
	CONSTRAINT KR2 FOREIGN KEY (ID_kategorii) REFERENCES Kategorie_jedzenia (ID),
	CONSTRAINT KR3 FOREIGN KEY (ID_restauracji) REFERENCES Restauracje (ID)
);

-- Tworzenie tabeli Wlasciciele_Restauracje
CREATE TABLE Wlasciciele_Restauracje (
	ID_wlasciciela NUMBER(10) NOT NULL,
  ID_restauracji NUMBER(10) NOT NULL,
  CONSTRAINT WR1 PRIMARY KEY (ID_wlasciciela, ID_restauracji),
	CONSTRAINT WR2 FOREIGN KEY (ID_wlasciciela) REFERENCES Wlasciciele (ID),
	CONSTRAINT WR3 FOREIGN KEY (ID_restauracji) REFERENCES Restauracje (ID)
);