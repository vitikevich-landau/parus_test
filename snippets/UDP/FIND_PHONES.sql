-- Поиск невалидных номеров телефонов
select
    T.RN,
    T.PHONE,
    T.PHONE2,
    T.FAX,
    T.TELEX,
    T.ROWID
from
    AGNLIST T
where
    ( INSTR(T.PHONE, '8') = 1
      or INSTR(T.PHONE2, '8') = 1
      or INSTR(T.FAX, '8') = 1
      or INSTR(T.TELEX, '8') = 1 )
    or ( INSTR(T.PHONE, '+') = 1
         or INSTR(T.PHONE2, '+') = 1
         or INSTR(T.FAX, '+') = 1
         or INSTR(T.TELEX, '+') = 1 )
    or ( LENGTH(T.PHONE) < 11
         or LENGTH(T.PHONE2) < 11
         or LENGTH(T.FAX) < 11
         or LENGTH(T.TELEX) < 11 )