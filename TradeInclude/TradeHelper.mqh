#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BasicEntry.mqh"
#include "BaseSignal.mqh"
#include "tradefunction.mqh"
#include "../RecoverAction/Martingale.mqh"
#include "../RecoverAction/ZoneCap.mqh"
#include "../Filter/TimeFilter.mqh"

class TradeHelper {
    private:
        
    public:
        BaseSignal *signalist[];
        int totalsignal;
        int magicNumber;
        string symbol;
        int trademode;
        int period;
        int curzone;
        datetime stopcreateOrderuntil;
        int presettrademode;

    TradeHelper() {

        symbol = "EURUSD";
        period = PERIOD_M15;
        magicNumber = default_magicNumber;
        stopcreateOrderuntil = TimeCurrent();
    }

// self modify
    virtual void initHelper() {
        totalsignal = 0;
        if (usebasicentry == 1)
            totalsignal++;
        
        int currentsignali = 0;
        initSignal(currentsignali);
    }

// self modify
    virtual void initSignal(int currentsignali) {
        ArrayResize(signalist, totalsignal , 0);
        if (usebasicentry == 1)
        {
            signalist[currentsignali] = new BasicEntry();
            signalist[currentsignali].period = period;
            signalist[currentsignali].symbol = symbol;
        }

    }

    ~TradeHelper() {
        int signalcount = ArraySize(signalist);
        for (int i = 0; i < signalcount; i++)
        {
            BaseSignal *bsignal = (BaseSignal *)signalist[i];
            delete(bsignal);
        }
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
        return false;
    }

    bool timeToCreateNewOrder(int type) {
        if (stopcreateOrderuntil > TimeCurrent())
            return false;
        return true;
    }

// Self include this and modify
    virtual void signalRefresh(BaseSignal *bsignal)
    {
        if (bsignal.signalid == basicentryid)
        {
            BasicEntry *be = (BasicEntry *)bsignal;
            be.Refresh();
        }
    }

    void createFirstOrder() {
        int signalcount = ArraySize(signalist);
        for (int i = 0; i < signalcount; i++)
        {
            BaseSignal *bsignal = (BaseSignal *)signalist[i];
            signalRefresh(bsignal);
            
            if (createOrderFilter(bsignal.signal, initlots) && bsignal.signal != -1)
            {
                Print("Create order now");
                tf_createorder(symbol, bsignal.signal, initlots, "1", "", bsignal.stoploss, bsignal.takeprofit, bsignal.signalname, magicNumber);
                return;
            }
        }
    }

// Self include this and modify
    virtual bool createOrderFilter(int signal, double lotsize)
    {

        return true;
    }

    void checkHasOrderNextAction() {
        int torders = tf_countAllOrders(symbol, magicNumber);
        if (torders > 0)
        {
            checkSignalCloseAction();
            checkRecoverAction();
        }
    }

    virtual void closeSignalRefresh(BaseSignal *bsignal)
    {
        if (bsignal.signalid == basicentryid)
        {
            BasicEntry *be = (BasicEntry *)bsignal;
            be.RefreshCloseSignal(OrderType(), OrderOpenPrice());
        }
        
    }

    void checkSignalCloseAction()
    {
        string orderparam[];
        //tf_findFirstOrder(symbol, magicNumber);
        //Print("Order comment: " + OrderComment());
        tf_commentdecode(OrderComment(), orderparam);
        
        int signalcount = ArraySize(signalist);
        int resultsignal = -1;
        for (int i = 0; i < signalcount; i++)
        {
            BaseSignal *bsignal = (BaseSignal *)signalist[i];
            if (orderparam[1] == bsignal.signalname)
            {
                closeSignalRefresh(bsignal);
                resultsignal = bsignal.closesignal;
                break;
            }
        }
        if (resultsignal == 1)
        {
            tf_closeAllOrders(symbol, magicNumber);
        }
    }

// Self include this and modify
    virtual void checkRecoverAction()
    {
        if (trademode == martingale)
        {
            Martingale *martin = new Martingale();
            martin.period = period;
            martin.symbol = symbol;
            martin.magicNumber = magicNumber;
            martin.curzone = curzone;
            martin.takeProfit();
            martin.doRecovery();
            
            delete(martin);
        } else if (trademode == zonecap)
        {
            Zonecap *zc = new Zonecap();
            zc.period = period;
            zc.symbol = symbol;
            zc.magicNumber = magicNumber;
            zc.curzone = curzone;
            zc.takeProfit();
            zc.doRecovery();
            
            delete(zc);
        } else if (trademode == simplestoploss)
        {

        } else if (trademode == signalclosesignal) {

        }
    }




};
