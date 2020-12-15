#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"

class MarquisBasicStochasticEntry : public BaseSignal {
    private:
           
    public:
        int takeprofit_pips;

    MarquisBasicStochasticEntry() {
        takeprofit_pips = 80;

        initHelper();
    }

    void initHelper() {
        signalname = "MBSE";
        signalid = marquisbasicentry;
    }

    ~MarquisBasicStochasticEntry() {
        
    }

    void Refresh()
    {
        signal = -1;
        period = PERIOD_M1;
        
        double sk0 = iStochastic(symbol, period, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
        double sd0 = iStochastic(symbol, period, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
        double sk1 = iStochastic(symbol, period, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
        //double sd1 = iStochastic(symbol, period, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);

        double macdm = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        double macds = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);

        double macdm1 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double macds1= iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);

         
        double ima0 = iMA(symbol, period, 200, 0, MODE_SMA, PRICE_CLOSE, 0);
        double ima1 = iMA(symbol, period, 200, 0, MODE_SMA, PRICE_CLOSE, 1);



        double iatr = iATR(symbol, period, 14, 0);
        double iadx = iADX(symbol, period, 14, PRICE_CLOSE, MODE_MAIN, 0);
        if (iatr < 1 || iadx < 20.1)
            return;

        if (sk0 > sk1 && macdm > macds && macdm > macdm1
            && ima0 > ima1
            )
        {
            signal = OP_BUY;
        }
        if (sk0 < sk1 && macdm < macds && macdm < macdm1
        && ima0 < ima1
            )
        {
            signal = OP_SELL;
        }

        signalvaliduntil = TimeCurrent() + 10 * 60;
    }

    void RefreshCloseSignal(int actiontype, double entryprice)
    {
        closesignal = -1;

        double diff = 0;
        if (actiontype == OP_BUY)
            diff = (MarketInfo(symbol, MODE_BID) - entryprice) * tf_getCurrencryMultipier(symbol);
        if (actiontype == OP_SELL)
            diff = (entryprice - MarketInfo(symbol, MODE_ASK)) * tf_getCurrencryMultipier(symbol);

        if (diff > takeprofit_pips) {
            closesignal = 1;
        }


    }

};