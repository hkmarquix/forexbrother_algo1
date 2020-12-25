#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"

class CGoldSignal : public BaseSignal {
    private:
        double sk0;
        double sd0;
        double sk1;
        double sd1;

        double macdm;
        double macds;
        double macdm1;
        double macds1;

        double sk_arr[];
        double sd_arr[];
           
    public:
        int takeprofit_pips;
        datetime signalValidUntil;

        int openedtrade;

    CGoldSignal() {
        openedtrade = 0;

        takeprofit_pips = 80;
        initHelper();
    }

    void initHelper() {
        period = PERIOD_M15;
        signalname = "cg";
        signalid = cgold;
    }

    ~CGoldSignal() {
        
    }

    void Refresh()
    {
        //if (TimeCurrent() < signalvaliduntil)
        //    return;
        //if (TimeMinute(TimeCurrent()) % 15 > 0)
        //    return;
        signal = -1;

        macdm = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        macds = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);

        macdm1 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        macds1 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);

        sk0 = iStochastic(symbol, period, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
        sd0 = iStochastic(symbol, period, 14, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
        sk1 = iStochastic(symbol, period, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
        sd1 = iStochastic(symbol, period, 14, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);

        //if (openedtrade > 9)
        //    return;


        if (sk0 > sk1 && sk0 < 40 && sk0 > sd0
        && !(macdm * 0.9 < macds || macdm < macdm1
        && checkHigherTimeFrameForTradeSignal(OP_BUY, period))
        )
        {
            int ii = findIncreaseDecreasePowerWithStochastic(OP_BUY, TimeCurrent() - 100 * 60);
            //openedtrade++;
            if (ii > 0)
                signal = OP_BUY;

        }
        if (sk0 < sk1 && sk0 > 60 && sk0 < sd0
        && !(macdm * 0.9 > macds || macdm > macdm1
        && checkHigherTimeFrameForTradeSignal(OP_SELL, period))
        )
        {
            int ii = findIncreaseDecreasePowerWithStochastic(OP_SELL, TimeCurrent() - 100 * 60);
            //openedtrade++;
            if (ii > 0)
                signal = OP_SELL;
        }
        signalValidUntil = TimeCurrent() + 60;


    }

    bool checkHigherTimeFrameForTradeSignal(int ordertype, int _period)
    {   
        bool checkperiod = 0;
        if (_period == PERIOD_M1)
        {
            checkperiod = PERIOD_M15;
            
        }
        else
        {
            checkperiod = PERIOD_H1;
        }

        double hsk0 = iStochastic(symbol, checkperiod, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
        double hsd0 = iStochastic(symbol, checkperiod, 14, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
        double hsk1 = iStochastic(symbol, checkperiod, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
        double hsd1 = iStochastic(symbol, checkperiod, 14, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);

        double hmacdm = iMACD(symbol, checkperiod, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        double hmacds = iMACD(symbol, checkperiod, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);

        if (hsk0 < hsd0 && hsk0 < 85 && macdm < macds
            && ordertype == OP_SELL)
        {
            return true;
        }
        if (hsk0 < hsd0 && hsk0 > 15 && macdm > macds
            && ordertype == OP_BUY)
        {
            return true;
        }
        return false;
    }

    void RefreshCloseSignal(int actiontype, double entryprice, datetime orderopentime)
    {
        recovermethod = -1;
        closesignal = -1;
        if (TimeCurrent() < signalvaliduntil)
            return;

        Refresh();

        if (signal == actiontype)
            return;

        int totalorder = tf_countAllOrders(symbol, magicNumber);

        int tperiod = PERIOD_M15;
        
        double diff = 0;
        if (actiontype == OP_BUY)
            diff = (MarketInfo(symbol, MODE_BID) - entryprice) * tf_getCurrencryMultipier(symbol);
        if (actiontype == OP_SELL)
            diff = (entryprice - MarketInfo(symbol, MODE_ASK)) * tf_getCurrencryMultipier(symbol);

        double hmacdm = iMACD(symbol, tperiod, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        double hmacds = iMACD(symbol, tperiod, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);

        double hmacdm1 = iMACD(symbol, tperiod, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double hmacds1 = iMACD(symbol, tperiod, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);

        double hsk0 = iStochastic(symbol, tperiod, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
        double hsd0 = iStochastic(symbol, tperiod, 14, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
        double hsk1 = iStochastic(symbol, tperiod, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
        double hsd1 = iStochastic(symbol, tperiod, 14, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);

        if (diff > 0)
        {
            if (actiontype == OP_BUY && sk0 < sk1 && sk0 < sd0)
            {
                closesignal = 1;
                return;
            }
            if (actiontype == OP_SELL && sk0 > sk1 && sk0 > sd0)
            {
                closesignal = 1;
                return;
            }
        }
        else
        {
            if (actiontype == OP_BUY
                    && hmacds * 0.7 - hmacdm > 0 && hmacdm < hmacdm1)
                {
                    closesignal = 1;
                    return;
                }
                if (actiontype == OP_SELL
                    && hmacdm * 0.7 - hmacds > 0 && hmacdm > hmacdm1)
                {
                    closesignal = 1;
                    return;
                }
        }
        
/*
        if (diff * -1 > curzone) { 

            //int rindex = findIncreaseDecreasePowerWithStochastic(actiontype, orderopentime);

            //if (rindex > 0)
            //{
                if (actiontype == OP_BUY
                    && macds * 0.7 - macdm > 0 && macdm < macdm1 && macds < 0)
                {
                    closesignal = 1;
                    return;
                }
                if (actiontype == OP_SELL
                    && macdm * 0.7 - macds > 0 && macdm > macdm1 && macds > 0)
                {
                    closesignal = 1;
                    return;
                }

                //Print("Martingale ... GO  ");
                //recovermethod = martingale;
                //closesignal = 2;
                //return;
            //}

        }
*/

    }

    int keepHighOrLowForAPeriodOfTime(int actiontype)
    {
        bool breakhigh = false;
        bool breaklow = false;
        for (int i = 0; i < 10; i++)
        {
            
            if (actiontype == OP_BUY)
            {
                if (sk_arr[i] < 85)
                    breakhigh = true;
            }
            if (actiontype == OP_SELL)
            {
                if (sk_arr[i] > 15)
                    breaklow = true;
            }
        }

        if (actiontype == OP_BUY && breakhigh)
            return 1;
        if (actiontype == OP_SELL && breaklow)
            return 1;

        return 0;
    }

    int findIncreaseDecreasePowerWithStochastic(int actiontype, datetime orderopentime)
    {
        int windowTocheck = 60;
    


        ArrayResize(sk_arr, windowTocheck);
        ArrayResize(sd_arr, windowTocheck);

        string res = "";
        string res1 = "";

        for (int i = 0; i < windowTocheck; i++)
        {
            double tsk0 = iStochastic(symbol, period, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            double tsd0 = iStochastic(symbol, period, 14, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i);

            sk_arr[i] = tsk0;
            sd_arr[i] = tsd0;
            res += DoubleToString(tsk0) + ", ";
            res1 += DoubleToString(tsd0) + ", ";
        }
        Print(res);
        Print(res1);

        int fstlowest = -1;
        double fstlowest_val  = 999;
        int seclowest = -1;
        double seclowest_val = 999;
        int fsthighest = -1;
        double fsthighest_val = -999;
        int sechighest = -1;
        double sechighest_val = -999;

        bool startlowloop = false;
        bool firstlowfinish = false;
        bool startseclowloop = false;
        bool seclowfinish = false;

        bool starthighloop = false;
        bool firsthighfinish = false;
        bool startsechighloop = false;
        bool sechighfinish = false;


        for (int i = 0; i < windowTocheck; i++)
        {
            datetime ntime = iTime(symbol, period, i);
            if (ntime <= orderopentime) {
                Print(orderopentime + " " + ntime);
                break;
            }

            if (!startlowloop)
            {
                if (sk_arr[i] > sd_arr[i])
                {
                    startlowloop = true;
                }
            }
            else if (!firstlowfinish)
            {
                if (sk_arr[i] < sd_arr[i] && sk_arr[i] < fstlowest_val && sk_arr[i] < 40)
                {
                    fstlowest_val = sk_arr[i];
                    fstlowest = i;
                }
                if (sk_arr[i] > sd_arr[i] && sk_arr[i] > 50 && fstlowest_val < 999)
                {
                    firstlowfinish = true;
                }
            }
            else if (firstlowfinish && !startseclowloop)
            {
                if (sk_arr[i] > sd_arr[i])
                {
                    startseclowloop = true;
                }
            }
            else if (firstlowfinish && !seclowfinish)
            {
                 if (sk_arr[i] < sd_arr[i] && sk_arr[i] < seclowest_val && sk_arr[i] < 40)
                {
                    seclowest_val = sk_arr[i];
                    seclowest = i;
                }
                if (sk_arr[i] > sd_arr[i] && sk_arr[i] > 50 && seclowest_val < 999)
                {
                    seclowfinish = true;
                }
            
            }

            if (!starthighloop)
            {
                if (sk_arr[i] < sd_arr[i])
                {
                    starthighloop = true;
                }
            }
            else if (!firsthighfinish)
            {
                if (sk_arr[i] > sd_arr[i] && sk_arr[i] > fsthighest_val && sk_arr[i] > 60)
                {
                    fsthighest_val = sk_arr[i];
                    fsthighest = i;
                }
                if (sk_arr[i] < sd_arr[i] && sk_arr[i] < 50 && fsthighest_val > -999)
                {
                    firsthighfinish = true;
                }
            }
            else if (firsthighfinish && !startsechighloop)
            {
                if (sk_arr[i] < sd_arr[i])
                {
                    startsechighloop = true;
                }
            }
            else if (firsthighfinish && !sechighfinish)
            {
                if (sk_arr[i] > sd_arr[i] && sk_arr[i] > sechighest_val && sk_arr[i] > 60)
                {
                    sechighest_val = sk_arr[i];
                    sechighest = i;
                }
                if (sk_arr[i] < sd_arr[i] && sk_arr[i] < 50 && sechighest_val > -999)
                {
                    sechighfinish = true;
                }
            
            }
        }

        Print("1st low: " + fstlowest_val + "(" + fstlowest + ") 2nd low: " + seclowest_val + "(" + seclowest + ")");
        Print("1st high: " + fsthighest_val + "(" + fsthighest + ") 2nd high: " + sechighest_val + "(" + sechighest + ")");

        int rsindex = 0;

        if (fsthighest == -1 || fstlowest == -1 || sechighest == -1 || seclowest == -1)
            return 0;

        if (actiontype == OP_BUY)
        {
            if (fstlowest_val > seclowest_val)
                rsindex++;
            double cprice1 = iClose(symbol, period, fstlowest);
            double cprice2 = iClose(symbol, period, seclowest);
            if (cprice1 > cprice2)
                rsindex++;
            if (fstlowest_val < 5)
                rsindex++;
        }
        else if (actiontype == OP_SELL)
        {
            if (fsthighest_val > 95)
                rsindex++;
            if (fsthighest_val < sechighest_val)
                rsindex++;
            double cprice1 = iClose(symbol, period, fsthighest);
            double cprice2 = iClose(symbol, period, sechighest);
            if (cprice1 < cprice2)
                rsindex++;
        }

        Print("R Index: "+ rsindex);

        return rsindex;
    }

};