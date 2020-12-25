#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "MarquisBasicStochasticEntry.mqh"
#include "MarquisBollingerEntry.mqh"
#include "MichimokuSignal.mqh"
#include "CGoldSignal.mqh"
#include "../TradeInclude/TradeHelper.mqh"
#include "../TradeInclude/BasicEntry.mqh"
#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"
#include "../RecoverAction/Martingale.mqh"
#include "../RecoverAction/ZoneCap.mqh"
#include "../Filter/TimeFilter.mqh"
#include "../Filter/ADXFilter.mqh"

class MTradeHelper : public TradeHelper {
    private:
            
    public:
        
    MTradeHelper() {
        TradeHelper();
    }

// self modify
    void initHelper() {
        totalsignal = 0;
        if (usebasicentry == 1)
            totalsignal++;
        if (use_marquisbasicstochasticmethod == 1)
            totalsignal++;
        if (use_marquisbandentry == 1)
            totalsignal++;
        if (use_michimoku == 1)
            totalsignal++;
        if (use_cgold == 1)
            totalsignal++;
        Print("Total signal size: " + totalsignal);
        ArrayResize(signalist, totalsignal , 0);

        initSignal(0);
        
    }


// self modify
    void initSignal(int currentsignali) {
        
        if (usebasicentry == 1)
        {
            signalist[currentsignali] = new BasicEntry();
            signalist[currentsignali].period = period;
            signalist[currentsignali++].symbol = symbol;
        }
        if (use_marquisbasicstochasticmethod == 1)
        {
            signalist[currentsignali] = new MarquisBasicStochasticEntry();
            signalist[currentsignali].period = period;
            signalist[currentsignali++].symbol = symbol;
        }
        if (use_marquisbandentry == 1)
        {
            signalist[currentsignali] = new MarquisBollingerEntry();
            signalist[currentsignali].period = period;
            signalist[currentsignali++].symbol = symbol;
        }
        if (use_michimoku == 1)
        {
            signalist[currentsignali] = new MichimokuSignal();
            signalist[currentsignali].period = period;
            signalist[currentsignali++].symbol = symbol;
        }
        if (use_cgold == 1)
        {
            signalist[currentsignali] = new CGoldSignal();
            signalist[currentsignali].period = period;
            signalist[currentsignali].magicNumber = magicNumber;
            signalist[currentsignali].curzone = curzone;
            signalist[currentsignali++].symbol = symbol;
        }
        
    }

// Self include this and modify
    void signalRefresh(BaseSignal *bsignal)
    {
        //Print(bsignal.signalid);
        if (bsignal.signalid == basicentryid)
        {
            BasicEntry *be = (BasicEntry *)bsignal;
            be.Refresh();
        }
        if (bsignal.signalid == marquisbasicentry)
        {
            MarquisBasicStochasticEntry *mbe = (MarquisBasicStochasticEntry *)bsignal;
            mbe.Refresh();
        }
        if (bsignal.signalid == marquisbandentry)
        {
            MarquisBollingerEntry *mbe = (MarquisBollingerEntry *)bsignal;
            mbe.Refresh();
        }
        if (bsignal.signalid == michimoku)
        {
            MichimokuSignal *ms = (MichimokuSignal *)bsignal;
            ms.Refresh();
        }
        if (bsignal.signalid == cgold)
        {
            CGoldSignal *cg = (CGoldSignal *)bsignal;
            cg.Refresh();
        }
    }


// Self include this and modify
    bool createOrderFilter(int signal, double lotsize)
    {
        TimeFilter *tf = new TimeFilter();
        tf.symbol = symbol;
        tf.period = period;
        tf.actiontype = signal;
        tf.lotsize = lotsize;
        tf.Refresh();
        int tsignal = tf.signal;
        delete(tf);
        if (tsignal != signal) {
            return false;
        }

        ADXFilter *adxf = new ADXFilter();
        adxf.symbol = symbol;
        adxf.period = period;
        adxf.actiontype = signal;
        adxf.lotsize = lotsize;
        adxf.Refresh();
        tsignal = adxf.signal;
        delete(adxf);
        if (tsignal != signal) {
            return false;
        }


        return true;
    }

    void closeSignalRefresh(BaseSignal *bsignal)
    {
        of_selectlastorder(symbol, magicNumber);
        if (bsignal.signalid == basicentryid)
        {
            BasicEntry *be = (BasicEntry *)bsignal;
            be.RefreshCloseSignal(OrderType(), OrderOpenPrice());
        }
        else if (bsignal.signalid == marquisbasicentry)
        {
            MarquisBasicStochasticEntry *mse = (MarquisBasicStochasticEntry *)bsignal;
            mse.RefreshCloseSignal(OrderType(), OrderOpenPrice());
        }
        else if (bsignal.signalid == marquisbandentry)
        {
            MarquisBollingerEntry *mse = (MarquisBollingerEntry *)bsignal;
            mse.RefreshCloseSignal(OrderType(), OrderOpenPrice());
        }
        else if (bsignal.signalid == michimoku)
        {
            MichimokuSignal *ms = (MichimokuSignal *)bsignal;
            ms.RefreshCloseSignal(OrderType(), OrderOpenPrice());
        }
        else if (bsignal.signalid == cgold)
        {
            CGoldSignal *cg = (CGoldSignal *)bsignal;
            cg.RefreshCloseSignal(OrderType(), OrderOpenPrice(), OrderOpenTime());
        }
    }


// Self include this and modify
    void checkRecoverAction()
    {
        if (trademode == martingale)
        {
            Martingale *martin = new Martingale();
            martin.period = PERIOD_M1;
            martin.symbol = symbol;
            martin.magicNumber = magicNumber;
            martin.curzone = curzone;
            martin.currecover = currecover;
            martin.takeProfit();
            int res = martin.doRecovery();
            if (res == 2)
            {
               trademode = zonecap;
            }
            
            delete(martin);
        } else if (trademode == zonecap)
        {
            Zonecap *zc = new Zonecap();
            zc.period = period;
            zc.symbol = symbol;
            zc.magicNumber = magicNumber;
            zc.curzone = curzone;
            zc.currecover = currecover;
            zc.takeProfit();
            zc.doRecovery();
            
            delete(zc);
        } else if (trademode == simplestoploss)
        {

        } else if (trademode == signalclosesignal) {

        }
    }




};
