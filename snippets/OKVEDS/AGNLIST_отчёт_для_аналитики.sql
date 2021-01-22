/*
    Данные для предоставления в отчёт Excel
*/

/*
    Пустые ИНН
*/
select
    A.RN,
    A.AGNABBR,
    A.AGNNAME,
    A.FULLNAME,
    A.AGNTYPE,
    A.AGNIDNUMB,
    A.REASON_CODE
from
    AGNLIST A
where
    A.AGNTYPE = 0
    and A.AGNIDNUMB is null
;

/*
    Пустые/Невалидные КПП
*/
select
    A.RN,
    A.AGNABBR,
    A.AGNNAME,
    A.FULLNAME,
    A.AGNTYPE,
    A.AGNIDNUMB,
    A.REASON_CODE
from
    AGNLIST A
where
    A.AGNTYPE = 0
    and A.REASON_CODE is null
    or LENGTH(A.REASON_CODE) < 3
;

/*
    Пустые/Невалидные полные наименования
*/
select
    A.RN,
    A.AGNABBR,
    A.AGNNAME,
    A.FULLNAME,
    A.AGNTYPE,
    A.AGNIDNUMB,
    A.REASON_CODE
from
    AGNLIST A
where
    A.AGNTYPE = 0
    and A.FULLNAME is null
    or LENGTH(A.FULLNAME) < LENGTH(A.AGNNAME)
;

/*
    Записи с дублирующими ИНН
*/
select
    A.INN_CNT,
    A.RN,
    A.AGNABBR,
    A.AGNNAME,
    A.FULLNAME,
    A.AGNTYPE,
    A.AGNIDNUMB,
    A.REASON_CODE
from
    (
        select
            count(*) over(
                partition by A.AGNIDNUMB
            ) INN_CNT,
            A.*
        from
            AGNLIST A
        where
            A.AGNTYPE = 0
            and A.AGNIDNUMB is not null
    ) A
where
    A.INN_CNT > 1
;


/*
    Общий отчёт по вышеперечисленным
    not in для инвертирования
*/
select
    count(*) over(
        partition by A.AGNIDNUMB
    ) INN_MATCH,
    count(*) over(
        partition by A.AGNIDNUMB, A.REASON_CODE, A.AGNNAME, A.FULLNAME
    ) MATCH,
    A.*
from
    (
        select
            A.RN,
            A.AGNABBR,
            A.AGNNAME,
            A.FULLNAME,
            A.AGNTYPE,
            A.AGNIDNUMB,
            A.REASON_CODE
        from
            AGNLIST A
        where
            A.AGNTYPE = 0
            and A.RN in (
                select
                    A.RN
                from
                    (
                        ( select
                            A.RN,
                            A.AGNABBR,
                            A.AGNNAME,
                            A.FULLNAME,
                            A.AGNTYPE,
                            A.AGNIDNUMB,
                            A.REASON_CODE
                        from
                            AGNLIST A
                        where
                            A.AGNTYPE = 0
                            and A.AGNIDNUMB is null
                        )
                        union all
                        ( select
                            A.RN,
                            A.AGNABBR,
                            A.AGNNAME,
                            A.FULLNAME,
                            A.AGNTYPE,
                            A.AGNIDNUMB,
                            A.REASON_CODE
                        from
                            AGNLIST A
                        where
                            A.AGNTYPE = 0
                            and A.REASON_CODE is null
                            or LENGTH(A.REASON_CODE) < 3
                        )
                        union all
                        ( select
                            A.RN,
                            A.AGNABBR,
                            A.AGNNAME,
                            A.FULLNAME,
                            A.AGNTYPE,
                            A.AGNIDNUMB,
                            A.REASON_CODE
                        from
                            AGNLIST A
                        where
                            A.AGNTYPE = 0
                            and A.FULLNAME is null
                            or LENGTH(A.FULLNAME) < LENGTH(A.AGNNAME)
                        )
                        union all
                        ( select
                            A.RN,
                            A.AGNABBR,
                            A.AGNNAME,
                            A.FULLNAME,
                            A.AGNTYPE,
                            A.AGNIDNUMB,
                            A.REASON_CODE
                        from
                            AGNLIST A
                        where
                            A.RN in (
                                select
                                    A.RN
                                from
                                    (
                                        select
                                            count(*) over(
                                                partition by A.AGNIDNUMB
                                            ) INN_CNT,
                                            A.*
                                        from
                                            AGNLIST A
                                        where
                                            A.AGNTYPE = 0
                                            and A.AGNIDNUMB is not null
                                    ) A
                                where
                                    A.INN_CNT > 1
                            )
                        )
                    ) A
            )
    ) A;