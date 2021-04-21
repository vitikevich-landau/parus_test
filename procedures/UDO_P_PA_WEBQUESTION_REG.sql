create or replace procedure UDO_P_PA_WEBQUESTION_REG
-- Создание события из обращения через WEB форму
-- 21.04.2021 добавлена плановая дата начала работ
 (
    SPHONE_IN        in   varchar2,
    SCOMPANY_TITLE   in   varchar2,
    SCLIENT_NAME     in   varchar2,
    SMESSAGE_TEXT    in   varchar2,
    SMODULE          in   varchar2 default null,
    SCURATOR         in   varchar2 default null
) is

    C_PARUS_COMPANY_RN   constant number := 18803;
    C_EVENT_CATALOG_RN   constant number := 1660616;         -- 14 Web Client RN
    L_QUESTION_RN        number;
    L_NEVENT_RN          number;
    L_IS_PERSON          number;                                 -- Сотрдник или организация 1/0
    L_SCLIENT_CLIENT     varchar2(160);
    L_SCLIENT_PERSON     varchar2(160);
    L_CURATOR            varchar2(160); -- код куратора для отправки как сотруднику
    L_DPLAN_DATE         date; -- плановая дата начала работ
    -- procedures

    /* Процедура привязки события к обращению */

    procedure P$WEBQUESTION_CLNEVENT_BIND (
        NQUESTION_RN   in   number,
        NCLNEVENT_RN   in   number
    ) is
    begin
        update UDO_T_PA_CLNEVNTS_WEBQUESTIONS
        set
            PRN = NCLNEVENT_RN
        where
            RN = NQUESTION_RN;

        commit;
    end P$WEBQUESTION_CLNEVENT_BIND;

    -- Формирование шаблона описания события

    function F$EVENT_DESCRIPTION_TEMPLATE (
        SPHONE_IN        in   varchar2,
        SCOMPANY_TITLE   in   varchar2,
        SCLIENT_NAME     in   varchar2,
        SMESSAGE_TEXT    in   varchar2,
        SINFORMATION     in   varchar2 default null         -- Какая либо доп. информация
    ) return varchar2 is
        L_EVENT_DESC varchar2(2000);
    begin
        L_EVENT_DESC   := 'Телефон: '
                        || SPHONE_IN
                        || CR;
        if SCOMPANY_TITLE is not null or LENGTH(SCOMPANY_TITLE) > 0 then
            L_EVENT_DESC := L_EVENT_DESC
                            || 'Организация: '
                            || SCOMPANY_TITLE
                            || CR;
        end if;

        L_EVENT_DESC   := L_EVENT_DESC
                        || 'Имя: '
                        || SCLIENT_NAME
                        || CR;
        -- Выбранный модуль
        if SMODULE is not null then
            L_EVENT_DESC := L_EVENT_DESC
                            || 'Модуль: '
                            || SMODULE
                            || CR;
        end if;

        -- Выбранный куратор

        if SCURATOR is not null then
            L_EVENT_DESC := L_EVENT_DESC
                            || 'Куратор: '
                            || SCURATOR
                            || CR;
        end if;

        L_EVENT_DESC   := L_EVENT_DESC
                        || CR
                        || 'Текст обращения: '
                        || CR
                        || SMESSAGE_TEXT
                        || CR;

        if SINFORMATION is not null or LENGTH(SINFORMATION) > 0 then
            L_EVENT_DESC := L_EVENT_DESC
                            || CR
                            || SINFORMATION
                            || CR;
        end if;

        return L_EVENT_DESC;
    end F$EVENT_DESCRIPTION_TEMPLATE;

begin
    -- generate question rn
    L_QUESTION_RN   := GEN_ID();


    -- Определяем сотрудник или организация
    begin
        select
            IS_PERSON
        into L_IS_PERSON
        from
            UDO_V_PA_WEBQUEST_CLIENTVERIFY
        where
            PHONE = SPHONE_IN
            and IS_PERSON = 1
            and rownum = 1;

    exception
        when NO_DATA_FOUND then
            L_IS_PERSON := null;
    end;

    -- Сохраняем обращение из формы в таблицу

    UDO_P_PA_WEBQUESTION_ADD(L_QUESTION_RN, SPHONE_IN, SCOMPANY_TITLE, SCLIENT_NAME, SMESSAGE_TEXT,
                             L_IS_PERSON, SMODULE, SCURATOR);

    /*
        Если определён сотрудник/организация то,
        находим и передаём мнемокод организация-инициатора/мнемокод сотрудника-инициатора
    */

--    p_exception(0, 'L_IS_PERSON: ' || to_char(L_IS_PERSON) || ', ' || 'SPHONE_IN: ' || SPHONE_IN);

    if ( L_IS_PERSON = 1 ) then
        begin
            select distinct
                SCODE
            into L_SCLIENT_PERSON
            from
                (
                    select
                        CP.SCODE
                    from
                        UDO_V_PA_WEBQUEST_CLIENTVERIFY   WQ
                        inner join V_CLNPERSONS                     CP
                        on WQ.RN = CP.NRN
                        left join V_CLIENTCLIENTS                  CC
                        on CP.NOWNER_AGENT = CC.NCLIENT_AGENT
                    where
                        WQ.PHONE = SPHONE_IN
                        and CC.SCLIENT_AGENT_NAME = SCOMPANY_TITLE
                    order by
                        CP.NCRN desc
                )
            where
                rownum = 1;

        exception
            when others then
                L_SCLIENT_PERSON := null;
        end;
        -- если не найден по связке организация + телефон, ищем только по телефону

        if L_SCLIENT_PERSON is null then
            begin
                select distinct
                    SCODE
                into L_SCLIENT_PERSON
                from
                    (
                        select
                            CP.SCODE
                        from
                            UDO_V_PA_WEBQUEST_CLIENTVERIFY   WQ
                            inner join V_CLNPERSONS                     CP
                            on WQ.RN = CP.NRN
                        where
                            WQ.PHONE = SPHONE_IN
                        order by
                            CP.NCRN desc
                    )
                where
                    rownum = 1;

            exception
                when others then
                    L_SCLIENT_PERSON := null;
            end;

        end if;

    else
        if ( L_IS_PERSON = 0 ) then
            begin
                select distinct
                    CP.SCLIENT_CODE
                into L_SCLIENT_CLIENT
                from
                    UDO_V_PA_WEBQUEST_CLIENTVERIFY   WQ
                    inner join V_CLIENTCLIENTS                  CP
                    on WQ.TITLE = CP.SCLIENT_AGENT_NAME
                where
                    WQ.PHONE = SPHONE_IN;

            exception
                when others then
                    L_SCLIENT_CLIENT := null;
            end;

        end if;
    end if;

--    p_exception(0, 'L_SCLIENT_PERSON: ' || L_SCLIENT_PERSON || ', ' || 'L_SCLIENT_CLIENT: ' || L_SCLIENT_CLIENT || ', SPHONE_IN: ' || SPHONE_IN);

    L_DPLAN_DATE    := SYSDATE;
-- расчет плановой даты начала работ
-- если ранее 18:00 то текущая дата иначе дата+1, время всегда 18:00
    select
        case
            when extract(hour from LOCALTIMESTAMP) < 18 then
                TO_DATE(TO_CHAR(LOCALTIMESTAMP, 'DD.MM.YYYY'), 'DD.MM.YYYY') + 18 / 24
            else
                TO_DATE(TO_CHAR(LOCALTIMESTAMP + 1, 'DD.MM.YYYY'), 'DD.MM.YYYY') + 18 / 24
        end as DT
    into L_DPLAN_DATE
    from
        DUAL;

-- todo Определить куратора

    L_CURATOR       := null;

    /*
        Создаём событие средствами системы

        Пока не определяется клиент отправитель или получатель
        то регитсрируем default событие
    */
    UDO_P_PA_CLNEVENTS_INSERT(C_PARUS_COMPANY_RN,                               -- NCOMPANY           -- организация Парус
     C_EVENT_CATALOG_RN,                               -- NCRN               -- каталог события
     null,                                             -- SEVENT_PREF        -- префикс события, Генерится автоматичеки
     null,                                             -- SEVENT_NUMB        -- номер события, Генерится автоматичеки
     'СобытиеWeb',                                     -- SEVENT_TYPE        -- мнемокод типа события
                              'НовоеСобытие',                                   -- SEVENT_STAT        -- мнемокод статуса события
                               L_DPLAN_DATE,                                     -- DPLAN_DATE         -- плановая дата начала работ по событию
                               'PARUS#адм#1#Парус_Алтай',                        -- SINIT_PERSON       -- мнемокод инициатора
                               L_SCLIENT_CLIENT,                                 -- SCLIENT_CLIENT     -- мнемокод клиента-инициатора
                               L_SCLIENT_PERSON,                                 -- SCLIENT_PERSON     -- мнемокод сотрудника-инициатора
                              null,                                             -- SSEND_CLIENT       -- мнемокод клиента-исполнителя
                               null,                                             -- SSEND_DIVISION     -- мнемокод подразделения-исполнителя
                               null,                                             -- SSEND_POST         -- мнемокод должности-исполнителя
                               null,                                             -- SSEND_PERFORM      -- мнемокод штатной должности-исполнителя
                               L_CURATOR,                                        -- SSEND_PERSON       -- мнемокод сотрудника-исполнителя
                              null,                                             -- SSEND_STAFFGRP     -- мнемокод нештатной структуры
                               null,                                             -- SSEND_USER_GROUP   -- мнемокод группы пользователей
                               null,                                             -- SSEND_USER_NAME    -- наименование пользователя
                               F$EVENT_DESCRIPTION_TEMPLATE(SPHONE_IN, SCOMPANY_TITLE, SCLIENT_NAME, SMESSAGE_TEXT),                                                -- SEVENT_DESCR       -- описание события
                               null,                                             -- SREASON            -- причина события
                               L_NEVENT_RN                                       -- NRN                -- регистрационный номер события
                              );

    /*
        Обнуляем поле клиента заполняемое по умолчанию, при default генерации
    */

    if ( L_SCLIENT_CLIENT is null ) and ( L_SCLIENT_PERSON is null ) then
        update CLNEVENTS
        set
            CLIENT_PERSON = null
        where
            RN = L_NEVENT_RN;

    end if;

    -- Привязка события к обращению

    P$WEBQUESTION_CLNEVENT_BIND(L_QUESTION_RN, L_NEVENT_RN);
end UDO_P_PA_WEBQUESTION_REG;