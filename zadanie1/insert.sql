INSERT INTO Skladniki (Nazwa, Ilosc_na_stanie, Jednostka) VALUES ('Mleko', 20, 'l');
INSERT INTO Skladniki (Nazwa, Ilosc_na_stanie, Jednostka) VALUES ('Jab³ka', 5, 'kg');
INSERT INTO Skladniki (Nazwa, Ilosc_na_stanie, Jednostka) VALUES ('Kawior', 15, 'porc');
INSERT INTO Skladniki (Nazwa, Ilosc_na_stanie, Jednostka) VALUES ('Cukinia', 2, 'szt');
INSERT INTO Skladniki (Nazwa, Ilosc_na_stanie, Jednostka) VALUES ('Marchew', 0, 'kg');
INSERT INTO Skladniki (Nazwa, Ilosc_na_stanie, Jednostka) VALUES ('£osoœ', 0.5, 'kg');

INSERT INTO Dostawcy (Nazwa, Miasto, Adres)
 SELECT 'Jab³ex', 'Radom', 'Jab³czana 12' FROM dual UNION ALL 
 SELECT 'Chata wuja Toma', 'Aleksandrów £ódzki', '£odzka 15' FROM dual UNION ALL 
 SELECT 'Rybak Andrzej', 'Sopot', 'D¹browskiego 1' FROM dual UNION ALL 
 SELECT 'Warzywex', 'Radom', 'Warzywna 5' FROM dual UNION ALL 
 SELECT 'Super Korpo', 'Dubaj', 'Super Reach Street' FROM dual;

INSERT INTO Dostawcy_Skladniki (ID_dostawcy, ID_skladnika, Cena)
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Jab³ex'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), 3.00 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Chata wuja Toma'), (SELECT ID from Skladniki WHERE Nazwa='Mleko'), 1.20 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Chata wuja Toma'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), 1.20 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Chata wuja Toma'), (SELECT ID from Skladniki WHERE Nazwa='Marchew'), 1.20 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Rybak Andrzej'), (SELECT ID from Skladniki WHERE Nazwa='Kawior'), 20.00 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Rybak Andrzej'), (SELECT ID from Skladniki WHERE Nazwa='£osoœ'), 7.99 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Warzywex'), (SELECT ID from Skladniki WHERE Nazwa='Cukinia'), 6.00 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Warzywex'), (SELECT ID from Skladniki WHERE Nazwa='Marchew'), 0.90 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Warzywex'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), 3.50 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Super Korpo'), (SELECT ID from Skladniki WHERE Nazwa='Mleko'), 3.00 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Super Korpo'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), 4.00 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Super Korpo'), (SELECT ID from Skladniki WHERE Nazwa='Kawior'), 16.00 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Super Korpo'), (SELECT ID from Skladniki WHERE Nazwa='Cukinia'), 8.00 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Super Korpo'), (SELECT ID from Skladniki WHERE Nazwa='Marchew'), 3.00 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Super Korpo'), (SELECT ID from Skladniki WHERE Nazwa='£osoœ'), 5.00 FROM dual;

INSERT INTO Dostawy (ID_dostawcy, ID_skladnika, Data_dostawy, Ilosc)
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Jab³ex'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), TO_DATE('01-11-2016','MM-DD-YYYY'), 100 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Jab³ex'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), TO_DATE('01-10-2016','MM-DD-YYYY'), 50 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Jab³ex'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), TO_DATE('01-12-2016','MM-DD-YYYY'), 20 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Rybak Andrzej'), (SELECT ID from Skladniki WHERE Nazwa='Kawior'), TO_DATE('06-11-2016','MM-DD-YYYY'), 15 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Rybak Andrzej'), (SELECT ID from Skladniki WHERE Nazwa='£osoœ'), TO_DATE('06-12-2016','MM-DD-YYYY'), 2 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Warzywex'), (SELECT ID from Skladniki WHERE Nazwa='Marchew'), TO_DATE('11-11-2016','MM-DD-YYYY'), 19 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Warzywex'), (SELECT ID from Skladniki WHERE Nazwa='Marchew'), SYSTIMESTAMP, 49 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Chata wuja Toma'), (SELECT ID from Skladniki WHERE Nazwa='Mleko'), TO_DATE('11-10-2016','MM-DD-YYYY'), 15 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Super Korpo'), (SELECT ID from Skladniki WHERE Nazwa='Cukinia'), TO_DATE('11-11-2016','MM-DD-YYYY'), 50 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Super Korpo'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), TO_DATE('11-09-2016','MM-DD-YYYY'), 200 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dostawcy WHERE Nazwa='Super Korpo'), (SELECT ID from Skladniki WHERE Nazwa='Kawior'), TO_DATE('01-12-2016','MM-DD-YYYY'), 5 FROM dual;

INSERT INTO Dania (Nazwa, Opis, Cena, Czas_przygotowania)
 SELECT 'Jab³ecznik', 'Normalny jab³ecznik', 12.99, (INTERVAL '01:00:00' HOUR TO SECOND)  FROM dual UNION ALL 
 SELECT 'Super specja³', 'Super specja³ zawiera niesamowicie tajemn¹ recepturê', 42.00, (INTERVAL '01:20:00' HOUR TO SECOND)   FROM dual UNION ALL 
 SELECT '£osoœ z jab³kiem', 'Autorskie po³¹czenie ³ososia z jab³kiem', 72.99, (INTERVAL '00:33:33' HOUR TO SECOND)  FROM dual UNION ALL 
 SELECT 'Shake z marchewki i cukinii', 'OrzeŸwiaj¹cy napój na lato', 6.99, (INTERVAL '00:10:00' HOUR TO SECOND)  FROM dual;

INSERT INTO Dania_Skladniki (ID_dania, ID_skladnika, Ilosc)
 SELECT (SELECT ID FROM Dania WHERE Nazwa='Jab³ecznik'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), 10 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dania WHERE Nazwa='Super specja³'), (SELECT ID from Skladniki WHERE Nazwa='Kawior'), 1 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dania WHERE Nazwa='Super specja³'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), 0.2 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dania WHERE Nazwa='Super specja³'), (SELECT ID from Skladniki WHERE Nazwa='Cukinia'), 0.3 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dania WHERE Nazwa='£osoœ z jab³kiem'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), 1 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dania WHERE Nazwa='£osoœ z jab³kiem'), (SELECT ID from Skladniki WHERE Nazwa='£osoœ'), 1 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dania WHERE Nazwa='Shake z marchewki i cukinii'), (SELECT ID from Skladniki WHERE Nazwa='Mleko'), 0.5 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dania WHERE Nazwa='Shake z marchewki i cukinii'), (SELECT ID from Skladniki WHERE Nazwa='Jab³ka'), 0.2 FROM dual UNION ALL 
 SELECT (SELECT ID FROM Dania WHERE Nazwa='Shake z marchewki i cukinii'), (SELECT ID from Skladniki WHERE Nazwa='Cukinia'), 0.2 FROM dual;

INSERT INTO Klienci (Imie, Nazwisko, Data_urodzenia, Kontakt, Czy_staly_klient)
 SELECT 'Adam', 'Adamowicz', NULL, '500-500-500', 0 FROM dual UNION ALL 
 SELECT 'Barbara', 'Barbarowska', TO_DATE('06-11-1990', 'DD-MM-YYYY'), 'bb@gmail.com', 1 FROM dual UNION ALL 
 SELECT 'Czarek', 'Czajkowski', TO_DATE('13-11-1986', 'DD-MM-YYYY'), 'Czajkowskiego 6, £ódŸ', 0 FROM dual UNION ALL 
 SELECT 'Daniel', 'Danielowski', TO_DATE('31-01-1991', 'DD-MM-YYYY'), '700-700-700', 1 FROM dual;

INSERT INTO Zamowienia (Data_zamowienia, ID_Klienta, Cena) 
 SELECT TO_DATE('8-12-2016', 'DD-MM-YYYY'), (SELECT ID FROM Klienci WHERE Nazwisko = 'Adamowicz'), 0 FROM dual UNION ALL 
 SELECT TO_DATE('9-12-2016', 'DD-MM-YYYY'), (SELECT ID FROM Klienci WHERE Nazwisko = 'Barbarowska'), 0 FROM dual UNION ALL 
 SELECT TO_DATE('29-11-2016', 'DD-MM-YYYY'), (SELECT ID FROM Klienci WHERE Nazwisko = 'Czajkowski'), 0 FROM dual UNION ALL 
 SELECT TO_DATE('10-12-2016', 'DD-MM-YYYY'), (SELECT ID FROM Klienci WHERE Nazwisko = 'Barbarowska'), 0 FROM dual;


INSERT INTO Zamowienia_Dania (ID_Zamowienia, ID_Dania, Liczba)
 SELECT 1, 1, 1 FROM dual UNION ALL 
 SELECT 1, 2, 2 FROM dual UNION ALL 
 SELECT 2, 3, 2 FROM dual UNION ALL 
 SELECT 3, 1, 1 FROM dual UNION ALL 
 SELECT 3, 2, 1 FROM dual UNION ALL 
 SELECT 3, 3, 1 FROM dual UNION ALL 
 SELECT 4, 1, 3 FROM dual UNION ALL 
 SELECT 4, 3, 3 FROM dual UNION ALL 
 SELECT 4, 4, 1 FROM dual;
