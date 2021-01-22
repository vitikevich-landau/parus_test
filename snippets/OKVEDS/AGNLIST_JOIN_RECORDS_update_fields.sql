/*
    Update полей таблицы контрагентов данными из records
*/
declare
    L_CNT number := 0;
begin
    for REC in (
        with AGNS as (
            select
                *
            from
                (
                    select
                        count(*) over(
                            partition by A.AGNIDNUMB
                        ) as CNT,
                        A.*
                    from
                        UDO_T_PA_AGNLIST_TEMP A
                    where
                        -- Юр. лица
                        A.AGNTYPE = 0
                        -- Есть ИНН
                        and A.AGNIDNUMB is not null
                ) A
            where
                -- Без дублирующих ИНН
                A.CNT = 1
        ), RECS as (
            select
                *
            from
                (
                    select
                        count(*) over(
                            partition by R.INN, R.KPP
                        ) as CNT,
                        -- Добавить минимальный RN из группы, что бы убрать дубликаты
                        min(R.RN) over(
                            partition by R.INN, R.KPP
                        ) as FIRST_RN,
                        R.*
                    from
                        UDO_T_PA_VYPISKANALOG_RECODRS R
                    where
                        -- Действующие
                        R.STATUS = 'Действующая'
                        -- Есть ИНН
                        and R.INN is not null
                        -- Есть КПП
--                        and R.KPP is not null
                ) R
            where
                -- + первый RN из группы
                R.RN = R.FIRST_RN
        )
        select
            RECS.KPP,
            RECS.TITLE,
            AGNS.RN,
            AGNS.FULLNAME,
            AGNS.REASON_CODE
        from
            AGNS
            inner join RECS
            on AGNS.AGNIDNUMB = RECS.INN
    ) loop
--        L_CNT := L_CNT + 1;
        DBMS_OUTPUT.PUT_LINE(REC.RN
                             || ': '
                             || REC.FULLNAME
                             || ', '
                             || REC.REASON_CODE);

        if ( REC.FULLNAME is null ) then
            if ( REC.TITLE is not null ) then
                L_CNT := L_CNT + 1;
                DBMS_OUTPUT.PUT_LINE('FULLNAME: '
                                     || REC.FULLNAME
                                     || ', TITLE: '
                                     || REC.TITLE);

/*                update UDO_T_PA_AGNLIST_TEMP AGN
                set
                    AGN.FULLNAME = REC.TITLE
                where
                    AGN.RN = REC.RN;
*/

            end if;
        end if;

        if ( REC.REASON_CODE is null ) then
            if ( REC.KPP is not null ) then
                L_CNT := L_CNT + 1;
                DBMS_OUTPUT.PUT_LINE('REASON: '
                                     || REC.REASON_CODE
                                     || ', KPP: '
                                     || REC.KPP);
/*
                update UDO_T_PA_AGNLIST_TEMP AGN
                set
                    AGN.REASON_CODE = REC.KPP
                where
             AGN.RN = REC.RN;
 */

            end if;
        end if;

    end loop;

    DBMS_OUTPUT.PUT_LINE('L_CNT: ' || L_CNT);
end;