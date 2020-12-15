
double lotincrease_step = 0.01;//0.01;

double initlots = 0.01;
double initlotstep = 0.01;
double recoverPips = 100;
double zcrecoverPips = 450;
double targetProfitForEachOrder = 1;

int maxrecoverypair = 5;
int maxopenedpair = 6;

string EA_NAME = "fba1";


int use_marquisbasicstochasticmethod = 1;
int usebasicentry = 0;



int defaulttrademode = 2;
int currenttrademode = 2;
/* 

    martingale = 1,
    zonecap = 2,
    simplestoploss = 3,
    signalclosesignal = 4
    */

int maxCommentLevel = 20;
string curlist[] =  { "XAUUSD" };//, "EURJPY", "USDJPY", "USDCHF", "GBPAUD" };
int curperiod[] = { PERIOD_M1, PERIOD_M15, PERIOD_M15, PERIOD_M15, PERIOD_M15 };
int curtrademode[] = { 1, 2, 2, 2, 2 };
double curzone[] = { 120, 450, 450, 450, 450 };
