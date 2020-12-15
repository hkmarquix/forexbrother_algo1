#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BaseRecovery.mqh"

class Martingale : public BaseRecovery {
    private:
           
    public:

    Martingale() {

        initHelper();
    }

    void initHelper() {
        recoveryname = "Martin";
        recoveryid = martingale;
    }

    ~Martingale() {
        
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
        
        if (orderi == 1 && TimeCurrent() - lastopentime < 5 * 60 * 60)
            return -1;
        if (orderi > 1 && TimeCurrent() - lastopentime < 30 * 60 * 60)
            return -1;
        
        Print("Last open time: " + lastopentime + " C: " + OrderComment());
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

        if (diff > curzone && needRecoveryAction(cprice))
        {
            int neworderi = StrToInteger(param[2]) + 1;
            double newlots = OrderLots() + initlotstep + neworderi * lotincrease_step;

            tf_createorder(symbol, OrderType(), newlots, IntegerToString(neworderi), "", 0, 0, recoveryname, magicNumber);
            return 1;
        }

        //stopping criteria , can be deleted
        //if (diff > curzone * 3) {
        //    tf_closeAllOrders(symbol, magicNumber);
        //    return 2;
        //}
        
        return -1;
    }


    int takeProfit()
    {
        double tprofit = tf_orderTotalProfit(symbol, magicNumber);
        int torder = tf_countAllOrders(symbol, magicNumber);
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