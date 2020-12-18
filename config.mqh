
double lotincrease_step = 0.02;//0.01;

double initlots = 0.08;//0.04;
double initlotstep = 0.08;//0.04;
double recoverPips = 100;
double zcrecoverPips = 450;
double targetProfitForEachOrder = 0.8;//0.4;

int maxrecoverypair = 5;
int maxopenedpair = 6;

string EA_NAME = "fba1";

int use_marquisbandentry = 1;
int use_marquisbasicstochasticmethod = 0;
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
string curlist[] =  { "EURUSD" };//, "EURJPY", "USDJPY", "USDCHF", "GBPAUD" };
int curperiod[] = { PERIOD_M15, PERIOD_M15, PERIOD_M15, PERIOD_M15, PERIOD_M15 };
int curtrademode[] = { 1, 2, 2, 2, 2 };
double currecover[] = { 120, 120, 120, 120, 120 };
double curzone[] = { 500, 500, 500, 500, 500 };