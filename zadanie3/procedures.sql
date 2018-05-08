--Wprowadzenie danych odnośnie wlasciciela do tabeli Wlasciciele
create or replace procedure import_xml_to_wlasciciele(p_filename in varchar2) is
  xmlfile xmltype;
begin
  xmlfile := xmltype(bfilename('XMLFILES',p_filename),nls_charset_id('AL32UTF8'));
  insert into Wlasciciele (id, wlasciciel_spec) values (wlasciciele_seq.nextval, xmlfile);
  commit;
end;

execute import_xml_to_wlasciciele(p_filename => 'wlasciciel1.xml');

--Wprowadzanie danych odnośnie dania do tabeli Dania
create or replace procedure import_xml_dania(p_filename in varchar2) is
  xmlfile xmltype;
  danie_spec xmltype;
begin
  xmlfile := xmltype(bfilename('XMLFILES',p_filename),nls_charset_id('AL32UTF8'));
  danie_spec := xmlfile.extract('/danie');
  insert into Dania (id, spec) values (dania_seq.nextval, danie_spec);
end;

execute import_xml_dania(p_filename => 'danie1.xml');

--import danych odnośnie wielu dań z pliku xml do kilku wierszy
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


--pozyskiwanie informacji o danym wlasicielu na podstawie jego id
create or replace procedure show_wlasciciel_info(wlasciciel_id in number) is
  x clob;
begin
  select w.wlasciciel_spec.getCLOBVal() into x from wlasciciele w where w.id = wlasciciel_id;
  dbms_output.put_line(x);
end;

execute show_wlasciciel_info(1);