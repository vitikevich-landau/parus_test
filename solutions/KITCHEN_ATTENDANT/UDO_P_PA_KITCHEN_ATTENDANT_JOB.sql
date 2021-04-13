create or replace procedure UDO_P_PA_KITCHEN_ATTENDANT_JOB is

    C_DAY    number := mod(TO_NUMBER(TO_CHAR(SYSDATE + 1, 'J')), 7);
    C_HOUR   number := EXTRACT(hour from CURRENT_TIMESTAMP) + EXTRACT(timezone_hour from CURRENT_TIMESTAMP);
begin
    if ( C_HOUR = 14 ) then
        UDO_P_PA_KITCHEN_ATTENDANT_I; -- только информирование
    end if;
    if ( C_DAY = 5 and C_HOUR = 16 ) then
        UDO_P_PA_KITCHEN_ATTENDANT; -- информирование и смена дежурного
    elsif ( C_DAY != 5 and C_HOUR = 17 ) then
        UDO_P_PA_KITCHEN_ATTENDANT;  -- информирование и смена дежурного
    end if;

end UDO_P_PA_KITCHEN_ATTENDANT_JOB;