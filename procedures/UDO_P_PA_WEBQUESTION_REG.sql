create or replace procedure UDO_P_PA_WEBQUESTION_REG(
    SPHONE_IN           in   varchar2,
    SCOMPANY_TITLE   in   varchar2,
    SCLIENT_NAME     in   varchar2,
    SMESSAGE_TEXT    in   varchar2
) is
    C_PARUS_COMPANY_RN   constant number := 18803;
    C_EVENT_CATALOG_RN   constant number := 1660616;         -- 14 Web Client RN

    L_QUESTION_RN   number;
    L_NEVENT_RN     number;
    L_IS_PERSON     number;                                 -- Сотрдник или организация 1/0
    L_SCLIENT_CLIENT    varchar2(160);
    L_SCLIENT_PERSON    varchar2(160);

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
        SPHONE_IN           in   varchar2,
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
                            || CR
                            || 'Организация: '
                            || REPLACE(SCOMPANY_TITLE, '|', CR || 'Организация: ')
                            || CR
                            || CR;
        end if;

        L_EVENT_DESC   := L_EVENT_DESC
                        || 'Имя: '
                        || SCLIENT_NAME
                        || CR;
        L_EVENT_DESC   := L_EVENT_DESC
                        || 'Текст обращения: '
                        || SMESSAGE_TEXT
                        || CR;
        if SINFORMATION is not null or LENGTH(SINFORMATION) > 0 then
            L_EVENT_DESC := L_EVENT_DESC
                            || SINFORMATION
                            || CR;
        end if;

        return L_EVENT_DESC;
    end F$EVENT_DESCRIPTION_TEMPLATE;

begin
    -- generate question rn
    L_QUESTION_RN := GEN_ID();


    -- Определяем сотрудник или организация
    begin
        select IS_PERSON into L_IS_PERSON from UDO_V_PA_WEBQUEST_CLIENTVERIFY where PHONE = SPHONE_IN and rownum = 1;
    exception
        when NO_DATA_FOUND then
            L_IS_PERSON := null;
    end;

    -- Сохраняем обращение из формы в таблицу
    UDO_P_PA_WEBQUESTION_ADD(L_QUESTION_RN, SPHONE_IN, SCOMPANY_TITLE, SCLIENT_NAME, SMESSAGE_TEXT, L_IS_PERSON);

    /*
        Если определён сотрудник/организация то,
        находим и передаём мнемокод организация-инициатора/мнемокод сотрудника-инициатора
    */

--    p_exception(0, 'L_IS_PERSON: ' || to_char(L_IS_PERSON) || ', ' || 'SPHONE_IN: ' || SPHONE_IN);

    if ( L_IS_PERSON = 1 ) then
        begin
            select distinct
                CP.SCODE
            into L_SCLIENT_PERSON
            from
                UDO_V_PA_WEBQUEST_CLIENTVERIFY          WQ
                inner join V_CLNPERSONS                 CP
                on WQ.RN = CP.NRN
            where
                PHONE = SPHONE_IN;

        exception
            when others then
                L_SCLIENT_PERSON := null;
        end;
    else
        if ( L_IS_PERSON = 0 ) then
            begin
                select distinct
                    CP.SCLIENT_CODE
                into L_SCLIENT_CLIENT
                from
                    UDO_V_PA_WEBQUEST_CLIENTVERIFY          WQ
                    inner join V_CLIENTCLIENTS              CP
                    on WQ.TITLE = CP.SCLIENT_AGENT_NAME
                where
                    PHONE = SPHONE_IN;

            exception
                when others then
                    L_SCLIENT_CLIENT := null;
            end;

        end if;
    end if;

--    p_exception(0, 'L_SCLIENT_PERSON: ' || L_SCLIENT_PERSON || ', ' || 'L_SCLIENT_CLIENT: ' || L_SCLIENT_CLIENT || ', SPHONE_IN: ' || SPHONE_IN);


    /*
        Создаём событие средствами системы

        Пока не определяется клиент отправитель или получатель
        то регитсрируем default событие
    */
    UDO_P_PA_CLNEVENTS_INSERT (
        C_PARUS_COMPANY_RN,                               -- NCOMPANY           -- организация Парус
        C_EVENT_CATALOG_RN,                               -- NCRN               -- каталог события
        null,                                             -- SEVENT_PREF        -- префикс события, Генерится автоматичеки
        null,                                             -- SEVENT_NUMB        -- номер события, Генерится автоматичеки
        'СобытиеWeb',                                     -- SEVENT_TYPE        -- мнемокод типа события
        'НовоеСобытие',                                   -- SEVENT_STAT        -- мнемокод статуса события
        null,                                             -- DPLAN_DATE         -- плановая дата начала работ по событию
        'PARUS#адм#1#Парус_Алтай',                        -- SINIT_PERSON       -- мнемокод инициатора
        L_SCLIENT_CLIENT,                                 -- SCLIENT_CLIENT     -- мнемокод клиента-инициатора
        L_SCLIENT_PERSON,                                 -- SCLIENT_PERSON     -- мнемокод сотрудника-инициатора
        null,                                             -- SSEND_CLIENT       -- мнемокод клиента-исполнителя
        null,                                             -- SSEND_DIVISION     -- мнемокод подразделения-исполнителя
        null,                                             -- SSEND_POST         -- мнемокод должности-исполнителя
        null,                                             -- SSEND_PERFORM      -- мнемокод штатной должности-исполнителя
        null,                                             -- SSEND_PERSON       -- мнемокод сотрудника-исполнителя
        null,                                             -- SSEND_STAFFGRP     -- мнемокод нештатной структуры
        null,                                             -- SSEND_USER_GROUP   -- мнемокод группы пользователей
        null,                                             -- SSEND_USER_NAME    -- наименование пользователя
        F$EVENT_DESCRIPTION_TEMPLATE(
            SPHONE_IN,
            SCOMPANY_TITLE,
            SCLIENT_NAME,
            SMESSAGE_TEXT
        ),                                                -- SEVENT_DESCR       -- описание события
        null,                                             -- SREASON            -- причина события
        L_NEVENT_RN                                       -- NRN                -- регистрационный номер события
    );

    /*
        Обнуляем поле клиента заполняемое по умолчанию, при default генерации
    */
    if ( L_SCLIENT_CLIENT IS NULL) and (L_SCLIENT_PERSON IS NULL ) then
      update CLNEVENTS set CLIENT_PERSON = null where RN = L_NEVENT_RN;
	end if;

    -- Привязка события к обращению
    P$WEBQUESTION_CLNEVENT_BIND(L_QUESTION_RN, L_NEVENT_RN);


end UDO_P_PA_WEBQUESTION_REG;

