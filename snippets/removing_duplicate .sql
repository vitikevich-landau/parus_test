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


select
    *
from
    UDO_T_PA_CRLCERT_REVOKED
where
    rowid not in (
        select
            max(rowid)
        from
            UDO_T_PA_CRLCERT_REVOKED
        group by
            SERIAL_NUMBER
    );