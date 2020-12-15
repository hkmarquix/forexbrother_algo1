#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BaseSignal.mqh"

class BasicEntry : public BaseSignal {
    private:
           
    public:

    BasicEntry() {

        initHelper();
    }

    void initHelper() {
        signalname = "BasicEntry";
        signalid = basicentryid;
    }

    ~BasicEntry() {
        
    }

    void Refresh()
    {
        //Print("Checking basic entry");
        double ema80 = iMA(symbol, period, 80, 0, MODE_EMA, PRICE_CLOSE, 0);
        double ilow = iLow(symbol, period, 0);
        double ihigh = iHigh(symbol, period, 0);

        signal = -1;
        if (ilow > ema80)
            signal = OP_BUY;
        if (ihigh < ema80)
            signal = OP_SELL;
        signalvaliduntil = TimeCurrent() + 10 * 60;
    }

    void RefreshCloseSignal(int actiontype, double entryprice)
    {
        closesignal = -1;
        Refresh();
        if (signal != actiontype)
            closesignal = 1;
        closesignalvaliduntil = TimeCurrent() + 10 * 60;
    }

};