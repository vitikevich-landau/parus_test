begin
  sys.dbms_scheduler.create_schedule(schedule_name   => 'PARUS.UDO_SCHED_PA_CHECK_CERTS',
                                     start_date      => to_date('01-11-2020 00:00:00', 'dd-mm-yyyy hh24:mi:ss'),
                                     repeat_interval => 'Freq=Daily;ByHour=08, 12, 13, 16, 19, 22;ByMinute=09, 17, 37', -- ОТРЕДАКТИРОВАТЬ !
                                     end_date        => to_date(null),
                                     comments        => '');
end;
/