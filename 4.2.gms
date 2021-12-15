scalar BigM /1000/;
SET
PD  'Products'  /A, B, C/
PC  'Processes' /I, II, III/
;
Parameters
SUPPLY(PD)      'Maximum Raw Product Supply'
/   A   16
    B   inf
    C   0 /
COST_SUPPLY(PD) 'Raw Product Cost'
/   A   0.5
    B   0.95
    C   0 /
COST_V(PC)      'Process Variable Cost'
/   I   0.25
    II  0.4
    III 0.55 /
COST_F(PC)      'Process Fixed Cost'
/   I   1
    II  1.5
    III 2 /
DEMAND(PD)      'Maximum Product Demand'
/   A   0
    B   0
    C   15 /
B_PRICE(PD)     'Base Prices'
/   A   0
    B   0
    C   1.8 /
E_PRICE(PD)     'Excess Prices'
/   A   0
    B   0
    C   1.5 /
CUTOFF(PD)      'Demand Cutoff before excess'
/   A   0
    B   0
    C   10 /
D_PRICE(PD)     'Excess Prices Difference'
;
D_PRICE(PD) = B_PRICE(PD) - E_PRICE(PD);
Table
Input(PC,PD)
    A       B       C
I   1       0       0
II  0       1       0
III 0       1       0
;

Table
Output(PC,PD)
    A       B       C
I   0       0.9     0
II  0       0       0.82
III 0       0       0.95
;



Variables
Profit
;

Positive Variables
UTIL(PC)        'Process Utilization'
BOUGHT(PD)      'Products Bought'
PRODUCED(PD)    'Products Produced'
EXCESS(PD)      'Excess Products'
INCOME          'Total Income'
EXPENSE         'Total Expense'
;
Binary Variables
IS_ACTIVE(PC)   'Process is active'
IS_EXCESS(PD)   'Product is excess'
;
Equations
OBJFUN          'Objective function'
BAL_PD(PD)      'Product Balance'
Supply_lim(PD)  'Supply Limit'
Demand_lim(PD)  'Demand Limit'
Active_c_1(PC)  'Active Check 1'
Active_c_2(PC)  'Active Check 2'
Excess_c_1(PD)  'Excess Check 1'
Excess_c_2(PD)  'Excess Check 2'
Excess_c_3(PD)  'Excess Check 3'
Excess_c_4(PD)  'Excess Check 4'
INCOME_EQ       'Income Equation'
EXPENSE_EQ      'Expense Equation'
;
OBJFUN ..           Profit =e= INCOME - EXPENSE;
INCOME_EQ ..        INCOME =e= SUM(PD,PRODUCED(PD)*B_PRICE(PD)) - SUM(PD,EXCESS(PD)*D_PRICE(PD));
EXPENSE_EQ ..       EXPENSE =e= SUM(PC,UTIL(PC)*COST_V(PC)) + SUM(PC, IS_ACTIVE(PC)*COST_F(PC)) + SUM(PD, BOUGHT(PD)*COST_SUPPLY(PD));
BAL_PD(PD) ..       SUM(PC, Output(PC, PD) * UTIL(PC)) + BOUGHT(PD) =e= SUM(PC, Input(PC, PD) * UTIL(PC)) + PRODUCED(PD);
Supply_lim(PD) ..   BOUGHT(PD) =l= SUPPLY(PD);
Demand_lim(PD) ..   PRODUCED(PD) =l= DEMAND(PD);
Active_c_1(PC) ..   BigM*IS_ACTIVE(PC) =g= UTIL(PC);
Active_c_2(PC) ..   BigM*(1-IS_ACTIVE(PC)) =g= eps - UTIL(PC);
Excess_c_1(PD) ..   EXCESS(PD) =g= 0;
Excess_c_2(PD) ..   EXCESS(PD) =g= PRODUCED(PD) - CUTOFF(PD);
Excess_c_3(PD) ..   EXCESS(PD) =l= BigM*(1-IS_EXCESS(PD));
Excess_c_4(PD) ..   EXCESS(PD) =l= PRODUCED(PD) - CUTOFF(PD) + BigM*(IS_EXCESS(PD));
Model Chemical /all/;
Solve Chemical Using MIP Maximising Profit;
