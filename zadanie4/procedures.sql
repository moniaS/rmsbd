set serveroutput on;

create or replace procedure DodajRestauracje
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

execute DodajRestauracje('Hot Spoon', 'Drewnowska', '58', 'Lodz', 19.447467, 51.780623);

--zmiana lokalizacji restauracji
create or replace procedure zmiana_lokalizacji_rest(id_restauracji in number, x in number, y in number) AS
begin
	update restauracje set lokalizacja = SDO_GEOMETRY(2001, 8307, MDSYS.SDO_POINT_TYPE(x, y, NULL), NULL, NULL) where id = id_restauracji;
end;

execute zmiana_lokalizacji_rest(1, 19.446932, 51.767967);

--wyswietl dane o wszystkich restauracjach
create or replace procedure info_wszystkie_restauracje AS
	cursor cursorRestauracje is select * from restauracje;
	temp_rest restauracje%rowtype;
begin
	open cursorRestauracje;
	fetch cursorRestauracje into temp_rest;
	while (cursorRestauracje%FOUND) loop
  		dbms_output.put_line('Nazwa: ' || temp_rest.nazwa);
  		dbms_output.put_line('Adres: ' || temp_rest.miasto || ', ul. ' || temp_rest.nazwa_ulicy || ' ' || temp_rest.numer_ulicy);
      	dbms_output.put_line('Wspolrzedne: ' || temp_rest.lokalizacja.sdo_point.x || ' E, ' || temp_rest.lokalizacja.sdo_point.y || ' N');
      	dbms_output.put_line('');
		fetch cursorRestauracje into temp_rest;
	end loop;
end;

execute info_wszystkie_restauracje;


--wyswietl nazwy restauracji ktore sa w odleglosci x km od klienta
create or replace procedure restauracje_w_zasiegu_klienta(id_klienta in number, zasieg_km number) as
  nazwy varchar2(1000);
begin
select listagg(r.nazwa, ', ' ) within group (order by r.nazwa) into nazwy from restauracje r where
   sdo_within_distance(r.lokalizacja,
                       (select przyblizona_lokalizacja from klienci where id = id_klienta),
                       'distance='|| zasieg_km ||' unit=km'
   ) = 'TRUE';
   
   dbms_output.put_line('Restauracje w zasiegu ' || zasieg_km || 'km: ' || nazwy);
end;

execute restauracje_w_zasiegu_klienta(1, 1);

--wyswietl odleglosc restauracji od miejsca zamieszkania 
create or replace procedure wyswietl_odl_rest_klient(id_klienta in number, id_restauracji in number) as
  odleglosc number;
  lok_rest restauracje.lokalizacja%type;
  lok_klient klienci.przyblizona_lokalizacja%type;
  nazwa_restauracji restauracje.nazwa%type;
begin
  select lokalizacja, nazwa into lok_rest, nazwa_restauracji from restauracje where id = id_restauracji;
  select przyblizona_lokalizacja into lok_klient from klienci where id = id_klienta;
  select sdo_geom.sdo_distance(lok_rest, lok_klient, 0.005, 'unit=km') into odleglosc from dual;
  dbms_output.put_line('Odleglosc do ' || nazwa_restauracji || ': ' || round(odleglosc, 3) || ' km');
end;

execute wyswietl_odl_rest_klient(1, 2);