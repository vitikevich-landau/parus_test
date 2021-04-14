create or replace view UDO_V_PA_LATECOMERS as
    select distinct
        F.ID,
        F.FULLNAME,
        L.M,
        L.Y,
        D1.VAL    as D1,
        D2.VAL    as D2,
        D3.VAL    as D3,
        D4.VAL    as D4,
        D5.VAL    as D5,
        D6.VAL    as D6,
        D7.VAL    as D7,
        D8.VAL    as D8,
        D9.VAL    as D9,
        D10.VAL   as D10,
        D11.VAL   as D11,
        D12.VAL   as D12,
        D13.VAL   as D13,
        D14.VAL   as D14,
        D15.VAL   as D15,
        D16.VAL   as D16,
        D17.VAL   as D17,
        D18.VAL   as D18,
        D19.VAL   as D19,
        D20.VAL   as D20,
        D21.VAL   as D21,
        D22.VAL   as D22,
        D23.VAL   as D23,
        D24.VAL   as D24,
        D25.VAL   as D25,
        D26.VAL   as D26,
        D27.VAL   as D27,
        D28.VAL   as D28,
        D29.VAL   as D29,
        D30.VAL   as D30,
        D31.VAL   as D31
    from
        UDO_T_PA_PARUS_EMPLOYEES   F
        left join UDO_T_PA_LATECOMERS        L
        on L.FULLNAME = F.FULLNAME
        left join UDO_T_PA_LATECOMERS        D1
        on D1.FULLNAME = F.FULLNAME
           and D1.D = '1'
        left join UDO_T_PA_LATECOMERS        D2
        on D2.FULLNAME = F.FULLNAME
           and D2.D = '2'
        left join UDO_T_PA_LATECOMERS        D3
        on D3.FULLNAME = F.FULLNAME
           and D3.D = '3'
        left join UDO_T_PA_LATECOMERS        D4
        on D4.FULLNAME = F.FULLNAME
           and D4.D = '4'
        left join UDO_T_PA_LATECOMERS        D5
        on D5.FULLNAME = F.FULLNAME
           and D5.D = '5'
        left join UDO_T_PA_LATECOMERS        D6
        on D6.FULLNAME = F.FULLNAME
           and D6.D = '6'
        left join UDO_T_PA_LATECOMERS        D7
        on D7.FULLNAME = F.FULLNAME
           and D7.D = '7'
        left join UDO_T_PA_LATECOMERS        D8
        on D8.FULLNAME = F.FULLNAME
           and D8.D = '8'
        left join UDO_T_PA_LATECOMERS        D9
        on D9.FULLNAME = F.FULLNAME
           and D9.D = '9'
        left join UDO_T_PA_LATECOMERS        D10
        on D10.FULLNAME = F.FULLNAME
           and D10.D = '10'
        left join UDO_T_PA_LATECOMERS        D11
        on D11.FULLNAME = F.FULLNAME
           and D11.D = '11'
        left join UDO_T_PA_LATECOMERS        D12
        on D12.FULLNAME = F.FULLNAME
           and D12.D = '12'
        left join UDO_T_PA_LATECOMERS        D13
        on D13.FULLNAME = F.FULLNAME
           and D13.D = '13'
        left join UDO_T_PA_LATECOMERS        D14
        on D14.FULLNAME = F.FULLNAME
           and D14.D = '14'
        left join UDO_T_PA_LATECOMERS        D15
        on D15.FULLNAME = F.FULLNAME
           and D15.D = '15'
        left join UDO_T_PA_LATECOMERS        D16
        on D16.FULLNAME = F.FULLNAME
           and D16.D = '16'
        left join UDO_T_PA_LATECOMERS        D17
        on D17.FULLNAME = F.FULLNAME
           and D17.D = '17'
        left join UDO_T_PA_LATECOMERS        D18
        on D18.FULLNAME = F.FULLNAME
           and D18.D = '18'
        left join UDO_T_PA_LATECOMERS        D19
        on D19.FULLNAME = F.FULLNAME
           and D19.D = '19'
        left join UDO_T_PA_LATECOMERS        D20
        on D20.FULLNAME = F.FULLNAME
           and D20.D = '20'
        left join UDO_T_PA_LATECOMERS        D21
        on D21.FULLNAME = F.FULLNAME
           and D11.D = '21'
        left join UDO_T_PA_LATECOMERS        D22
        on D22.FULLNAME = F.FULLNAME
           and D22.D = '22'
        left join UDO_T_PA_LATECOMERS        D23
        on D23.FULLNAME = F.FULLNAME
           and D23.D = '23'
        left join UDO_T_PA_LATECOMERS        D24
        on D24.FULLNAME = F.FULLNAME
           and D24.D = '24'
        left join UDO_T_PA_LATECOMERS        D25
        on D25.FULLNAME = F.FULLNAME
           and D25.D = '25'
        left join UDO_T_PA_LATECOMERS        D26
        on D26.FULLNAME = F.FULLNAME
           and D26.D = '26'
        left join UDO_T_PA_LATECOMERS        D27
        on D27.FULLNAME = F.FULLNAME
           and D27.D = '27'
        left join UDO_T_PA_LATECOMERS        D28
        on D28.FULLNAME = F.FULLNAME
           and D28.D = '28'
        left join UDO_T_PA_LATECOMERS        D29
        on D29.FULLNAME = F.FULLNAME
           and D29.D = '29'
        left join UDO_T_PA_LATECOMERS        D30
        on D30.FULLNAME = F.FULLNAME
           and D30.D = '30'
        left join UDO_T_PA_LATECOMERS        D31
        on D31.FULLNAME = F.FULLNAME
           and D31.D = '31';