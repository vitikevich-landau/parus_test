begin
  sys.dbms_scheduler.create_job(job_name            => 'PARUS.UDO_J_PA_KITCHEN_ATTENDANT',
                                job_type            => 'STORED_PROCEDURE',
                                job_action          => 'UDO_P_PA_KITCHEN_ATTENDANT_JOB',
                                schedule_name       => 'PARUS.WORKING_DAY_EVENING',
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => false,
                                comments            => '');
end;
/
