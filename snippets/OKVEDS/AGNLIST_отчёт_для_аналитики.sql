/*
    Данные для предоставления в отчёт Excel
*/

/*
    Пустые ИНН
*/
select
    *
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
    *
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
    *
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
    *
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
    A.INN_CNT > 1;