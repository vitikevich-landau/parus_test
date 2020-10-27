procedure UDO_P_PA_CHECK_CERTS is
    -- variables
    V$N_SERIAL_LENGTH constant number := 40;

    -- procedures
    /*
        Вставка данных из временной таблицы в постоянную
    */
    procedure P$COMPARE_AND_INSERT is
    begin
        insert into MY_CRL_CERT_INFO (
            SERIAL_NUMBER,
            REVOCATION_DATE,
            INSERT_DATE
        )
            select
                T.SERIAL_NUMBER,
                T.REVOCATION_DATE,
                T.INSERT_DATE
            from
                MY_CRL_CERT_INFO        M
                right join MY_CRL_CERT_INFO_TEMP   T
                on M.SERIAL_NUMBER = T.SERIAL_NUMBER
            where
                M.SERIAL_NUMBER is null;

        commit;
    end P$COMPARE_AND_INSERT;

    /*
        Очистка временной таблицы
    */
    procedure P$CLEAR_TEMP_TABLE is
    begin
        delete from MY_CRL_CERT_INFO_TEMP;

        commit;
    end P$CLEAR_TEMP_TABLE;

begin
    -- 1
    P$COMPARE_AND_INSERT();

    -- 2
    FOR I IN ( select
               UL.RN
           from
               DIGCERT            DC
               inner join MY_CRL_CERT_INFO   CRL
               on LPAD(DC.SERIAL, V$N_SERIAL_LENGTH, '0') = CRL.SERIAL_NUMBER
               inner join USERCERT           UC
               on UC.DIGCERT = DC.RN
               inner join USERLIST           UL
               on UL.AUTHID = UC.AUTHID )
    loop
        DBMS_OUTPUT.PUT_LINE(I.RN);
        /*
            Блокировка учётной записи
        */
        --P_USERLIST_LOCK(USER_RN, 1, 0, 0);
    end loop;

    -- 3
    P$CLEAR_TEMP_TABLE();

end UDO_P_PA_CHECK_CERTS;
