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
        recoveryname = "Martingale";
        recoveryid = martingale;
    }

    ~Martingale() {
        
    }

    int doRecovery() {
        if (!of_selectlastorder(symbol, magicNumber))
            return -1;

        if (OrderProfit() > 0)
            return -1;

        datetime lastopentime = OrderOpenTime();
        if (lastopentime - TimeCurrent() > 30 * 60 * 60)
            return -1;

        double lastprice = OrderOpenPrice();

        string param[];
        tf_commentdecode(OrderComment(), param);

        double cprice = 0;
        if (OrderType() == OP_BUY) {
            cprice = MarketInfo(symbol, MODE_ASK);
        }
        else
        {
            cprice = MarketInfo(symbol, MODE_BID);
        }

        double diff = MathAbs(cprice - lastprice) * of_getcurrencrymultipier();

        if (diff > curzone)
        {
            int neworderi = StrToInteger(param[2]) + 1;
            double newlots = OrderLots() + initlotstep + neworderi * lotincrease_step;

            tf_createorder(symbol, OrderType(), newlots, IntegerToString(neworderi), "", 0, 0, recoveryname, magicNumber);
            return 1;
        }

        // stopping criteria , can be deleted
        if (diff > curzone * 3) {
            tf_closeAllOrders(symbol, magicNumber);
            return 2;
        }
        
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


};