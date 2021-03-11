-- Клиенты из каталогов Бюджет и Муниципальный учёт

select /*C.*,*/
    A.AGNNAME,
    A.AGNIDNUMB
from
    V_CLIENTCLIENTS   C
    left join AGNLIST           A
    on A.RN = C.NCLIENT_AGENT
where
    A.AGNTYPE = 0
    and C.NCRN in (
        74311,
        55900,
        1154790,
        1154178,
        1154309,
        1583018,
        1153886,
        1154523,
        1154017,
        841772,
        55990,
        56080,
        56125,
        56215,
        56260,
        56350,
        56305,
        56395,
        56440,
        56485,
        56981,
        57026,
        57161,
        57206,
        57251,
        57296,
        57386,
        57431,
        57476,
        57521,
        57566
    )
    and ( LENGTH(A.AGNIDNUMB) != 10
          or A.AGNIDNUMB is null );