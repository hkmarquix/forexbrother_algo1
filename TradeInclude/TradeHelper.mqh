#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BasicEntry.mqh"
#include "BaseSignal.mqh"
#include "tradefunction.mqh"
#include "Martingale.mqh"

class TradeHelper {
    private:
            
        BaseSignal *signalist[];
        
        // 1 -> basic method
        
    public:
        int totalsignal;
        int magicNumber;
        string symbol;
        int trademode;
        int period;
        datetime stopcreateOrderuntil;

    TradeHelper() {

        symbol = "EURUSD";
        period = PERIOD_M15;
        magicNumber = default_magicNumber;
        stopcreateOrderuntil = TimeCurrent();
    }

    void initHelper() {
        totalsignal = 0;
        if (usebasicentry == 1)
            totalsignal++;
        
        int currentsignali = 0;
        ArrayResize(signalist, totalsignal , 0);
        if (usebasicentry == 1)
        {
            signalist[currentsignali] = new BasicEntry();
            signalist[currentsignali].period = period;
            signalist[currentsignali].symbol = symbol;
        }

    }

    ~TradeHelper() {
        
    }

    void refreshRobot() {
        if (!checkHasOrder()) {
            if (timeToCreateNewOrder(0) &&
                tf_countRecoveryCurPair(symbol, magicNumber) < maxrecoverypair &&
                tf_countOpenedCurPair(symbol, magicNumber) < maxopenedpair) {
                createFirstOrder();
            }

        } else {
            checkHasOrderNextAction();
        }

    }

    bool checkHasOrder() {
        if (tf_countAllOrders(symbol, magicNumber) > 0)
            return true;
        trademode = defaulttrademode;
        return false;
    }

    bool timeToCreateNewOrder(int type) {
        if (stopcreateOrderuntil > TimeCurrent())
            return false;
        return true;
    }

    void createFirstOrder() {
        int signalcount = ArraySize(signalist);
        for (int i = 0; i < signalcount; i++)
        {
            BaseSignal *bsignal = (BaseSignal *)signalist[i];
            //Print("Checking signal..." + bsignal.signalname);
            if (bsignal.signalid == basicentryid)
            {
                BasicEntry *be = (BasicEntry *)bsignal;
                be.Refresh();
            }
            
            if (bsignal.signal != -1)
            {
                tf_createorder(symbol, bsignal.signal, initlots, "1", "", bsignal.stoploss, bsignal.takeprofit, bsignal.signalname, magicNumber);
                return;
            }
        }
    }

    void checkHasOrderNextAction() {
        if (tf_countAllOrders(symbol, magicNumber) == 1)
        {
            checkSignalCloseAction();
        }
        else 
        {
            // using recover method
            checkRecoverAction();
        }
    }

    void checkSignalCloseAction()
    {
        string orderparam[];
        tf_commentdecode(OrderComment(), orderparam);
        int signalcount = ArraySize(signalist);
        int resultsignal = -1;
        for (int i = 0; i < signalcount; i++)
        {
            BaseSignal *bsignal = (BaseSignal *)signalist[i];
            if (orderparam[1] == bsignal.signalname)
            {
                if (bsignal.signalid == basicentryid)
                {
                    BasicEntry *be = (BasicEntry *)bsignal;
                    be.RefreshCloseSignal(OrderType());
                }
                resultsignal = bsignal.closesignal;
                break;
            }
        }
        if (resultsignal == 1)
        {
            tf_closeAllOrders(symbol, magicNumber);
        }
    }

    void checkRecoverAction()
    {
        if (trademode == martingale)
        {
            Martingale *martin = new Martingale();
            martin.period = period;
            martin.symbol = symbol;

            martin.doRecovery();

            delete(martin);
        } else if (trademode == zonecap)
        {

        } else if (trademode == simplestoploss)
        {

        } else if (trademode == signalclosesignal) {

        }
    }




};
