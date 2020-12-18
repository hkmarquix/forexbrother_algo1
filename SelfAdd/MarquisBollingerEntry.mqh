#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"

class MarquisBollingerEntry : public BaseSignal {
    private:

        double uval;
        double mval;
        double lval;

        double uval1;
        double mval1;
        double lval1;

        double cprice;

        double ihigh1;
        double ihigh0;
        double ilow1;
        double ilow0;

        double ma0;
        double ma1;
           
    public:
        int takeprofit_pips;
        int strongsignal;

    MarquisBollingerEntry() {
        takeprofit_pips = 80;

        initHelper();
    }

    void initHelper() {
        signalname = "mbb";
        signalid = marquisbandentry;
    }

    ~MarquisBollingerEntry() {
        
    }

    void Refresh()
    {
        signal = -1;

        cprice = iClose(symbol, period, 0);

        uval = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
        mval = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_MAIN, 0);
        lval = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
                
        uval1 = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
        mval1 = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_MAIN, 1);
        lval1 = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);

        double ima0 = iMA(symbol, period, 200, 0, MODE_SMA, PRICE_CLOSE, 0);
        double ima1 = iMA(symbol, period, 200, 0, MODE_SMA, PRICE_CLOSE, 1);





        if (isMouthOpen())
        {
            signal = strongsignal;
            signalvaliduntil = TimeCurrent() + 10 * 60;
            return;
        }
        if (uval > uval1 && lval < lval1)
            return;
        /*
        ihigh1 = iHigh(symbol, period, 1);
        ihigh0 = iHigh(symbol, period, 0);
        ilow1 = iLow(symbol, period, 1);
        ilow0 = iLow(symbol, period, 0);
        
        if (ihigh1 > uval1 && ihigh0 > uval && cprice > uval
            && ima0 < ima1)
        {
            signal = OP_SELL;
        }
        if (ilow1 < lval1 && ilow0 < lval && cprice < lval
            && ima0 > ima1)
        {
            signal = OP_BUY;
        }
        */
        signalvaliduntil = TimeCurrent() + 10 * 60;
    }

    bool isMouthOpen()
    {
        strongsignal = -1;
        double diffu = (uval - uval1) * of_getcurrencrymultipier(symbol);
        double diffl = (lval1 - lval) * of_getcurrencrymultipier(symbol);

        if (uval > uval1 && lval < lval1
            && diffu > 60 && diffl > 60)
        {
            if (cprice > mval)
                strongsignal = OP_BUY;
            if (cprice < mval)
                strongsignal = OP_SELL;
            return true;
        }
        return false;
    }

    void RefreshCloseSignal(int actiontype, double entryprice)
    {
        closesignal = -1;

        double diff = 0;
        if (actiontype == OP_BUY)
            diff = cprice - entryprice;
        if (actiontype == OP_SELL)
            diff = entryprice - cprice;

        Refresh();

        double maend = iMA(symbol, period, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
        double maend1 = iMA(symbol, period, 5, 0, MODE_EMA, PRICE_CLOSE, 1);
        double mastart = iMA(symbol, period, 5, 0, MODE_EMA, PRICE_CLOSE, 1);//windowToCheck - 1);

        double iatr = iATR(symbol, period, 14, 0);

        double maslope = (maend - mastart) / 2;

        if (actiontype == OP_BUY && maslope < -2) //checkHighestI == windowToCheck - 1)
        {
            return;
        }
        if (actiontype == OP_SELL && maslope > 2) // checkLowestI == windowToCheck -1)
        {
            return;
        }
        maend = iMA(symbol, period, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
        maend1 = iMA(symbol, period, 5, 0, MODE_EMA, PRICE_CLOSE, 1);
        mastart = iMA(symbol, period, 5, 0, MODE_EMA, PRICE_CLOSE, 1);//windowToCheck - 1);
        //iatr = iATR(symbol, period, 14, 0);



        if (cprice > maend + iatr * 0.15 && (maend - mastart) < 1)
        {
            closesignal = 1;
            return;
        }
        else if (cprice < maend - iatr * 0.15 && (maend - mastart) > -1)
        {
            closesignal = 1;
            return;
        }


    }

};