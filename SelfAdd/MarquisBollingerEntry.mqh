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
        if (TimeCurrent() < signalvaliduntil)
            return;
        //if (TimeMinute(TimeCurrent()) % 15 > 0)
        //    return;

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
            if (strongsignal == OP_BUY && (ima0 - ima1) * of_getcurrencrymultipier(symbol) > -2)
                signal = strongsignal;
            if (strongsignal == OP_SELL && (ima0 - ima1) * of_getcurrencrymultipier(symbol) < 2)
                signal = strongsignal;
            
        }

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
        signalvaliduntil = TimeCurrent() + 5 * 60;
    }

    bool isMouthOpen()
    {
        strongsignal = -1;
        double diffu = (uval - uval1) * of_getcurrencrymultipier(symbol);
        double diffl = (lval1 - lval) * of_getcurrencrymultipier(symbol);

        double vol = iVolume(symbol, period, 1);
        double vol2 = iVolume(symbol, period, 2);

        double mfi = iMFI(symbol, period, 14, 0);
        double mfi1 = iMFI(symbol, period, 14, 1);
        

        if (uval > uval1 && lval < lval1
            && diffu > 40 && diffl > 40 && vol > vol2 && mfi > mfi1)
        {
            Print("UVal: " + uval + " uval1: " + uval1 + " lval: " + lval + " lval1: " + lval1 + " vol: " + vol);
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


        if (TimeCurrent() < signalvaliduntil)
            return;


        double diff = 0;
        if (actiontype == OP_BUY)
            diff = cprice - entryprice;
        if (actiontype == OP_SELL)
            diff = entryprice - cprice;

        Refresh();

        double ihigh0 = iHigh(symbol, period, 0);
        double ilow0 = iLow(symbol, period, 0);

        if (signal == actiontype)
            return;

        if (actiontype == OP_BUY && ihigh0 < uval)
        {
            closesignal = 1;
        }
        if (actiontype == OP_SELL && ilow0 > lval)
            closesignal = 1;

    }

};