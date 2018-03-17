--procedura wykonywana w schedulerze
create or replace 
PROCEDURE zaopatrzenie(
  p_id_dostawcy dostawy.id_dostawcy%TYPE,
  p_id_skladnika dostawy.id_skladnika%TYPE,
  p_ilosc dostawy.ilosc%TYPE
) as
begin
  insert into dostawy (id_dostawcy, id_skladnika, data_dostawy, ilosc)
  values (p_id_dostawcy, p_id_skladnika, sysdate, p_ilosc);
end;
begin
  zaopatrzenie(3, 3, 5);
end;
insert into dostawy (id_dostawcy, id_skladnika, data_dostawy, ilosc)
  values (5, 2, sysdate, 10);
  

--tworzenie programu ktory ma sie wywolywac (wraz z definicja argumentow wykonywanej procedury)
BEGIN
  dbms_scheduler.create_program (
    program_name => 'dostawy_skladnikow_program',
    program_action => 'ZAOPATRZENIE',
    program_type => 'STORED_PROCEDURE',
    number_of_arguments => 3);
    
  dbms_scheduler.define_program_argument(
    program_name => 'dostawy_skladnikow_program',
    argument_position => 1,
    argument_type => 'number',
    default_value => '5');
    
  dbms_scheduler.define_program_argument(
    program_name => 'dostawy_skladnikow_program',
    argument_position => 2,
    argument_type => 'number',
    default_value => '3');
    
  dbms_scheduler.define_program_argument(
    program_name => 'dostawy_skladnikow_program',
    argument_position => 3,
    argument_type => 'BINARY_DOUBLE',
    default_value => '2');
  --aby program byl wykonywany nalezy go aktywowac
  dbms_scheduler.enable('dostawy_skladnikow_program');
END;

--tworzenie schedulera (harmonogram wykonywania zadania)
begin
  dbms_scheduler.create_schedule (
    schedule_name => 'dostawy_skladnikow_schedule',
    start_date  => systimestamp,
    repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',
    end_date  => systimestamp + interval '1' day,
    comments  => 'Nowa dostawa dotarla');
end;

--definicja obiektu job - wiaze ze soba akcje(program) z definicja kiedy(schedulerem)
begin
  dbms_scheduler.create_job (
    job_name  => 'dostawy_skladnikow_job',
    program_name  => 'dostawy_skladnikow_program',
    schedule_name => 'dostawy_skladnikow_schedule');
end;

--enable - pozwala na wykonywanie pracy schedulera, disable aby go dezaktywowac
exec dbms_scheduler.enable('dostawy_skladnikow_job');