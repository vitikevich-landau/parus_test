create table UDO_T_PA_CLNEVNTS_WEBQUESTIONS (
    RN              number(17) not null,
    PRN             number(17),
    PHONE           varchar2(40),
    COMPANY_TITLE   varchar2(160),
    CLIENT_NAME     varchar2(160),
    MESSAGE_TEXT    varchar2(2000),
    STATUS          number(17),
    RATING          number(17),
    IS_PERSON       number(1),
    REG_DATE        date,
    DONE_DATE       date
)