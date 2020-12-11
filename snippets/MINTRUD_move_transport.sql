create or replace procedure UDO_PA_P_ESTVEHICO_MOVE
-- Передача автотранспорта другой организации (Парус-Алтай 11.12.2020)
-- (MINTRUD Минтруд_РА)
-- Управление госимуществом, транспортные средства
 (
    NCOMPANY        in   number,
    NIDENT          in   number,      -- идентификатор помеченных записей
    SORG_CODE_NEW   in   varchar2     -- Подведомственное учреждение приемник
) as
    SSQL         varchar2(4000);
    L_ORG        PKG_STD.TREF;
    L_JUR_PERS   PKG_STD.TREF;
begin
    select
        RN,
        JUR_PERS
    into
        L_ORG,
        L_JUR_PERS
    from
        GMZORG
    where
        COMPANY = NCOMPANY
        and CODE = SORG_CODE_NEW;

    for REC in (
        select
            SL.DOCUMENT
        from
            SELECTLIST SL
        where
            SL.IDENT = NIDENT
    ) loop
        SSQL   := 'ALTER TABLE ESTVEHI DISABLE ALL TRIGGERS';
        execute immediate SSQL;
        begin
            update ESTVEHI
            set
                ORG = L_ORG,
                JUR_PERS = L_JUR_PERS
            where
                RN = REC.DOCUMENT;

        exception
            when others then
                SSQL := 'ALTER TABLE ESTVEHI ENABLE ALL TRIGGERS';
                execute immediate SSQL;
                raise;
        end;

        SSQL   := 'ALTER TABLE ESTVEHI ENABLE ALL TRIGGERS';
        execute immediate SSQL;
    end loop;

end UDO_PA_P_ESTVEHICO_MOVE;