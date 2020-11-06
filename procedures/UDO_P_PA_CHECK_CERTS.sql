create or replace procedure UDO_P_PA_CHECK_CERTS is
   -- variables

    C$N_SERIAL_LENGTH   constant number := 40;
    C$S_PAD_STRING      constant varchar2(1) := '0';

    -- procedures
    /*
        Вставка данных из временной таблицы в постоянную
    */

    procedure P$COMPARE_AND_INSERT is
    begin
        insert into UDO_T_PA_CRLCERT_REVOKED (
            SERIAL_NUMBER,
            REVOCATION_DATE,
            INSERT_DATE
        )
            select
                T.SERIAL_NUMBER,
                T.REVOCATION_DATE,
                T.INSERT_DATE
            from
                UDO_T_PA_CRLCERT_REVOKED        M
                right join UDO_T_PA_CRLCERT_REVOKED_TEMP   T
                on M.SERIAL_NUMBER = T.SERIAL_NUMBER
            where
                M.SERIAL_NUMBER is null
                /*
                    Отбросить сертификаты ранее выпущенные ранее digcert
                */
                and TO_DATE(SUBSTR(T.REVOCATION_DATE, 0, INSTR(T.REVOCATION_DATE, ' ') - 1), 'dd.mm.yyyy') > (
                    select
                        min(FROM_DATE)
                    from
                        DIGCERT
                );

        commit;
    end P$COMPARE_AND_INSERT;

    /*
        Очистка временной таблицы
    */

    procedure P$CLEAR_TEMP_TABLE is
    begin
        delete from UDO_T_PA_CRLCERT_REVOKED_TEMP;

        commit;
    end P$CLEAR_TEMP_TABLE;

    /*
        Удаление дубликатов из временной тадлицы
    */

    procedure P$REMOVE_DUPLICATES is
    begin
        delete from UDO_T_PA_CRLCERT_REVOKED_TEMP
        where
            rowid not in (
                select
                    max(rowid)
                from
                    UDO_T_PA_CRLCERT_REVOKED_TEMP
                group by
                    SERIAL_NUMBER
            );

        commit;
    end P$REMOVE_DUPLICATES;

    /*
        Блокировка учётной записи
    */

    procedure P$USER_LOCK (
        USER_RN number
    ) is
    begin
        update USERLIST
        set
            ACC_LOCK = 1,
            ACC_LOCK_DATE = SYSDATE,
            ACC_UNLOCK_DATE = null,
            ACC_LOCK_WIN = 1,
            ACC_LOCK_DATE_WIN = SYSDATE,
            ACC_LOCK_WEB = 1,
            ACC_LOCK_DATE_WEB = SYSDATE
        where
            RN = USER_RN;

        commit;
    end P$USER_LOCK;

    /*
        Отправка уведомления о блокировке
    */

    procedure P$SEND_MESSAGE (
        STO        in   varchar2,     -- ADDR_USER_CODE
        SMESSAGE   in   varchar2
    ) is

        C$$N_WARN_MSG_CATALOG    number := 18149079;
        V$$N_MESSAGE_TYPE_CODE   number;
        V$$N_SCHEDULER_CODE      number;
        V$$N_PROVIDER_CODE       number;
        V$$N_RRN                 number := GEN_ID;
        V$$N_ADDR_COMPANY_RN     number;
        V$$S_TITLE               varchar2(240);
    begin
        P_WARNMSGQUEUE_JOINS('Уведомление HTTP', 'День', 'ORACLE_HTTP', V$$N_MESSAGE_TYPE_CODE, V$$N_SCHEDULER_CODE,
                             V$$N_PROVIDER_CODE);
        select
            RN
        into V$$N_ADDR_COMPANY_RN
        from
            COMPANIES
        where
            NAME = 'КУРА_МинФин';

        /*
            Максимальная длина строки WARNMSGQUEUE.TITLE%type 240
        */

        if ( LENGTH(SMESSAGE) > 240 ) then
            V$$S_TITLE := RPAD(SUBSTR(SMESSAGE, 0, 237), 240, '.');
        else
            V$$S_TITLE := SMESSAGE;
        end if;

        insert into WARNMSGQUEUE (
            RN,
            CRN,
            AUTHOR,
            TITLE,
            MESSAGE,
            MESSAGE_DATE,
            MESSAGE_TYPE,
            SCHEDULER,
            PROVIDER,
            DELETE_AFTER_SEND
        ) values (
            V$$N_RRN,
            C$$N_WARN_MSG_CATALOG,
            'PARUS',
            V$$S_TITLE,
            SMESSAGE,
            SYSDATE,
            V$$N_MESSAGE_TYPE_CODE,
            V$$N_SCHEDULER_CODE,
            V$$N_PROVIDER_CODE,
            1
        );

        insert into WARNMSGQADDR (
            RN,
            PRN,
            CRN,
            ADDR_TYPE,
            ADDR_COMPANY,
            ADDR_ROLE,
            ADDR_USER,
            ADDR_CODE,
            NEXT_LAUNCH,
            LAST_LAUNCH,
            LAUNCH_COUNT,
            TRY_COUNT,
            ERROR_IDENT
        ) values (
            GEN_ID,
            V$$N_RRN,
            C$$N_WARN_MSG_CATALOG,
            1,
            V$$N_ADDR_COMPANY_RN,
            null,
            null,
            STO /* кому */,
            to_date('01-04-2019', 'dd-mm-yyyy'),
            null,
            1,
            3,
            null
        );

    end P$SEND_MESSAGE;

    /*
        Шаблон отправки уведомлений
    */

    function F$MESSAGE_TEMPLATE (
        SUSERCERT_AUTHID   in   varchar2,
        SAGNLIST_AGNNAME   in   varchar2,
        SDIGCERT_SERIAL    in   varchar2,
        SDIGCERT_TO_NAME   in   varchar2
    ) return varchar2 is
    begin
        return 'Сертификат пользователя '
               || SUSERCERT_AUTHID
               || ' находится в списке отозванных '
               || CR
               || 'Сотрудник: '
               || NVL(SAGNLIST_AGNNAME, '"Отсутствует"')
               || ' '
               || CR
               || 'Серийный номер сертификата: '
               || SDIGCERT_SERIAL
               || ' '
               || CR
               || 'Имя сертификата: "'
               || SDIGCERT_TO_NAME
               || '" '
               || CR
               || 'После замены сертификата обратитесь к специалисту по сопровождению модуля "УДП"';
    end F$MESSAGE_TEMPLATE;

begin
    -- 1
    P$REMOVE_DUPLICATES();

    -- 2
    P$COMPARE_AND_INSERT();

--    p_exception(0, 'here');

    -- 3
    /*
       Поиск сертификатов в списках отозванных
    */
    for I in (
        select
            UL.RN,
            UC.AUTHID,
            AGL.AGNNAME,
            DC.SERIAL,
            DC.TO_NAME
        from
            DIGCERT                    DC
            inner join UDO_T_PA_CRLCERT_REVOKED   CRL
            on LPAD(DC.SERIAL, C$N_SERIAL_LENGTH, C$S_PAD_STRING) = CRL.SERIAL_NUMBER
            inner join USERCERT                   UC
            on UC.DIGCERT = DC.RN
            inner join USERLIST                   UL
            on UL.AUTHID = UC.AUTHID
            /*
               Присоединение к найденным озерам ФИО.
               Для формирования сообщений
            */
            left join CLNPERSONS                 PS
            on PS.PERS_AUTHID = UC.AUTHID
            left join AGNLIST                    AGL
            on PS.PERS_AGENT = AGL.RN
    ) loop
        --DBMS_OUTPUT.PUT_LINE(I.RN);
        --DBMS_OUTPUT.PUT_LINE(F$MESSAGE_TEMPLATE(I.AUTHID, I.AGNNAME, I.SERIAL, I.TO_NAME));
        P$SEND_MESSAGE(I.AUTHID, F$MESSAGE_TEMPLATE(I.AUTHID, I.AGNNAME, I.SERIAL, I.TO_NAME));

        P$USER_LOCK(I.RN);
    end loop;

    -- 4

    P$CLEAR_TEMP_TABLE();
end UDO_P_PA_CHECK_CERTS;