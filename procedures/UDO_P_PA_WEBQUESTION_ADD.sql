create or replace procedure UDO_P_PA_WEBQUESTION_ADD (
    NRN              in   number,
    SPHONE           in   varchar2,
    SCOMPANY_TITLE   in   varchar2,
    SCLIENT_NAME     in   varchar2,
    SMESSAGE_TEXT    in   varchar2,
    NIS_PERSON       in   number default null
) is
begin
    insert into UDO_T_PA_CLNEVNTS_WEBQUESTIONS (
        RN,
        PRN,
        PHONE,
        COMPANY_TITLE,
        CLIENT_NAME,
        MESSAGE_TEXT,
        STATUS,
        RATING,
        REG_DATE,
        DONE_DATE,
        IS_PERSON
    ) values (
        NRN,
        null,
        SPHONE,
        SCOMPANY_TITLE,
        SCLIENT_NAME,
        SMESSAGE_TEXT,
        null,
        null,
        SYSDATE,
        null,
        NIS_PERSON
    );

    commit;
end UDO_P_PA_WEBQUESTION_ADD;