begin
  sys.dbms_scheduler.create_schedule(schedule_name   => 'PARUS.WORKING_DAY_EVENING',
                                     start_date      => to_date('19-02-2021 00:00:00', 'dd-mm-yyyy hh24:mi:ss'),
                                     repeat_interval => 'Freq=Daily;Interval=1;ByDay=Mon, Tue, Wed, Thu, Fri;ByHour=16, 17;ByMinute=40',
                                     end_date        => to_date(null),
                                     comments        => '');
end;
/
