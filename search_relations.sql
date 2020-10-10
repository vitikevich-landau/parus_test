SELECT
    p.table_name,
--    c1.column_name, /* Некоторый космментарий в коде */
    c.table_name,
    c.column_name
FROM
    all_constraints    p
    INNER JOIN all_constraints    r
    ON r.constraint_type = 'R'
       AND r.r_constraint_name = p.constraint_nameex
    INNER JOIN all_cons_columns   c
    ON c.constraint_name = r.constraint_name
--    INNER JOIN all_cons_columns   c1
--    ON c1.constraint_name = p.constraint_name
WHERE
    p.constraint_type IN (
        'P'
    )
    AND p.table_name like 'CLNPERSONS' -- зависит от того
ORDER BY
    r.table_name,
    --c.column_name
