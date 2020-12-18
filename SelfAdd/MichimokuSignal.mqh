#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"

class MichimokuSignal : public BaseSignal {
    private:

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
        bool chikouspanTouchTheCloud;

        double farawayindex;
        double pricecrossbeautifulindex;
           
    public:
        int takeprofit_pips;
        int strongsignal;

    MichimokuSignal() {
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
        if (TimeCurrent() < signalvaliduntil)
            return;
        //if (TimeMinute(TimeCurrent()) % 15 > 0)
        //    return;

        signal = -1;
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
            return;
        }

        checkBuySellSignalOfTenKanKiJunCross();
        if (signal == -1 && strongsignal == -1)
            checkSpanASpanBCrossSignal();
        checkCloudFarAwayIndex();
        checkCrossCloudSignalStrongBeforeTenkanKinJunCross();

    }

    void checkInsideTheCloud()
    {
        insideTheCloud = false;
        if (ihigh0 < MathMin(senkou_spanA, senkou_spanB)) {
            insideTheCloud = true;
            return;
        }
        if (ilow0 > MathMax(senkou_spanA, senkou_spanB)) {
            insideTheCloud = true;
            return;
        }
    }

    void checkBuySellSignalOfTenKanKiJunCross()
    {
        if (ilow0 > MathMax(senkou_spanA, senkou_spanB)
            && tenkan_sen > kinjun_sen && tenkan_sen1 < kinjun_sen1)
        {
            strongsignal = OP_BUY;
        }
        else if (ihigh0 < MathMin(senkou_spanA, senkou_spanB)
            && tenkan_sen > kinjun_sen && tenkan_sen1 < kinjun_sen1)
        {
            signal = OP_BUY;
        }
        else if (ihigh0 < MathMin(senkou_spanA, senkou_spanB)
            && tenkan_sen < kinjun_sen && tenkan_sen1 > kinjun_sen1)
        {
            strongsignal = OP_SELL;
        }
        else if (ilow0 > MathMax(senkou_spanA, senkou_spanB)
            && tenkan_sen < kinjun_sen && tenkan_sen1 > kinjun_sen1)
        {
            signal = OP_SELL;
        }
    }

    void checkSpanASpanBCrossSignal()
    {
        if (ilow0 > MathMax(senkou_spanA, senkou_spanB)
            && senkou_spanA > senkou_spanB && senkou_spanA1 < senkou_spanB1)
        {
            strongsignal = OP_BUY;
        }
        if (ihigh0 < MathMin(senkou_spanA, senkou_spanB)
            && senkou_spanA < senkou_spanB && senkou_spanA1 > senkou_spanB1)
        {
            strongsignal = OP_SELL;
        }
    }

    void checkCloudFarAwayIndex()
    {
        farawayindex = 0;

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
                break;
            }
            if (t_high0 < MathMin(tsenkou_spanA, tsenkou_spanB) && chikouspan0 > t_low0
                && chikouspan1 < t_low1)
            {
                chikouspanTouchTheCloud = true;
                break;
            }
        }
    }

    void RefreshCloseSignal(int actiontype, double entryprice)
    {
        closesignal = -1;
        if (TimeCurrent() < signalvaliduntil)
            return;

        Refresh();
        chikouSpanTouchLine();
        if (signal != -1 && actiontype != signal)
        {
            closesignal = 1;
            return;
        }
        if (strongsignal != -1 && actiontype != signal)
        {
            closesignal = 1;
            return;
        }
        if (chikouspanTouchTheCloud)
        {
            closesignal = 1;
            return;
        }
    }

};