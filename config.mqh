
double lotincrease_step = 0;//0.01;

double initlots = 0.01;
double initlotstep = 0.01;
double recoverPips = 100;
double zcrecoverPips = 450;
double targetProfitForEachOrder = 1;

int maxrecoverypair = 5;
int maxopenedpair = 6;

int usebasicentry = 1;

int defaulttrademode = 2;
// 1 -> martingale , 2 -> zone cap recovery, 4 -> gold

int maxCommentLevel = 20;
string curlist[] =  { "EURUSD", "EURJPY", "USDJPY", "USDCHF", "GBPAUD" };
int curperiod[] = { PERIOD_M15, PERIOD_M15, PERIOD_M15, PERIOD_M15, PERIOD_M15 };
double curzone[] = { 450, 450, 450, 450, 450 };
