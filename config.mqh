
double lotincrease_step = 0;//0.01;

double initlots = 0.01;
double initlotstep = 0.01;
double recoverPips = 100;
double zcrecoverPips = 450;
double targetProfitForEachOrder = 1;

int maxrecoverypair = 5;
int maxopenedpair = 6;

string EA_NAME = "fba1";

enum signalidlist {
    basicentryid=1012,

};

int usebasicentry = 1;

enum trademodelist {
    martingale = 1,
    zonecap = 2,
    simplestoploss = 3,
    signalclosesignal = 4
};

int defaulttrademode = 2;
int currenttrademode = 2;
// 1 -> martingale , 2 -> zone cap recovery, 4 -> gold

int maxCommentLevel = 20;
string curlist[] =  { "GBPUSD" };//, "EURJPY", "USDJPY", "USDCHF", "GBPAUD" };
int curperiod[] = { PERIOD_M15, PERIOD_M15, PERIOD_M15, PERIOD_M15, PERIOD_M15 };
int curtrademode[] = { 1, 2, 2, 2, 2 };
double curzone[] = { 450, 450, 450, 450, 450 };
