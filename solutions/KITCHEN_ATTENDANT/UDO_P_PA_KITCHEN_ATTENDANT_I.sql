create or replace procedure UDO_P_PA_KITCHEN_ATTENDANT_I is
-- Дежурный сегодня, только информирование

    REQ           UTL_HTTP.REQ;
    RES           UTL_HTTP.RESP;
    SCONTENT      varchar2(4000);
    L_SMSG        varchar(400);
    L_NNUM        number;
    L_SFULLNAME   varchar2(160);
begin
    select
        NUM
    into L_NNUM -- текущий
    from
        UDO_T_PA_KITCHEN_ATTENDANT
    where
        IS_ACTIVE = 1;

    select
        FULLNAME
    into L_SFULLNAME -- фио
    from
        UDO_T_PA_KITCHEN_ATTENDANT
    where
        NUM = L_NNUM;


    if ( L_SFULLNAME is null ) then
        L_SMSG := 'На сегодня дежурный не назначен.';
    else
        L_SMSG := 'Сегодня дежурит: '
                  || L_SFULLNAME;
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

    commit;
end UDO_P_PA_KITCHEN_ATTENDANT_I;
