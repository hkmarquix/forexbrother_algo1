#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"

class MichimokuSignal : public BaseSignal {
    private:
        int TenKanSen;
        int KijunSen;
        int SenKouSpanB;


        double tenkan_sen;
        double kinjun_sen;
        double senkou_spanA;
        double senkou_spanB;

        double tenkan_sen1;
        double kinjun_sen1;
        double senkou_spanA1;
        double senkou_spanB1;

        double tenkan_sen2;
        double kinjun_sen2;
        double senkou_spanA2;
        double senkou_spanB2;

        double close0;
        double close1;

        double ilow0;
        double ilow1;
        double ihigh0;
        double ihigh1;

        double mfi0;
        double mfi1;

        bool insideTheCloud;
        bool enterUpCloud;
        bool enterLowCloud;
        bool chikouspanTouchTheCloud;

        double farawayindex;
        double pricecrossbeautifulindex;
           
    public:
        int takeprofit_pips;
        int strongsignal;
        int weaksignal;

    MichimokuSignal() {
        TenKanSen = 9;
        KijunSen = 26;
        SenKouSpanB = 52;

        takeprofit_pips = 80;
        initHelper();
    }

    void initHelper() {
        period = PERIOD_M15;
        signalname = "mchi";
        signalid = michimoku;
    }

    ~MichimokuSignal() {
        
    }

    void Refresh()
    {
        //if (TimeCurrent() < signalvaliduntil)
        //    return;
        //if (TimeMinute(TimeCurrent()) % 15 > 0)
        //    return;
        signal = -1;
        weaksignal = -1;
        strongsignal = -1;

        close0 = iClose(symbol, period, 0);
        close1 = iClose(symbol, period, 1);

        tenkan_sen   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_TENKANSEN,0);
        kinjun_sen   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_KIJUNSEN,0);
        senkou_spanA = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANA,0);
        senkou_spanB = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANB,0);

        tenkan_sen1   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_TENKANSEN,1);
        kinjun_sen1   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_KIJUNSEN,1);
        senkou_spanA1 = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANA,1);
        senkou_spanB1 = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANB,1);

        tenkan_sen2   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_TENKANSEN,2);
        kinjun_sen2   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_KIJUNSEN,2);
        senkou_spanA2 = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANA,2);
        senkou_spanB2 = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANB,2);

        ihigh0  = iHigh(symbol, period, 0);
        ilow0   = iLow(symbol, period, 0);
        ihigh1  = iHigh(symbol, period, 1);
        ilow1   = iLow(symbol, period, 1);

        mfi0 = iMFI(symbol, period, 14, 0);
        mfi1 = iMFI(symbol, period, 14, 1);

        checkInsideTheCloud();
        if (insideTheCloud)
        {
            //Print("Inside the cloud");
            return;
        }

        checkBuySellSignalOfTenKanKiJunCross();
        if (signal == -1 && strongsignal == -1)
            checkSpanASpanBCrossSignal();
        checkCrossCloudSignalStrongBeforeTenkanKinJunCross();

        signal = strongsignal;
        checkCloudFarAwayIndex();

        if (signal == -1)
            signal = weaksignal;
        signal = checkMacd(signal);

        if (pricecrossbeautifulindex > 0 && signal != -1) {
            Print("Price cross index: " + pricecrossbeautifulindex);
        }

        /*if (didOpenOrderAfterFirstLeaveCloud(signal))
        {
            signal = -1;
            weaksignal = -1;
            strongsignal = -1;
        }*/

    }

    int checkMacd(int actiontype)
    {
        double macdm = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        double macds = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
        double macdm1 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double macds1 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
        if (actiontype == OP_BUY && macdm > macdm1)
            return actiontype;
        if (actiontype == OP_SELL && macdm < macdm1)
            return actiontype;

        return -1;
    }

    int checkFirstLeaveCloud(int actiontype)
    {
        double t_close;
        double t_tenkan_sen;
        double t_kinjun_sen;
        double t_senkou_spanA;
        double t_senkou_spanB;
        bool firstLeaveCloud = false;
        for (int i = 0; i < 100; i++)
        {
            t_close = iClose(symbol, period, i);
        
            t_tenkan_sen   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_TENKANSEN,i);
            t_kinjun_sen   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_KIJUNSEN,i);
            t_senkou_spanA = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANA,i);
            t_senkou_spanB = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANB,i);

            if (actiontype == OP_BUY)
            {
                if (i == 0 && t_close < MathMax(t_senkou_spanA, t_senkou_spanB))
                {
                    return -1;
                }
                if (t_close < MathMax(t_senkou_spanA, t_senkou_spanB))
                {
                    return i;
                }
            }
            else if (actiontype == OP_SELL)
            {
                if (i == 0 && t_close > MathMax(t_senkou_spanA, t_senkou_spanB))
                {
                    return -1;
                }
                if (t_close > MathMax(t_senkou_spanA, t_senkou_spanB))
                {
                    return i;
                }
            }
        }
        return -1;
    }

    bool didOpenOrderAfterFirstLeaveCloud(int actiontype)
    {
        int ic = checkFirstLeaveCloud(actiontype);
        datetime opent = iTime(symbol, period, ic);
        if (of_selectlastclosedorder(symbol, magicNumber))
        {
            if (OrderOpenTime() > opent)
                return true;
        }
        return false;
    }

    void checkInsideTheCloud()
    {
        enterUpCloud = false;
        enterLowCloud = false;
        insideTheCloud = false;
        if (close0 < MathMax(senkou_spanA, senkou_spanB) && close0 > MathMin(senkou_spanA, senkou_spanB)
        && ihigh0 > MathMax(senkou_spanA, senkou_spanB)) {
            insideTheCloud = true;
            enterUpCloud = true;
            return;
        }
        if (close0 < MathMax(senkou_spanA, senkou_spanB) && close0 > MathMin(senkou_spanA, senkou_spanB)
            && ilow0 < MathMin(senkou_spanA, senkou_spanB)) {
            insideTheCloud = true;
            enterLowCloud = true;
            return;
        }
    }

    void checkBuySellSignalOfTenKanKiJunCross()
    {
        if (ilow0 > MathMax(senkou_spanA, senkou_spanB)
            && tenkan_sen > kinjun_sen && tenkan_sen1 < kinjun_sen1
             && tenkan_sen2 < kinjun_sen2)
        {
            Print("Tenkan > kinjun & low > span, buy now [S]");
            strongsignal = OP_BUY;
            weaksignal = OP_BUY;
        }
        else if (ihigh0 < MathMin(senkou_spanA, senkou_spanB)
            && tenkan_sen > kinjun_sen && tenkan_sen1 < kinjun_sen1
             && tenkan_sen2 < kinjun_sen2)
        {
            Print("Tenkan > kinjun & low > span, buy now [W]");
            weaksignal = OP_BUY;
        }
        else if (ihigh0 < MathMin(senkou_spanA, senkou_spanB)
            && tenkan_sen < kinjun_sen && tenkan_sen1 > kinjun_sen1
             && tenkan_sen2 > kinjun_sen2)
        {
            Print("Tenkan < kinjun & high < span, sell now [S]");
            strongsignal = OP_SELL;
            weaksignal = OP_SELL;
        }
        else if (ilow0 > MathMax(senkou_spanA, senkou_spanB)
            && tenkan_sen < kinjun_sen && tenkan_sen1 > kinjun_sen1
             && tenkan_sen2 > kinjun_sen2)
        {
            Print("Tenkan < kinjun & low > span, sell now [W]");
            weaksignal = OP_SELL;
        }
    }

    void checkSpanASpanBCrossSignal()
    {
        if (ilow0 > MathMax(senkou_spanA, senkou_spanB)
            && senkou_spanA > senkou_spanB && senkou_spanA1 < senkou_spanB1)
        {
            Print("span cross [b]");
            strongsignal = OP_BUY;
            weaksignal = OP_BUY;
        }
        if (ihigh0 < MathMin(senkou_spanA, senkou_spanB)
            && senkou_spanA < senkou_spanB && senkou_spanA1 > senkou_spanB1)
        {
            Print("span cross [s]");
            strongsignal = OP_SELL;
            weaksignal = OP_SELL;
        }
    }

    void checkCloudFarAwayIndex()
    {
        farawayindex = 0;
        if (signal == -1)
            return;

        int lcloud = checkFirstLeaveCloud(signal);
        if (lcloud > 10)
        {
            farawayindex = lcloud;
            signal = -1;
        }
    }

    void checkCrossCloudSignalStrongBeforeTenkanKinJunCross(int windowsBefore = 0)
    {
        pricecrossbeautifulindex = 0;

        double t_high0  = iHigh(symbol, period, windowsBefore + 0);
        double t_high1  = iHigh(symbol, period, windowsBefore + 1);
        double t_high2  = iHigh(symbol, period, windowsBefore + 2);

        double t_low0  = iLow(symbol, period, windowsBefore + 0);
        double t_low1  = iLow(symbol, period, windowsBefore + 1);
        double t_low2  = iLow(symbol, period, windowsBefore + 2);

        double t_tenkan_sen   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_TENKANSEN,windowsBefore + 0);
        double t_kinjun_sen   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_KIJUNSEN,windowsBefore + 0);
        double t_senkou_spanA = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANA,windowsBefore + 0);
        double t_senkou_spanB = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANB,windowsBefore + 0);

        double t_tenkan_sen1   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_TENKANSEN,windowsBefore + 1);
        double t_kinjun_sen1   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_KIJUNSEN,windowsBefore + 1);
        double t_senkou_spanA1 = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANA,windowsBefore + 1);
        double t_senkou_spanB1 = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANB,windowsBefore + 1);

        double t_tenkan_sen2   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_TENKANSEN,windowsBefore + 2);
        double t_kinjun_sen2   = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_KIJUNSEN,windowsBefore + 2);
        double t_senkou_spanA2 = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANA,windowsBefore + 2);
        double t_senkou_spanB2 = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANB,windowsBefore + 2);

        if (t_low0 > MathMax(senkou_spanA, senkou_spanB) && t_high2 < MathMin(senkou_spanA2, senkou_spanB2)
            && t_high1 > MathMax(senkou_spanA1, senkou_spanB1) && t_low1 <  MathMin(senkou_spanA1, senkou_spanB1))
        {
            pricecrossbeautifulindex += 5;
        }

        if (t_high0 < MathMin(senkou_spanA, senkou_spanB) && t_high2 > MathMax(senkou_spanA2, senkou_spanB2)
            && t_high1 > MathMax(senkou_spanA1, senkou_spanB1) && t_low1 <  MathMin(senkou_spanA1, senkou_spanB1))
        {
            pricecrossbeautifulindex += 5;
        }

        if (t_low0 > MathMax(senkou_spanA, senkou_spanB) && t_high2 < MathMin(senkou_spanA2, senkou_spanB2)
            )
        {
            pricecrossbeautifulindex += 5;
        }

        if (t_high0 < MathMin(senkou_spanA, senkou_spanB) && t_low2 > MathMax(senkou_spanA2, senkou_spanB2)
            )
        {
            pricecrossbeautifulindex += 5;
        }

        if (t_low0 > MathMax(senkou_spanA, senkou_spanB) && t_high2 < MathMax(senkou_spanA1, senkou_spanB1)
            )
        {
            pricecrossbeautifulindex += 5;
        }

        if (t_high0 < MathMin(senkou_spanA, senkou_spanB) && t_low2 > MathMin(senkou_spanA1, senkou_spanB1)
            )
        {
            pricecrossbeautifulindex += 5;
        }

        if (t_low0 > MathMax(senkou_spanA, senkou_spanB) && t_low1 < MathMax(senkou_spanA1, senkou_spanB1)
            )
        {
            pricecrossbeautifulindex += 5;
        }

        if (t_high0 < MathMin(senkou_spanA, senkou_spanB) && t_high1 > MathMin(senkou_spanA1, senkou_spanB1)
            )
        {
            pricecrossbeautifulindex += 5;
        }

    }

    void chikouSpanTouchLine()
    {
        chikouspanTouchTheCloud = false;

        double chikouspan0;
        double chikouspan1;
        int i = 26;
        //for (int i = 26; i < 30; i++)
        if (true)
        {
            chikouspan0 = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_CHIKOUSPAN,i);
            chikouspan1 = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_CHIKOUSPAN,i+1);
            double t_high0  = iHigh(symbol, period, i);
            double t_high1  = iHigh(symbol, period, i+1);
            double t_low0   = iLow(symbol, period, i);
            double t_low1   = iLow(symbol, period, i+1);

            double tsenkou_spanA = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANA,i);
            double tsenkou_spanB = iIchimoku(symbol,period,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANB,i);

            if (t_low0 > MathMax(tsenkou_spanA, tsenkou_spanB) && chikouspan0 < t_high0 
                && chikouspan1 > t_high1)
            {
                chikouspanTouchTheCloud = true;
                
            }
            if (t_high0 < MathMin(tsenkou_spanA, tsenkou_spanB) && chikouspan0 > t_low0
                && chikouspan1 < t_low1)
            {
                chikouspanTouchTheCloud = true;
                
            }
        }
    }

    bool tenkanCross(int actiontype)
    {
        if (actiontype == OP_BUY)
        {
            if (tenkan_sen < kinjun_sen)
                return true;
        }
        else if (actiontype == OP_SELL)
        {
            if (kinjun_sen > kinjun_sen)
                return true;
        }
        return false;
    }

    void RefreshCloseSignal(int actiontype, double entryprice)
    {
        closesignal = -1;
        if (TimeCurrent() < signalvaliduntil)
            return;

        Refresh();

        if (closeWithMovingAverage(actiontype))
        {
            Print("Closing with moving average");
            closesignal = 1;
            return;
        }

        if (tenkanCross(actiontype))
        {
            Print("TenkanKinJun Cross, close now");
            closesignal = 1;
            return;
        }

        chikouSpanTouchLine();
        if (weaksignal != -1 && actiontype != weaksignal)
        {
            Print("New signal is : " + weaksignal + " close now");
            closesignal = 1;
            return;
        }

        if (insideTheCloud && enterUpCloud && actiontype == OP_BUY) {
            Print("Inside the cloud, close now");
            closesignal = 1;
        }

        if (insideTheCloud && enterLowCloud && actiontype == OP_SELL) {
            Print("Inside the cloud, close now");
            closesignal = 1;
        }

        if (chikouspanTouchTheCloud)
        {
            //closesignal = 1;
            return;
        }
    }

    int closeWithMovingAverage(int actiontype)
    {
        double ma0 = iMA(symbol, period, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
        double ma1 = iMA(symbol, period, 20, 0, MODE_SMA, PRICE_CLOSE, 1);

        if (actiontype == OP_BUY)
        {
            if (ma0 <= ma1)
                return 1;
        }
        else if (actiontype == OP_SELL)
        {
            if (ma0 >= ma1)
                return 1;
        }
        return 0;
    }

};
