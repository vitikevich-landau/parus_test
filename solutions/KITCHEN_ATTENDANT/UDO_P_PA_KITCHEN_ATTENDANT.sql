create or replace procedure UDO_P_PA_KITCHEN_ATTENDANT is
    L_SMSG     varchar2(200);
    REQ        UTL_HTTP.REQ;
    RES        UTL_HTTP.RESP;
    SCONTENT   varchar2(4000);
begin
    begin
        select
            T.FULLNAME
        into L_SMSG
        from
            UDO_T_PA_KITCHEN_ATTENDANT T
        where
            T.DAY_NUMBER = MOD(TO_NUMBER(TO_CHAR(SYSDATE + 1, 'J')), 7)
            and T.WEEK_NUMBER = TRUNC((TO_CHAR(SYSDATE, 'dd') + MOD(TRUNC(SYSDATE, 'mm') - to_date('03.01.2005', 'dd.mm.yyyy'), 7
            ) + 6) / 7);

    exception
        when others then
            L_SMSG := null;
    end;

    if ( L_SMSG is null ) then
        L_SMSG := 'На сегодня дежурный не назначен. Кто-то должен вынести мусор!';
    else
        L_SMSG := 'Сегодня дежурит: '
                  || L_SMSG
                  || '\r\n'
                  || 'Не забудьте вынести мусор!';
    end if;

    SCONTENT   := '{"msg":"'
                || L_SMSG
                || '"}';
    REQ        := UTL_HTTP.BEGIN_REQUEST('http://192.168.1.200:8185/api/mychat-send-kitchen-message', 'POST', ' HTTP/1.1');
    UTL_HTTP.SET_HEADER(REQ, 'user-agent', 'mozilla/5.0');
    UTL_HTTP.SET_HEADER(REQ, 'Transfer-Encoding', 'chunked');
    UTL_HTTP.SET_HEADER(REQ, 'content-type', 'application/json;charset=utf-8');
    UTL_HTTP.SET_BODY_CHARSET(REQ, 'UTF-8');
    UTL_HTTP.WRITE_TEXT(REQ, SCONTENT);
    RES        := UTL_HTTP.GET_RESPONSE(REQ);

end UDO_P_PA_KITCHEN_ATTENDANT;
