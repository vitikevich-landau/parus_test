begin
  sys.dbms_scheduler.create_job(job_name            => 'PARUS.UDO_JOB_PA_CHECK_CERTS',
                                job_type            => 'STORED_PROCEDURE',
                                job_action          => 'UDO_P_PA_CHECK_CERTS',
                                schedule_name       => 'PARUS.UDO_J_PA_CHECK_CERTS',
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => false,
                                comments            => '');
end;
/