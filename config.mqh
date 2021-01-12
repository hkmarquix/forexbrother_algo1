
double lotincrease_step = 0.01;//0.01;

double initlots = 0.04;//0.04;
double initlotstep = 0.04;//0.04;
double recoverPips = 100; // default val
double zcrecoverPips = 450;  // default val
double targetProfitForEachOrder = 3;// 0.4;  // zone cap profit per order

double martingaletype = 1; // 1 -> step method; 2 -> factor method
double martingalefactor = 2;
double martingaletakeprofitpips = 10;
bool boundMartingaleLotsizenotsmallerthanLastOrder = false;

int maxrecoverypair = 5;
int maxopenedpair = 6;

string EA_NAME = "fba1";

int use_mcomplex = 0;
int use_cgold = 1;
int use_michimoku = 0;
int use_marquisbandentry = 0;
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
string curlist[] =  { "XAUUSD" };//, "EURJPY", "USDJPY", "USDCHF", "GBPAUD" };
int curperiod[] = { PERIOD_M1, PERIOD_M15, PERIOD_M15, PERIOD_M15, PERIOD_M15 };
int curtrademode[] = { 1, 2, 2, 2, 2 };
double currecover[] = { 120, 120, 120, 120, 120 };
double curzone[] = { 100, 500, 500, 500, 500 };
