create or replace procedure UDO_P_PA_KITCHEN_ATTENDANT is

    REQ           UTL_HTTP.REQ;
    RES           UTL_HTTP.RESP;
    SCONTENT      varchar2(4000);
    L_SMSG        varchar(400);
    L_NNUM        number;
    L_NMAX        number;
    L_SFULLNAME   varchar2(160);
begin
    select
        NUM
    into L_NNUM
    from
        UDO_T_PA_KITCHEN_ATTENDANT
    where
        IS_ACTIVE = 1;

    select
        max(NUM)
    into L_NMAX
    from
        UDO_T_PA_KITCHEN_ATTENDANT;

    select
        FULLNAME
    into L_SFULLNAME
    from
        UDO_T_PA_KITCHEN_ATTENDANT
    where
        NUM = L_NNUM;

    -- Обнулить текущего

    update UDO_T_PA_KITCHEN_ATTENDANT
    set
        IS_ACTIVE = 0
    where
        NUM = L_NNUM;

    if ( L_NNUM >= L_NMAX ) then
        L_NNUM := 1;
    else
        L_NNUM := L_NNUM + 1;
    end if;

    -- Установить следующего

    update UDO_T_PA_KITCHEN_ATTENDANT
    set
        IS_ACTIVE = 1
    where
        NUM = L_NNUM;

    if ( L_SFULLNAME is null ) then
        L_SMSG := 'На сегодня дежурный не назначен. Кто-то должен вынести мусор!';
    else
        L_SMSG := 'Сегодня дежурит: '
                  || L_SFULLNAME
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

    commit;
end UDO_P_PA_KITCHEN_ATTENDANT;