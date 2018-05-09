---------------IMPORT DANYCH-----------------

--Wprowadzenie danych do tabeli wlasciciele - caly plik
create or replace procedure import_xml_to_wlasciciele(p_filename in varchar2) is
  xmlfile xmltype;
begin
  xmlfile := xmltype(bfilename('XMLFILES',p_filename),nls_charset_id('AL32UTF8'));
  insert into Wlasciciele (id, wlasciciel_spec) values (wlasciciele_seq.nextval, xmlfile);
  commit;
end;

execute import_xml_to_wlasciciele(p_filename => 'wlasciciel1.xml');

--wprowadzenie danych do tabeli restauracje - wszystkie elementy
create or replace procedure insert_restauracje(p_filename in varchar2) is
  xmlfile xmltype;  
  seq XMLSequenceType;
begin
  xmlfile := xmltype(bfilename('XMLFILES', p_filename),nls_charset_id('AL32UTF8'));
  select XMLSEQUENCE(xmlfile.extract('restauracje/restauracja')) into seq from dual;
  for i in 1..seq.count loop
    insert into Restauracje (restauracja_spec) values (seq(i));
  end loop;
end;

execute insert_restauracje(p_filename => 'restauracje.xml');

--Wprowadzanie danych do tabeli dania - pojedyczy element
create or replace procedure import_xml_dania(p_filename in varchar2) is
  xmlfile xmltype;
  danie_spec xmltype;
begin
  xmlfile := xmltype(bfilename('XMLFILES',p_filename),nls_charset_id('AL32UTF8'));
  danie_spec := xmlfile.extract('/danie');
  insert into Dania (id, spec) values (dania_seq.nextval, danie_spec);
end;

execute import_xml_dania(p_filename => 'danie1.xml');

--import danych do tabeli dania - wiele elementow
create or replace procedure import_xml_rozne_dania(p_filename in varchar2) is
  xmlfile xmltype;
  seq XMLSequenceType;
BEGIN
  xmlfile := xmltype(bfilename('XMLFILES',p_filename),nls_charset_id('AL32UTF8'));
  select XMLSEQUENCE(xmlfile.extract('dania/danie')) into seq from dual;
   
   for i in 1..seq.count loop
      insert into Dania (id, spec) values (dania_seq.nextval, seq(i));
   end loop;
END;

execute import_xml_rozne_dania(p_filename => 'dania.xml');


--import danych do tabeli dania - dopisanie danych do istniejacego rekordu
create or replace procedure import_dania_istniejacy_rekord(p_filename in varchar2) is
  danie_spec xmltype;
  danie_id number;
  xmlfile xmltype;
begin
  xmlfile := xmltype(bfilename('XMLFILES',p_filename),nls_charset_id('AL32UTF8'));
  select extractvalue(xmlfile, 'danie/@id') into danie_id from dual;
  update dania set spec = xmlfile.extract('/danie') where id = danie_id;
end;

insert into dania (id) values (dania_seq.NEXTVAL);
execute import_dania_istniejacy_rekord('danie_id.xml');



------------------POZYSKIWANIE INFORMACJI---------------------------

--pozyskiwanie informacji o danym wlasicielu na podstawie jego id
create or replace procedure show_wlasciciel_info(wlasciciel_id in number) is
  x clob;
begin
  select w.wlasciciel_spec.getCLOBVal() into x from wlasciciele w where w.id = wlasciciel_id;
  dbms_output.put_line(x);
end;

execute show_wlasciciel_info(1);


--procedura ktora wyswietla informacje o danym wezle w ktorym wartosc elementu nazwa
-- jest zgodna z parametrem przekazanym do procedury
create or replace procedure show_dania_information(nazwa in varchar2) is
  tmp_spec xmltype;
  tmp_output clob;
  danie_id Dania.id%TYPE;
begin
  dbms_lob.createtemporary(tmp_output, true);
  select d.id, d.spec into danie_id, tmp_spec from Dania d where extractvalue(d.spec, '/danie/nazwa') = nazwa;
  dbms_lob.append(tmp_output, tmp_spec.getCLOBVal());
  dbms_output.put_line(tmp_output);
  dbms_lob.freetemporary(tmp_output);
end;

execute show_dania_information('Schabowy z mizeria');


--Pobieranie informacji o daniach ktore maja mniej niz podana liczba kalorii
create or replace procedure dania_kalorie (kalorie in number) is
  tmp_danie xmltype;
  tmp_output clob;
  cursor cursorDania is select d.spec from dania d where extractvalue(d.spec, '/danie/kalorie') < kalorie;
BEGIN
  dbms_lob.createtemporary(tmp_output, true);
  dbms_lob.append(tmp_output, '<dania>');
  
  OPEN cursorDania;
  FETCH cursorDania INTO tmp_danie;
  while(cursorDania%FOUND) loop
      dbms_lob.append(tmp_output, tmp_danie.getCLOBVal());
      FETCH cursorDania INTO tmp_danie;
  end loop;
  close cursorDania;
  
  dbms_lob.append(tmp_output, '</dania>');
  dbms_output.put_line(tmp_output);
  dbms_lob.freetemporary(tmp_output);
END;

execute dania_kalorie (500);


--wyswietlanie skladnikow z jakich sklada sie dana potrawa
create or replace procedure pobierz_skladniki(nazwa in varchar2) is
  danie_spec dania.spec%TYPE;
  seq XMLSequenceType;
begin
  select d.spec into danie_spec from dania d where extractvalue(d.spec, 'danie/nazwa') = nazwa;
  dbms_output.put_line('Skladniki potrawy '|| nazwa || ':');
  select XMLSEQUENCE(danie_spec.extract('danie/skladniki/skladnik')) into seq from dual;
  for i in 1..seq.count loop
    dbms_output.put_line(seq(i).extract('/skladnik/text()').getCLOBVal());
  end loop;
end;

execute pobierz_skladniki('Schabowy z mizeria');


----------------------------ESKPORTOWAIE DANYCH-----------------------------

--eksport wszystkich rekordów z tabeli restauracje do pliku xml
create or replace procedure export_restauracje_info is
  tmp_info clob;
  restauracje_id restauracje.id%TYPE;
  restauracje_spec restauracje.restauracja_spec%TYPE;
  cursor cursorRestauracje is 
    select id, restauracja_spec from restauracje;
begin
  dbms_lob.createtemporary(tmp_info, true);
  dbms_lob.append(tmp_info, '<?xml version="1.0" encoding="UTF-8"?>');
  dbms_lob.append(tmp_info, '<restauracje>');
  open cursorRestauracje;
  fetch cursorRestauracje into restauracje_id, restauracje_spec;
  while (cursorRestauracje%FOUND) loop
    dbms_lob.append(tmp_info, restauracje_spec.getCLOBVal());
    fetch cursorRestauracje into restauracje_id, restauracje_spec;
  end loop;
  dbms_lob.append(tmp_info, '</restauracje>');
  dbms_output.put_line(tmp_info);
  dbms_xslprocessor.clob2file(tmp_info, 'XMLFILES', 'restauracje'||'_exported', nls_charset_id('AL32UTF8'));
  dbms_lob.freetemporary(tmp_info);
end;

execute export_restauracje_info;


--eksport dania o danym id do pliku xml (sprawdzanie atrybutu elementu)
create or replace procedure export_danie_id(id_dania in varchar2) is
  tmp_info clob;
  tmp_danie xmltype;
begin
  dbms_lob.createtemporary(tmp_info, true);
  dbms_lob.append(tmp_info, '<?xml version="1.0" encoding="UTF-8"?>');
  select d.spec into tmp_danie from dania d where extractvalue(d.spec, '/danie/@id') = id_dania;
  dbms_lob.append(tmp_info, tmp_danie.getCLOBVal());
  dbms_xslprocessor.clob2file(tmp_info, 'XMLFILES', 'danie'||id_dania||'_exported', nls_charset_id('AL32UTF8'));
  dbms_lob.freetemporary(tmp_info);
end;  

execute export_danie_id('1');


--eksport dan zawierajacych gluten
create or replace procedure export_dania_gluten(czy_gluten in varchar2) is
  tmp_info clob;
  tmp_danie xmltype;
  cursor cursorDania is select d.spec from dania d where extractvalue(d.spec, '/danie/gluten') = czy_gluten;
begin
  dbms_lob.createtemporary(tmp_info, true);
  dbms_lob.append(tmp_info, '<?xml version="1.0" encoding="UTF-8"?>');
  dbms_lob.append(tmp_info, '<daniadasf>');
  
  open cursorDania;
  fetch cursorDania into tmp_danie;
  while(cursorDania%FOUND) loop
    dbms_lob.append(tmp_info, tmp_danie.getCLOBVal());
    fetch cursorDania into tmp_danie;
  end loop;
  dbms_lob.append(tmp_info, '</dania>');
  dbms_xslprocessor.clob2file(tmp_info, 'XMLFILES', 'gluten_'||czy_gluten||'_exported', nls_charset_id('AL32UTF8'));
  dbms_lob.freetemporary(tmp_info);
end;

execute export_dania_gluten('tak');


