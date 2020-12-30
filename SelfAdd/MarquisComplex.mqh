#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"

class MarquisComplex : public BaseSignal {
    private:
        double sk_arr[];
        double sd_arr[];
        double macdm_arr[];
        double macds_arr[];
        double mfi_arr[];

        double drop_range;
        double rise_range;
           
    public:
        int takeprofit_pips;
        int windowSize;

        string trademessage;

    MarquisComplex() {
        takeprofit_pips = 80;
        windowSize = 100;
        initHelper();
    }

    void initHelper() {
        signalname = "mcom";
        signalid = mcomplex;
    }

    ~MarquisComplex() {
        
    }

    void Refresh()
    {
        trademessage = "";
        signal = -1;

        fillStochasticInArray(windowSize);
        fillMacdInArray(windowSize);
        fillMfiInArray(windowSize);
        int buysellindex = findStochasticDivergenceOnPriceDroporRise();
        if (buysellindex > 0)
        {
            if (macdCrossRising(OP_BUY) < 10 && mfiSlope() > 0.4 && mfi_arr[0] > 30 && sk_arr[0] > sk_arr[1])
            {
                //Print(trademessage);
                signal = OP_BUY;
            }
        }
        else if (buysellindex < 0)
        {
            if (macdCrossRising(OP_SELL) < 10 && mfiSlope() < -0.4 && mfi_arr[0] < 70 && sk_arr[0] < sk_arr[1])
            {
                //Print(trademessage);
                signal = OP_SELL;
            }
        }
        setTakeProfitStopLoss(signal);
        
        signalvaliduntil = TimeCurrent() + 10 * 60;
    }

    void RefreshCloseSignal(int actiontype, double entryprice, datetime opentime)
    {
        closesignal = -1;


    }

    double mfiSlope()
    {
        double slope = (mfi_arr[0] - mfi_arr[2]) / 3;
        return slope;
    }

    int macdCrossRising(int checkdirection)
    {
        int crossindex = 99;
        for (int i = 0; i < windowSize; i++)
        {
            double macdm = macdm_arr[i];
            double macds = macds_arr[i];
            if (checkdirection == OP_BUY) {
                if (i == 0 && macdm < macds)
                {
                    break;
                }
                if (macdm < macds) {
                    crossindex = i;
                    break;
                }
            }
            else if (checkdirection == OP_SELL) { 
                if (i == 0 && macdm > macds)
                {
                    break;
                }
                if (macdm > macds) {
                    crossindex = i;
                    break;
                }
            }

        }

        return crossindex;
    }

    void fillStochasticInArray(int windowsize)
    {
        ArrayResize(sk_arr, windowsize);
        ArrayResize(sd_arr, windowsize);

        string tdis = "";

        double sk0 = 0;
        double sd0 = 0;
        for (int i = 0; i < windowsize; i++)
        {
            sk0 = iStochastic(symbol, period, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            sd0 = iStochastic(symbol, period, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i);

            sk_arr[i] = sk0;
            sd_arr[i] = sd0;
            tdis += "," + sk0;
        }
        //Print(tdis);
    }

    void fillMacdInArray(int windowsize)
    {
        ArrayResize(macdm_arr, windowsize);
        ArrayResize(macds_arr, windowsize);

        double macdm = 0;
        double macds = 0;

        for (int i = 0; i < windowsize; i++)
        {
            macdm = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i);
            macds = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i);

            macdm_arr[i] = macdm;
            macds_arr[i] = macds;
        }
    }

    void fillMfiInArray(int windowsize)
    {
        ArrayResize(mfi_arr, windowsize);

        double mfi = 0;
        
        for (int i = 0; i < windowsize; i++)
        {
            mfi = iMFI(symbol, period, 14, i);
            mfi_arr[i] = mfi;
        }
    }

    int findStochasticDivergenceOnPriceDroporRise()
    {
        int windowTocheck = windowSize;

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

        
        int rsindex = 0;

        if (fsthighest == -1 || fstlowest == -1 || sechighest == -1 || seclowest == -1)
            return 0;


        double lowprice1 = iClose(symbol, period, fstlowest);
        double lowprice2 = iClose(symbol, period, seclowest);
        double highprice1 = iClose(symbol, period, fsthighest);
        double highprice2 = iClose(symbol, period, sechighest);

        int buyindex = 0;
        int sellindex = 0;

        drop_range = 0;
        rise_range = 0;

        if (fstlowest > fsthighest && sk_arr[0] > fstlowest_val) // HIGH position now
        {
            sellindex++;
            if (highprice1 < highprice2)
                sellindex++;
            if (fsthighest_val < sechighest_val)
                sellindex++;
            double risediff = fsthighest_val - fstlowest_val;
            double dropdiff = sechighest_val - fstlowest_val;
            if (dropdiff > risediff) {
                sellindex = sellindex + 3;
                drop_range = dropdiff;
            }
            
        }
        else if (fstlowest < fsthighest && sk_arr[0] < fsthighest_val) // LOW position now
        {
            buyindex++;
            if (lowprice1 > lowprice2)
                buyindex++;
            if (fstlowest_val > seclowest_val)
                buyindex++;
            double dropdiff = fsthighest_val - fstlowest_val;
            double risediff = fsthighest_val - seclowest_val;
            if (dropdiff < risediff)
            {
                buyindex = buyindex + 3;
                rise_range = risediff;
            }
                
        }

        
        
        if (sellindex == 0)
        {
                
            trademessage += ("1st low: " + fstlowest_val + "(" + fstlowest + ") 2nd low: " + seclowest_val + "(" + seclowest + ")");
            trademessage += ("1st high: " + fsthighest_val + "(" + fsthighest + ") 2nd high: " + sechighest_val + "(" + sechighest + ")");
            trademessage += ("Sellindex: " + sellindex + " buyindex: " + buyindex);

            return buyindex;
        }
        else if (buyindex == 0)
        {

            trademessage += ("1st low: " + fstlowest_val + "(" + fstlowest + ") 2nd low: " + seclowest_val + "(" + seclowest + ")");
            trademessage += ("1st high: " + fsthighest_val + "(" + fsthighest + ") 2nd high: " + sechighest_val + "(" + sechighest + ")");
            trademessage += ("Sellindex: " + sellindex + " buyindex: " + buyindex);

            return 0 - sellindex;
        }

        return 0;
    }

    void setTakeProfitStopLoss(int actiontype)
    {
        double cprice = 0;
        double atri = iATR(symbol, period, 14, 0);
        if (actiontype == OP_BUY)
        {
            cprice = MarketInfo(symbol, MODE_ASK);

            if (rise_range > 0) {
                //takeprofit = cprice + rise_range;
                //stoploss = cprice - rise_range;
                trademessage += ("Rise range: " + rise_range);
            }
            else
            {
                takeprofit = cprice + atri;
                stoploss = cprice - atri * 2;
            }
            
        }
        else 
        {
            cprice = MarketInfo(symbol, MODE_BID);

            if (drop_range > 0) {
                //takeprofit = cprice - drop_range;
                //stoploss = cprice + drop_range;
                trademessage += ("Drop range: " + drop_range);
            }
            else
            {
                takeprofit = cprice - atri;
                stoploss = cprice + atri * 2;
            }
        }

        
    }



};