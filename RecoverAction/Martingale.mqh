#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BaseRecovery.mqh"

class Martingale : public BaseRecovery {
    private:
           int TenKanSen;
int KijunSen;
int SenKouSpanB;
   

    public:

    Martingale() {
 TenKanSen = 9;
        KijunSen = 26;
        SenKouSpanB = 52;

        initHelper();
    }

    void initHelper() {
        recoveryname = "Martin";
        recoveryid = martingale;
    }

    ~Martingale() {
        
    }

    int simplyDoRecovery()
    {
        if (!of_selectlastorder(symbol, magicNumber))
            return -1;

        if (OrderProfit() > 0)
            return -1;

        string param[];
        tf_commentdecode(OrderComment(), param);
        int orderi = StrToInteger(param[2]);

        datetime lastopentime = OrderOpenTime();
        
        if (TimeCurrent() - lastopentime < PeriodSeconds(period) * 3)
            return -1;

        int neworderi = StrToInteger(param[2]) + 1;
        double newlots = OrderLots() + initlotstep + neworderi * lotincrease_step;

        tf_createorder(symbol, OrderType(), newlots, IntegerToString(neworderi), "", 0, 0, param[1], magicNumber);
        return 1;

    }

    int doRecovery() {
        if (!of_selectlastorder(symbol, magicNumber))
            return -1;

        if (OrderProfit() > 0)
            return -1;

        string param[];
        tf_commentdecode(OrderComment(), param);
        int orderi = StrToInteger(param[2]);

        datetime lastopentime = OrderOpenTime();
        
        if (orderi == 1 && TimeCurrent() - lastopentime < 5 * 60)
            return -1;
        if (orderi > 1 && TimeCurrent() - lastopentime < 20 * 60)
            return -1;
        
        //Print("Last open time: " + lastopentime + " C: " + OrderComment());
        double lastprice = OrderOpenPrice();

        

        double cprice = 0;
        if (OrderType() == OP_BUY) {
            cprice = MarketInfo(symbol, MODE_ASK);
        }
        else
        {
            cprice = MarketInfo(symbol, MODE_BID);
        }

        double diff = MathAbs(cprice - lastprice) * of_getcurrencrymultipier(symbol);

        if (diff > currecover && needRecoveryAction(cprice))
        {
            int neworderi = StrToInteger(param[2]) + 1;
            double newlots = OrderLots() + initlotstep + neworderi * lotincrease_step;

            tf_createorder(symbol, OrderType(), newlots, IntegerToString(neworderi), "", 0, 0, recoveryname, magicNumber);
            return 1;
        }
        
        if (checkGiveupMartingaleAndChangeToZoneCap())
         return 2;

        return -1;
    }

    bool checkGiveupMartingaleAndChangeToZoneCap()
    {
      if (!of_selectfirstorder(symbol, magicNumber))
            return false;
            double cprice = 0;
        if (OrderType() == OP_BUY) {
            cprice = MarketInfo(symbol, MODE_ASK);
        }
        else
        {
            cprice = MarketInfo(symbol, MODE_BID);
        }

        double diff = MathAbs(cprice - OrderOpenPrice()) * of_getcurrencrymultipier(symbol);
      if (diff > curzone) {
            
            
            
            if (leavingCloudAndPrepareforBigRiseorDrop(OrderType()))
               return true;
            
            
            
        }
        
        return false;
    }
    
    bool checkTouchCloudInWindow(int actiontype, int window)
    {
     int tperiod = PERIOD_M15;
         double tenkan_sen = iIchimoku(symbol,tperiod,TenKanSen,KijunSen,SenKouSpanB,MODE_TENKANSEN,window);
        double kinjun_sen = iIchimoku(symbol,tperiod,TenKanSen,KijunSen,SenKouSpanB,MODE_KIJUNSEN,window);
        double senkou_spanA = iIchimoku(symbol,tperiod,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANA,window);
        double senkou_spanB = iIchimoku(symbol,tperiod,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANB,window);
        double ihigh = iHigh(symbol, tperiod, window);
        double ilow = iLow(symbol, tperiod, window);
        if ((ihigh < MathMax(senkou_spanA, senkou_spanB && actiontype == OP_SELL)
         ||
         (ilow > MathMin(senkou_spanA, senkou_spanB) && actiontype == OP_BUY)))
         return true;
        return false;
    }
    
    bool leavingCloudAndPrepareforBigRiseorDrop(int actiontype)
    {
        int tperiod = PERIOD_M15;
        double tenkan_sen = iIchimoku(symbol,tperiod,TenKanSen,KijunSen,SenKouSpanB,MODE_TENKANSEN,0);
        double kinjun_sen = iIchimoku(symbol,tperiod,TenKanSen,KijunSen,SenKouSpanB,MODE_KIJUNSEN,0);
        double senkou_spanA = iIchimoku(symbol,tperiod,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANA,0);
        double senkou_spanB = iIchimoku(symbol,tperiod,TenKanSen,KijunSen,SenKouSpanB,MODE_SENKOUSPANB,0);

        double ihigh = iHigh(symbol, tperiod, 0);
        double ilow = iLow(symbol, tperiod, 0);
        
        bool justtouch = false;
        for (int i = 1; i < 8; i++)
        {
         if (checkTouchCloudInWindow(actiontype, i))
            justtouch = true;
        }
        if (!justtouch)
         return false;

        if (tenkan_sen > kinjun_sen && tenkan_sen > MathMax(senkou_spanA, senkou_spanB) 
         && ilow > MathMax(senkou_spanA, senkou_spanB )
         && actiontype == OP_SELL)
            return true;
        if (tenkan_sen < kinjun_sen && tenkan_sen < MathMin(senkou_spanA, senkou_spanB) 
         && ihigh < MathMin(senkou_spanA, senkou_spanB )
         && actiontype == OP_BUY)
            return true; 

         return false;
    }


    int takeProfit()
    {
        int torder = tf_countAllOrders(symbol, magicNumber);
        if (torder <= 1)
            return -1;
        double tprofit = tf_orderTotalProfit(symbol, magicNumber);
        
        if (tprofit > targetProfitForEachOrder * torder) {
            tf_closeAllOrders(symbol, magicNumber);
            return 1;
        }

        return -1;
    }

    bool needRecoveryAction(double cprice)
    {
        period = PERIOD_M15;
        int actiontype = OrderType();

    double maend = iMA(symbol, period, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
     double maend1 = iMA(symbol, period, 5, 0, MODE_EMA, PRICE_CLOSE, 1);
     double mastart = iMA(symbol, period, 5, 0, MODE_EMA, PRICE_CLOSE, 1);//windowToCheck - 1);

     double iatr = iATR(symbol, period, 14, 0);

     double maslope = (maend - mastart) / 2;

     if (actiontype == OP_BUY && maslope < -2) //checkHighestI == windowToCheck - 1)
     {
       return false;
     }
     if (actiontype == OP_SELL && maslope > 2) // checkLowestI == windowToCheck -1)
     {
       return false;
     }

      double macdm = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        double macds = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);

        double macdm1 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double macds1= iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);

      if (actiontype == OP_BUY && (macdm < macdm1 || macdm < macds - 1))
      {
         return false;
      }
      if (actiontype == OP_SELL && (macdm > macdm1 || macdm - 1 > macds))
      {
         return false;
      }

        if (cprice > maend + iatr * 0.15 && (maend - mastart) < 1)
        {
            return true;
        }
        //else if (cprice < maend - iatr * 0.25 && (maend - mastart) > -1)
        else if (cprice < maend - iatr * 0.15 && (maend - mastart) > -1)
        {
            return true;
        }
        return false;
    }

};