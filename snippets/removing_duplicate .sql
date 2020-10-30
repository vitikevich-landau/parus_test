delete from TABLENAME A
where
    A.ROWID > any (
        select
            B.ROWID
        from
            TABLENAME B
        where
            A.FIELDNAME = B.FIELDNAME
            and A.FIELDNAME2 = B.FIELDNAME2
    );


delete from EMP
where
    rowid not in (
        select
            max(rowid)
        from
            EMP
        group by
            EMPNO
    );