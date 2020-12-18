#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict


class BaseSignal {
    private:
          
    public:
        int signalid;
        int signal;
        int closesignal;
        int recovermethod;

        double takeprofit;
        double stoploss;
        
        string symbol;
        int period;
        datetime signalvaliduntil;
        datetime closesignalvaliduntil;

        string signalname;

    BaseSignal() {
        signalname = "";
        signalid = -1;
        signal = -1;
        closesignal = -1;
        recovermethod = -1;

        symbol = "EURUSD";
        period = PERIOD_M15;

        takeprofit = 0;
        stoploss = 0;

        signalvaliduntil = TimeCurrent();
        closesignalvaliduntil = TimeCurrent();
    }

    ~BaseSignal() {
        
    }

    void Refresh()
    {
        //Print("Base signal refresh");
    }

    void RefreshCloseSignal(int actiontype, double entryprice)
    {

    }

};