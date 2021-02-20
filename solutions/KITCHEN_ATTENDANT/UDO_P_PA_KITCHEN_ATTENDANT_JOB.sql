create or replace procedure UDO_P_PA_KITCHEN_ATTENDANT_JOB is
    C_DAY    number := mod(TO_NUMBER(TO_CHAR(SYSDATE + 1, 'J')), 7);
    C_HOUR   number := EXTRACT(hour from CURRENT_TIMESTAMP) + EXTRACT(TIMEZONE_HOUR from CURRENT_TIMESTAMP);
begin
    if ( C_DAY = 5 and C_HOUR = 16 ) then
        UDO_P_PA_KITCHEN_ATTENDANT;
    elsif ( C_DAY != 5 and C_HOUR = 17 ) then
        UDO_P_PA_KITCHEN_ATTENDANT;
    end if;
end UDO_P_PA_KITCHEN_ATTENDANT_JOB;