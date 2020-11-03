create or replace procedure UDO_P_PA_INTDOCS_PROX (
-- 03.11.2020 Добавлены доп параметры. Парус-Алтай.
    NCOMPANY       in   number,                                            -- организация
    NIDENT         in   number,                                            -- отмеченные записи
    /* add */
    NPREF_ENABLE   in   number,                                            -- печатать префкис да/нет
    dDATE_FROM     in   date,                                              -- дата выдачи
    dDATE_TO       in   date,                                              -- доверенность действительна по
    nDOC           in   varchar2,                                          -- документ основание или входящий документ
    sAGN           in   varchar2                                           -- контрагент кому выдано
) as

  -- константы листа

    TEMPL_SHEET_NAME       constant PKG_STD.TSTRING := 'ДОВЕРЕННОСТЬ';        -- Имя листа
  -- Тело отчёта
    SJP_ORGCODE            constant PKG_STD.TSTRING := 'SJP_ORGCODE';         -- по ОКПО
    SJP_AGNABBR            constant PKG_STD.TSTRING := 'SJP_AGNABBR';         -- Организация
    NUMB_DOC               constant PKG_STD.TSTRING := 'Numb_Doc';            -- Доверенность №
    NUMB_DOCD              constant PKG_STD.TSTRING := 'Numb_DocD';           -- Доверенность №
    SDATE_ISSUE            constant PKG_STD.TSTRING := 'SDATE_ISSUE';         -- Дата выдачи
    SDATE_EXP              constant PKG_STD.TSTRING := 'SDATE_EXP';           -- Доверенность действительна по
    PAYER                  constant PKG_STD.TSTRING := 'Payer';               -- наименование потребителя и его адрес
    SJP_AGNACC             constant PKG_STD.TSTRING := 'SJP_AGNACC';          -- Счёт № 1
    SJP_BANKACC_ALL        constant PKG_STD.TSTRING := 'SJP_BANKACC_ALL';     -- Счёт № 2
    BANK_STR               constant PKG_STD.TSTRING := 'Bank_Str';            -- наименование банка
    SAGTO_EMPPOST          constant PKG_STD.TSTRING := 'SAGTO_EMPPOST';       -- Доверенность выдана - должность
    NAME                   constant PKG_STD.TSTRING := 'name';                -- Доверенность выдана- фамилия, имя, отчество
    SAGTO_PASSPORT_SER     constant PKG_STD.TSTRING := 'SAGTO_PASSPORT_SER';  -- Паспорт : серия
    SAGTO_PASSPORT_NUMB    constant PKG_STD.TSTRING := 'SAGTO_PASSPORT_NUMB'; -- Паспорт : №
    SAGTO_PASSPORT_WHO     constant PKG_STD.TSTRING := 'SAGTO_PASSPORT_WHO';  -- Кем выдан
    SAGTO_SPASSPORT_WHEN   constant PKG_STD.TSTRING := 'SAGTO_SPASSPORT_WHEN'; -- Дата выдачи
    SAGFR_NAME             constant PKG_STD.TSTRING := 'SAGFR_NAME';          -- На получение от
    VALID                  constant PKG_STD.TSTRING := 'Valid';               -- материальных ценностей по
    VALIDD                 constant PKG_STD.TSTRING := 'ValidD';              -- материальных ценностей по
  -- таблица 1
    DDOC_DATE              constant PKG_STD.TSTRING := 'DDOC_DATE';           -- Дата выдачи
    DDOC_DATE_MOR          constant PKG_STD.TSTRING := 'DDOC_DATE_MOR';       -- Срок действия
    POST_NAME              constant PKG_STD.TSTRING := 'Post_Name';           -- Должность и фамилия лица, которому выдана доверенность
    SAGFR_NAMED            constant PKG_STD.TSTRING := 'SAGFR_NAMED';         -- Поставщик
  -- таблица 2
  -- Строка
    LINE_STR               constant PKG_STD.TSTRING := 'строка';
    SNOMEN_NAME            constant PKG_STD.TSTRING := 'SNOMEN_NAME';         -- Материальные ценности
    SUMEAS_MAIN            constant PKG_STD.TSTRING := 'SUMEAS_MAIN';         -- Единица измерения
    QUANTCELL              constant PKG_STD.TSTRING := 'QuantCell';
  -- окончание
    SJP_MANAGER            constant PKG_STD.TSTRING := 'SJP_MANAGER';         -- Руководитель
    SJP_MANAGER0           constant PKG_STD.TSTRING := 'SJP_MANAGERO';        -- Главный бухгалтер
    IDET_IDX               integer;
    SCUR_SHEET_NAME        PKG_STD.TSTRING;
    NDOCQUANT              PKG_STD.TQUANT;
    SDOCQUANT              PKG_STD.TSTRING;
    NRESTDOCQUANT          PKG_STD.TNUMBER;
    SRESTDOCQUANT          PKG_STD.TSTRING;
    SQUANTTOTEXT           PKG_STD.TSTRING;
begin

--   p_exception(0, 'after begin');

  -- пролог
    PRSG_EXCEL.PREPARE;

  -- цикл по внутренним документам
    for TREC in (
        select
            ID.RN               NRN,
            JA.ORGCODE          SJP_ORGCODE,
            JA.AGNABBR          SJP_AGNABBR,
            JA.AGNNAME          SJP_AGNNAME,
            JA.ADDR_POST        SJP_ADDR_POST,
            (
                select
                    CI.GEOGRNAME
                from
                    GEOGRAFY CI
                where
                    CI.RN = JA.ADDR_CITY_RN
            ) SJP_ADDR_CITY,
            (
                select
                    ST.GEOGRNAME
                from
                    GEOGRAFY ST
                where
                    ST.RN = JA.ADDR_STREET_RN
            ) SJP_ADDR_STREET,
            JA.ADDR_HOUSE       SJP_ADDR_HOUSE,
            JA.ADDR_BLOCK       SJP_ADDR_BLOCK,
            JA.ADDR_FLAT        SJP_ADDR_FLAT,
            JAA.AGNACC          SJP_AGNACC,
            JAB.BANKFCODEACC    SJP_BANKFCODEACC,
            NVL(JAA.BANKNAMEACC, JABA.AGNNAME) SJP_BANKNAMEACC_ALL,
            NVL(JAA.BANKACC, JAB.BANKACC) SJP_BANKACC_ALL,
            NVL(JAA.BANKCITYACC,(
                select
                    B_CI.GEOGRNAME
                from
                    GEOGRAFY B_CI
                where
                    B_CI.RN = JABA.ADDR_CITY_RN
            )) SJP_BANKCITYACC_ALL,
            DT1.DOCCODE         SDOC_TYPE,
            ID.DOC_PREFIX       SDOC_PREFIX,
            ID.DOC_NUMBER       SDOC_NUMBER,
            PKG_DOCUMENT.MAKE_NUMBER(ID.DOC_PREFIX, ID.DOC_NUMBER) SDOC_PREFNUMB,
            ID.DOC_DATE         DDOC_DATE,
            DT2.DOCCODE         SVALID_DOCTYPE,
            /* add */
            DT2.DOCNAME         SVALID_DOCNAME,
            DT3.DOCNAME         SIN_DOCNAME,
            ID.IN_DOCNUMB    SIN_DOCNUMB,
            ID.IN_DOCDATE    DIN_DOCDATE,
            /*  */
            ID.VALID_DOCNUMB    SVALID_DOCNUMB,
            ID.VALID_DOCDATE    DVALID_DOCDATE,
            AG1.AGNNAME         SAGFR_NAME,
            AG1.ADDR_POST       SAGFR_ADDR_POST,
            (
                select
                    AF_CI.GEOGRNAME
                from
                    GEOGRAFY AF_CI
                where
                    AF_CI.RN = AG1.ADDR_CITY_RN
            ) SAGFR_ADDR_CITY,
            (
                select
                    AF_ST.GEOGRNAME
                from
                    GEOGRAFY AF_ST
                where
                    AF_ST.RN = AG1.ADDR_STREET_RN
            ) SAGFR_ADDR_STREET,
            AG1.ADDR_HOUSE      SAGFR_ADDR_HOUSE,
            AG1.ADDR_BLOCK      SAGFR_ADDR_BLOCK,
            AG1.ADDR_FLAT       SAGFR_ADDR_FLAT,
--- mod
            AG2.AGNFAMILYNAME   SAGTO_FAMILYNAME,
            AG2.AGNFIRSTNAME    SAGTO_FIRSTNAME,
            AG2.AGNLASTNAME     SAGTO_LASTNAME,
            AG2.EMPPOST         SAGTO_EMPPOST,
            AG2.PASSPORT_SER    SAGTO_PASSPORT_SER,
            AG2.PASSPORT_NUMB   SAGTO_PASSPORT_NUMB,
            AG2.PASSPORT_WHO    SAGTO_PASSPORT_WHO,
            ( TO_CHAR(D_DAY(AG2.PASSPORT_WHEN))
              || ' '
              || F_SMONTH_BASE(D_MONTH(AG2.PASSPORT_WHEN), 1)
              || ' '
              || TO_CHAR(D_YEAR(AG2.PASSPORT_WHEN))
              || ' г.' ) SAGTO_SPASSPORT_WHEN,
---
            (
                select
                    NOTE
                from
                    AGNMANAGE
                where
                    PRN = J.AGENT
                    and POSITION = 1
                    and REG_DATE = (
                        select
                            max(REG_DATE)
                        from
                            AGNMANAGE
                        where
                            PRN = J.AGENT
                            and POSITION = 1
                            and REG_DATE <= ID.DOC_DATE
                    )
            ) SJP_MANAGER,      -- Руководство Юр. лица
            ( TO_CHAR(D_DAY(ID.DOC_DATE))
              || ' '
              || F_SMONTH_BASE(D_MONTH(ID.DOC_DATE), 1)
              || ' '
              || TO_CHAR(D_YEAR(ID.DOC_DATE))
              || ' г.' ) SDATE_ISSUE,      -- Дата выдачи
            ( TO_CHAR(D_DAY(ID.DOC_DATE + 14))
              || ' '
              || F_SMONTH_BASE(D_MONTH(ID.DOC_DATE + 14), 1)
              || ' '
              || TO_CHAR(D_YEAR(ID.DOC_DATE + 14))
              || ' г.' ) SDATE_EXP,        -- Дата по
            (
                select
                    NOTE
                from
                    AGNMANAGE
                where
                    PRN = J.AGENT
                    and POSITION = 0
                    and REG_DATE = (
                        select
                            max(REG_DATE)
                        from
                            AGNMANAGE
                        where
                            PRN = J.AGENT
                            and POSITION = 0
                            and REG_DATE <= ID.DOC_DATE
                    )
            ) SJP_MANAGER0      -- Гл.Бух Юр. лица
        from
            SELECTLIST   SL,
            INTDOCS      ID,
            JURPERSONS   J,
            DOCTYPES     DT1,
            DOCTYPES     DT2,
            DOCTYPES     DT3,
            AGNLIST      AG1,
            AGNLIST      AG2,
            AGNLIST      JA,
            (
                select
                    VA.AGNRN,
                    max(VA.RN) AGNACC
                from
                    AGNACC     VA,
                    AGNBANKS   VAB,
                    AGNLIST    VABA
                where
                    VA.AGNBANKS = VAB.RN
                    and VAB.AGNRN = VABA.RN
                group by
                    VA.AGNRN
            ) VACC,
            AGNACC       JAA,
            AGNBANKS     JAB,
            AGNLIST      JABA
        where
            SL.IDENT = NIDENT
            and SL.DOCUMENT = ID.RN
            and ID.JUR_PERS = J.RN
            and ID.DOC_TYPE = DT1.RN
            and ID.VALID_DOCTYPE = DT2.RN (+)
            and ID.IN_DOCTYPE = DT3.RN (+)
            and ID.AGENT_FROM = AG1.RN (+)
           -- and ID.AGENT_TO = AG2.RN (+)

            and AG2.AGNABBR = sAGN --add по мнемокоду из параметров
            and J.AGENT = JA.RN (+)
            and JA.RN = VACC.AGNRN (+)
            and VACC.AGNACC = JAA.RN (+)
            and JAA.AGNBANKS = JAB.RN (+)
            and JAB.AGNRN = JABA.RN (+)
    ) loop

    -- установка рабочего листа
        SCUR_SHEET_NAME := PRSG_EXCEL.FORM_SHEET_NAME(TREC.SDOC_TYPE
                                                      || ','
                                                      || TREC.SDOC_PREFNUMB
                                                      || ' '
                                                      || TEMPL_SHEET_NAME);

        PRSG_EXCEL.SHEET_COPY(TEMPL_SHEET_NAME, SCUR_SHEET_NAME);
        PRSG_EXCEL.SHEET_SELECT(SCUR_SHEET_NAME);
    -- описание
    -- заголовок
        PRSG_EXCEL.CELL_DESCRIBE(SJP_ORGCODE);
        PRSG_EXCEL.CELL_DESCRIBE(SJP_AGNABBR);
        PRSG_EXCEL.CELL_DESCRIBE(NUMB_DOC);
        PRSG_EXCEL.CELL_DESCRIBE(NUMB_DOCD);
        PRSG_EXCEL.CELL_DESCRIBE(SDATE_ISSUE);
        PRSG_EXCEL.CELL_DESCRIBE(SDATE_EXP);
        PRSG_EXCEL.CELL_DESCRIBE(PAYER);
        PRSG_EXCEL.CELL_DESCRIBE(SJP_AGNACC);
        PRSG_EXCEL.CELL_DESCRIBE(SJP_BANKACC_ALL);
        PRSG_EXCEL.CELL_DESCRIBE(BANK_STR);
        PRSG_EXCEL.CELL_DESCRIBE(SAGTO_EMPPOST);
        PRSG_EXCEL.CELL_DESCRIBE(NAME);
        PRSG_EXCEL.CELL_DESCRIBE(SAGTO_PASSPORT_SER);
        PRSG_EXCEL.CELL_DESCRIBE(SAGTO_PASSPORT_NUMB);
        PRSG_EXCEL.CELL_DESCRIBE(SAGTO_PASSPORT_WHO);
        PRSG_EXCEL.CELL_DESCRIBE(SAGTO_SPASSPORT_WHEN);
        PRSG_EXCEL.CELL_DESCRIBE(SAGFR_NAME);
        PRSG_EXCEL.CELL_DESCRIBE(VALID);
        PRSG_EXCEL.CELL_DESCRIBE(VALIDD);
    -- таблица 1
        PRSG_EXCEL.CELL_DESCRIBE(DDOC_DATE);
        PRSG_EXCEL.CELL_DESCRIBE(DDOC_DATE_MOR);
        PRSG_EXCEL.CELL_DESCRIBE(POST_NAME);
        PRSG_EXCEL.CELL_DESCRIBE(SAGFR_NAMED);
    -- таблица 2
        PRSG_EXCEL.LINE_DESCRIBE(LINE_STR);
        PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_STR, LINE_STR);
        PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_STR, SNOMEN_NAME);
        PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_STR, SUMEAS_MAIN);
        PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE_STR, QUANTCELL);
    -- окончание
        PRSG_EXCEL.CELL_DESCRIBE(SJP_MANAGER);
        PRSG_EXCEL.CELL_DESCRIBE(SJP_MANAGER0);

    -- запись заголовка
        PRSG_EXCEL.CELL_VALUE_WRITE(SJP_ORGCODE, TREC.SJP_ORGCODE);
        --PRSG_EXCEL.CELL_VALUE_WRITE(SJP_AGNABBR, TREC.SJP_AGNABBR);
        PRSG_EXCEL.CELL_VALUE_WRITE(SJP_AGNABBR, TREC.SJP_AGNNAME);

        if NPREF_ENABLE = 1 then
            if TREC.SDOC_PREFIX is not null then
                PRSG_EXCEL.CELL_VALUE_WRITE(NUMB_DOC, TRIM(TREC.SDOC_PREFIX)
                                                      || '/'
                                                      || TRIM(TREC.SDOC_NUMBER));

                PRSG_EXCEL.CELL_VALUE_WRITE(NUMB_DOCD, TRIM(TREC.SDOC_PREFIX)
                                                       || '/'
                                                       || TRIM(TREC.SDOC_NUMBER));

            else
                PRSG_EXCEL.CELL_VALUE_WRITE(NUMB_DOC, TRIM(TREC.SDOC_NUMBER));
                PRSG_EXCEL.CELL_VALUE_WRITE(NUMB_DOCD, TRIM(TREC.SDOC_NUMBER));
            end if;
        else
            PRSG_EXCEL.CELL_VALUE_WRITE(NUMB_DOC, TRIM(TREC.SDOC_NUMBER));
            PRSG_EXCEL.CELL_VALUE_WRITE(NUMB_DOCD, TRIM(TREC.SDOC_NUMBER));
        end if;

--        PRSG_EXCEL.CELL_VALUE_WRITE(SDATE_ISSUE, TREC.SDATE_ISSUE);
--        PRSG_EXCEL.CELL_VALUE_WRITE(SDATE_EXP, TREC.SDATE_EXP);
        PRSG_EXCEL.CELL_VALUE_WRITE(SDATE_ISSUE, to_char(dDATE_FROM, 'dd.mm.yyyy'));
        PRSG_EXCEL.CELL_VALUE_WRITE(SDATE_EXP, to_char(dDATE_TO, 'dd.mm.yyyy'));

        PRSG_EXCEL.CELL_VALUE_WRITE(PAYER, NVL(TREC.SJP_AGNNAME, TREC.SJP_AGNABBR)
                                           || ' '
                                           || LTRIM(TREC.SJP_ADDR_POST || ', ', ', ')
                                           || LTRIM(TREC.SJP_ADDR_CITY || ', ', ', ')
                                           || LTRIM(TREC.SJP_ADDR_STREET || ', ', ', ')
                                           || LTRIM(TREC.SJP_ADDR_HOUSE || ', ', ', ')
                                           || LTRIM(TREC.SJP_ADDR_BLOCK || ', ', ', ')
                                           || LTRIM(TREC.SJP_ADDR_FLAT || ', ', ', '));

        PRSG_EXCEL.CELL_VALUE_WRITE(SJP_AGNACC, TREC.SJP_AGNACC);
        PRSG_EXCEL.CELL_VALUE_WRITE(SJP_BANKACC_ALL, TREC.SJP_BANKACC_ALL);
        PRSG_EXCEL.CELL_VALUE_WRITE(BANK_STR, LTRIM(TREC.SJP_BANKNAMEACC_ALL || ', ', ', ')
                                              || LTRIM(TREC.SJP_BANKCITYACC_ALL || ', ', ', ')
                                              || case
            when TREC.SJP_BANKFCODEACC is not null then
                ' БИК ' || TREC.SJP_BANKFCODEACC
                                                 end);

        PRSG_EXCEL.CELL_VALUE_WRITE(SAGTO_EMPPOST, TREC.SAGTO_EMPPOST);
        PRSG_EXCEL.CELL_VALUE_WRITE(NAME, TREC.SAGTO_FAMILYNAME
                                          || RTRIM(' ' || TREC.SAGTO_FIRSTNAME, ' ')
                                          || RTRIM(' ' || TREC.SAGTO_LASTNAME, ' '));

        PRSG_EXCEL.CELL_VALUE_WRITE(SAGTO_PASSPORT_SER, TREC.SAGTO_PASSPORT_SER);
        PRSG_EXCEL.CELL_VALUE_WRITE(SAGTO_PASSPORT_NUMB, TREC.SAGTO_PASSPORT_NUMB);
        PRSG_EXCEL.CELL_VALUE_WRITE(SAGTO_PASSPORT_WHO, TREC.SAGTO_PASSPORT_WHO);
        PRSG_EXCEL.CELL_VALUE_WRITE(SAGTO_SPASSPORT_WHEN, TREC.SAGTO_SPASSPORT_WHEN);
        PRSG_EXCEL.CELL_VALUE_WRITE(SAGFR_NAME, TREC.SAGFR_NAME
                                                || ' '
                                                || RTRIM(LTRIM(TREC.SAGFR_ADDR_POST || ', ', ', ')
                                                         || LTRIM(TREC.SAGFR_ADDR_CITY || ', ', ', ')
                                                         || LTRIM(TREC.SAGFR_ADDR_STREET || ', ', ', ')
                                                         || LTRIM(TREC.SAGFR_ADDR_HOUSE || ', ', ', ')
                                                         || LTRIM(TREC.SAGFR_ADDR_BLOCK || ', ', ', ')
                                                         || TREC.SAGFR_ADDR_FLAT, ', '));


     if nDOC = 'документ-основание' then
        PRSG_EXCEL.CELL_VALUE_WRITE(VALID,  TREC.SVALID_DOCNAME /*TREC.SVALID_DOCTYPE*/
                                           || ' № '
                                           || TREC.SVALID_DOCNUMB
                                           || ' от '
                                           || TO_CHAR(TREC.DVALID_DOCDATE, 'dd.mm.yyyy'));

        PRSG_EXCEL.CELL_VALUE_WRITE(VALIDD, TREC.SVALID_DOCNAME /*TREC.SVALID_DOCTYPE*/
                                            || ' № '
                                            || TREC.SVALID_DOCNUMB
                                            || ' от '
                                            || TO_CHAR(TREC.DVALID_DOCDATE, 'dd.mm.yyyy'));
    else
        PRSG_EXCEL.CELL_VALUE_WRITE(VALID,  TREC.SIN_DOCNAME /*TREC.SVALID_DOCTYPE*/
                                           || ' № '
                                           || TREC.SIN_DOCNUMB
                                           || ' от '
                                           || TO_CHAR(TREC.DIN_DOCDATE, 'dd.mm.yyyy'));


        PRSG_EXCEL.CELL_VALUE_WRITE(VALIDD, TREC.SIN_DOCNAME /*TREC.SVALID_DOCTYPE*/
                                            || ' № '
                                            || TREC.SIN_DOCNUMB
                                            || ' от '
                                            || TO_CHAR(TREC.DIN_DOCDATE, 'dd.mm.yyyy'));
    end if;

    -- таблица 1

--        PRSG_EXCEL.CELL_VALUE_WRITE(DDOC_DATE, TO_CHAR(TREC.DDOC_DATE, 'dd.mm.yyyy'));
--        PRSG_EXCEL.CELL_VALUE_WRITE(DDOC_DATE_MOR, TO_CHAR(TREC.DDOC_DATE + 14, 'dd.mm.yyyy'));
        PRSG_EXCEL.CELL_VALUE_WRITE(DDOC_DATE, TO_CHAR(dDATE_FROM, 'dd.mm.yyyy'));
        PRSG_EXCEL.CELL_VALUE_WRITE(DDOC_DATE_MOR, TO_CHAR(dDATE_TO, 'dd.mm.yyyy'));

        PRSG_EXCEL.CELL_VALUE_WRITE(POST_NAME, TREC.SAGTO_EMPPOST
                                               || ' '
                                               || LTRIM(TREC.SAGTO_FAMILYNAME || ' ')
                                               || LTRIM(SUBSTR(TREC.SAGTO_FIRSTNAME, 1, 1)
                                                        || '. ', '. ')
                                               || LTRIM(SUBSTR(TREC.SAGTO_LASTNAME, 1, 1)
                                                        || '. ', '. '));

        PRSG_EXCEL.CELL_VALUE_WRITE(SAGFR_NAMED, TREC.SAGFR_NAME);
    -- окончание
        PRSG_EXCEL.CELL_VALUE_WRITE(SJP_MANAGER, TREC.SJP_MANAGER);
        PRSG_EXCEL.CELL_VALUE_WRITE(SJP_MANAGER0, TREC.SJP_MANAGER0);
    -- цикл по спецификациям
        for RFLD in (
            select
                ISP.RN          NRN,
                NO.NOMEN_NAME   SNOMEN_NAME,
                MM.MEAS_MNEMO   SUMEAS_MAIN,
                ISP.DOC_QUANT   NDOC_QUANT,
                NUM2TEXT(ISP.DOC_QUANT) SDOC_QUANT
            from
                INTDOCS_SP   ISP,
                DICNOMNS     NO,
                DICMUNTS     MM
            where
                TREC.NRN = ISP.PRN
                and ISP.NOMENCLATURE = NO.RN (+)
                and NO.UMEAS_MAIN = MM.RN (+)
        ) loop
      -- запись строки
            IDET_IDX        := PRSG_EXCEL.LINE_CONTINUE(LINE_STR);
            PRSG_EXCEL.CELL_VALUE_WRITE(SNOMEN_NAME, 0, IDET_IDX, RFLD.SNOMEN_NAME);
            PRSG_EXCEL.CELL_VALUE_WRITE(SUMEAS_MAIN, 0, IDET_IDX, RFLD.SUMEAS_MAIN);
            NDOCQUANT       := RFLD.NDOC_QUANT;
            SDOCQUANT       := TRIM(RFLD.SDOC_QUANT);
            NRESTDOCQUANT   := ( NDOCQUANT - TRUNC(NDOCQUANT) ) * 1000;
            SQUANTTOTEXT    := TRIM(TO_CHAR(NDOCQUANT, '999999999999990.000'));
            SRESTDOCQUANT   := TRIM(TO_CHAR(NRESTDOCQUANT, '000'));
            if TRUNC(NDOCQUANT) = 0 then
                SQUANTTOTEXT := SQUANTTOTEXT || ' ( ноль целых ';
            else
                if SUBSTR(SDOCQUANT, LENGTH(SDOCQUANT) - 4) = ' один' then
                    SQUANTTOTEXT := SQUANTTOTEXT
                                    || ' ( '
                                    || SUBSTR(SDOCQUANT, 1, LENGTH(SDOCQUANT) - 5)
                                    || ' одна целая ';

                else
                    if TRUNC(NDOCQUANT) = 1 then
                        SQUANTTOTEXT := SQUANTTOTEXT
                                        || ' ( '
                                        || ' одна целая ';
                    else
                        SQUANTTOTEXT := SQUANTTOTEXT
                                        || ' ( '
                                        || SDOCQUANT
                                        || ' целых ';
                    end if;
                end if;
            end if;

            if NRESTDOCQUANT = 0 then
                SQUANTTOTEXT := SQUANTTOTEXT || ' ) ';
            else
                if SUBSTR(SRESTDOCQUANT, 2, 2) = '00' then
                    SQUANTTOTEXT := SQUANTTOTEXT
                                    || SUBSTR(SRESTDOCQUANT, 1, 1)
                                    || ' десятых )';
                else
                    if SUBSTR(SRESTDOCQUANT, 3, 1) = '0' then
                        SQUANTTOTEXT := SQUANTTOTEXT
                                        || LTRIM(SUBSTR(SRESTDOCQUANT, 1, 2), 0)
                                        || ' сотых )';

                    else
                        SQUANTTOTEXT := SQUANTTOTEXT
                                        || LTRIM(SRESTDOCQUANT, 0)
                                        || ' тысячных )';
                    end if;
                end if;
            end if;

            PRSG_EXCEL.CELL_VALUE_WRITE(QUANTCELL, 0, IDET_IDX, SQUANTTOTEXT);
        end loop;
    -- удаление образца

        PRSG_EXCEL.LINE_DELETE(LINE_STR);
    end loop;
  -- Удаление листа - шаблона

    PRSG_EXCEL.SHEET_DELETE(TEMPL_SHEET_NAME);
  -- очистить список
    P_SELECTLIST_CLEAR(NIDENT);
end UDO_P_PA_INTDOCS_PROX;
