create or replace view UDO_V_PA_WEBQUEST_CLIENTVERIFY as
    select
        A.PHONE as PHONE,
        NVL(A.AGNFIRSTNAME, '') as NAME,
        DECODE(A.AGNFIRSTNAME, null, 0, 1) as IS_PERSON,
        NVL(B.AGNNAME, A.AGNNAME) as TITLE,
        C.RN
    from
        AGNLIST      A
        left join CLNPERSONS   C
        on C.PERS_AGENT = A.RN
        left join AGNLIST      B
        on B.RN = C.OWNER_AGENT
    where
        A.PHONE is not null
    union all
    select
        A.PHONE2 as PHONE,
        NVL(A.AGNFIRSTNAME, '') as NAME,
        DECODE(A.AGNFIRSTNAME, null, 0, 1) as IS_PERSON,
        NVL(B.AGNNAME, A.AGNNAME) as TITLE,
        C.RN
    from
        AGNLIST      A
        left join CLNPERSONS   C
        on C.PERS_AGENT = A.RN
        left join AGNLIST      B
        on B.RN = C.OWNER_AGENT
    where
        A.PHONE2 is not null
    union all
    select
        A.FAX as PHONE,
        NVL(A.AGNFIRSTNAME, '') as NAME,
        DECODE(A.AGNFIRSTNAME, null, 0, 1) as IS_PERSON,
        NVL(B.AGNNAME, A.AGNNAME) as TITLE,
        C.RN
    from
        AGNLIST      A
        left join CLNPERSONS   C
        on C.PERS_AGENT = A.RN
        left join AGNLIST      B
        on B.RN = C.OWNER_AGENT
    where
        A.FAX is not null
    union all
    select
        A.TELEX as PHONE,
        NVL(A.AGNFIRSTNAME, '') as NAME,
        DECODE(A.AGNFIRSTNAME, null, 0, 1) as IS_PERSON,
        NVL(B.AGNNAME, A.AGNNAME) as TITLE,
        C.RN
    from
        AGNLIST      A
        left join CLNPERSONS   C
        on C.PERS_AGENT = A.RN
        left join AGNLIST      B
        on B.RN = C.OWNER_AGENT
    where
        A.TELEX is not null;