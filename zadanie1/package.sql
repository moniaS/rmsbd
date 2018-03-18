create or replace
package menagerDostawcow
is 
  ile_dostawcow number;
  procedure wypisz_wszystkich;
  function PodajUdzialProcentowyDostawcow(id_d number) return binary_double;
  procedure dodajDostawce(
    p_nazwa dostawcy.nazwa%TYPE,
    p_miasto dostawcy.miasto%TYPE,
    p_adres dostawcy.adres%TYPE
  );
  function ilosc_dostawcow return number;
end;
  
create or replace package body menagerDostawcow
is
  procedure wypisz_wszystkich is
  dostawca dostawcy%rowtype;
  cursor cursorDostawcy is
    select * from dostawcy;
  begin
    dbms_output.put_line('W bazie znajduje sie ' ||  ile_dostawcow || ' dostawcow');
    open cursorDostawcy;
      fetch cursorDostawcy into dostawca;
      while cursorDostawcy%FOUND loop
        dbms_output.put_line(dostawca.nazwa || ', ' ||dostawca.miasto);
        fetch cursorDostawcy into dostawca;
      end loop;
    close cursorDostawcy;
    
  end;

  FUNCTION PodajUdzialProcentowyDostawcow
  (
    id_d NUMBER
  ) RETURN BINARY_DOUBLE AS
    udzial_procentowy BINARY_DOUBLE;
  BEGIN
    SELECT ROUND(COUNT(ID_dostawcy) / (SELECT COUNT(ID_dostawcy) FROM Dostawy), 4) INTO udzial_procentowy
    FROM Dostawy
    WHERE ID_dostawcy = id_d
    GROUP BY ID_dostawcy;
    RETURN udzial_procentowy * 100;
  END;
  
  PROCEDURE dodajDostawce(
    p_nazwa dostawcy.nazwa%TYPE,
    p_miasto dostawcy.miasto%TYPE,
    p_adres dostawcy.adres%TYPE
  ) AS
  BEGIN 
    INSERT INTO dostawcy(nazwa, miasto, adres)
    VALUES (p_nazwa, p_miasto, p_adres);
  END;
  
  function ilosc_dostawcow return number as
    ile number;
  begin
    select count(*) into ile from dostawcy;
  return ile;
  end;
  
begin
  select ilosc_dostawcow into ile_dostawcow from dual;

end;


--wywolywanie funkcji i procedur pakietowych
select menagerDostawcow.ilosc_dostawcow from dual;
select menagerDostawcow.podajUdzialProcentowyDostawcow(5) from dual;
--ta procedura wyswietla wartosc zmiennej pakietowej ile_dostawcow
begin 
  menagerDostawcow.wypisz_wszystkich; 
end;
begin
   menagerdostawcow.dodajdostawce('Swieze dostawy', 'Wroclaw', 'Bednarska 120');
end;
exec dbms_output.put_line('W bazie jest ' || menagerDostawcow.ile_dostawcow || ' dostawcow');