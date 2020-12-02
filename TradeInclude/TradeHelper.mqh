#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "ReportTg.mqh"
#include <hash.mqh>
#include <json.mqh>
#include "MIchimoku.mqh"
#include "StochasticMFI.mqh"
#include "StochasticM5.mqh"
#include "StochasticMACD.mqh"
#include "StochasticW.mqh"
#include "CBands.mqh"
#include "CGold.mqh"
#include "NextAction.mqh"
#include "TimePassed.mqh"

class TradeHelper {
    private:
        ReportTg * reportTg;
    NextAction * nextAction;

    int trademode;
    // 1 -> martingale 
    // 2-> zone cap 
    // 3 -> take profit / stop loss 
    // 4 -> martingale at support
    datetime stopcreateOrderuntil;
    
    datetime freemarginlastwarning;
    int currencydigitfix;
    string tradeparam;
    datetime lastreport;
    MIchimoku * moku;
    StochasticMFI * smfi;
    StochasticMACD *smacd;
    StochasticM5 *stocm5;
    StochasticW *stocw;
    CBands * cbands;
    CGold *cgold;

    int currentAction;
    double resistanceLv1;
    double resistanceLv2;
    double supportLv1;
    double supportLv2;
    double takeprofit_pt;
    double stoploss_pt;

    int lastsignalprovider;

    double lotstoadd;

    public:
        int magicNumber;
    string title;
    string symbol;
    int period;

    TradeHelper() {

        tradeparam = "";
        magicNumber = 0;
        currencydigitfix = 100;

        lastsignalprovider= -1;

        trademode = defaulttrademode;
        lastreport = TimeCurrent() + 5 * 60;
        stopcreateOrderuntil = TimeCurrent();
        freemarginlastwarning = TimeCurrent();
        
        lotstoadd = 0;
    }

    void initHelper() {
        moku = new MIchimoku(symbol);
        moku.period = period;
        smfi = new StochasticMFI(symbol);
        smfi.period = period;
        stocm5 = new StochasticM5(symbol);
        //stocm5.period = period;
        smacd = new StochasticMACD(symbol);
        smacd.period = period;
        stocw = new StochasticW(symbol);
        stocw.period = period;
        cbands = new CBands(symbol);
        cbands.period = period;
        cgold = new CGold(symbol);
        //cgold.period = period;
        reportTg = new ReportTg();
        nextAction = new NextAction();
        nextAction.magicNumber = magicNumber;
        nextAction.title = title;
        nextAction.symbol = symbol;
        nextAction.trademode = trademode;
    }

    ~TradeHelper() {
        delete(reportTg);
        delete(moku);
        delete(smfi);
        delete(stocm5);
        delete(stocw);
        delete(smacd);
        delete(cbands);
        delete(cgold);
        delete(nextAction);
        //delete(gold);
    }

    void refreshRobot() {
        if (!checkHasOrder()) {
            if (timeToCreateNewOrder(0) &&
                nextAction.countRecoveryCurPair() < maxrecoverypair &&
                nextAction.countOpenedCurPair() < maxopenedpair) {
                createFirstOrder();
            }

        } else {

            checkHasOrderNextAction();
        }

        if (TimeCurrent() > lastreport) {
            reportTg.syncClosedTradeToServer();
            lastreport = TimeCurrent() + 5 * 60;
        }
    }


    int countAllOrders() {
        int torder = 0;
        for (int i = 0; i < OrdersTotal(); i++) {
            OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
            if (OrderMagicNumber() == magicNumber && OrderSymbol() == symbol)
                torder++;
        }
        return torder;
    }

    bool checkHasOrder() {
        if (countAllOrders() > 0)
            return true;
        trademode = defaulttrademode;
        return false;
    }


    bool timeToCreateNewOrder(int type) {
        if (stopcreateOrderuntil > TimeCurrent())
            return false;
        //int min = TimeMinute(TimeCurrent());
        //if (min == 0 || min == 15 || min == 30 || min == 45)
            return true;
        //return false;
    }


    bool timeToCreateMartingaleOrder(int type) {
        int min = TimeMinute(TimeCurrent());
        if (min == 0)
            return true;
        return false;
    }

    void checkFreeMargin() {
        if (freemarginlastwarning + 120 > TimeCurrent())
            return;
        if (AccountFreeMargin() < 300 && !IsTesting()) {
            Alert("Free Margin is too low");
            reportTg.reportToTg(symbol + " Free margin is too low");
            freemarginlastwarning = TimeCurrent();
        }
    }

    void createFirstOrder() {
        int buysell_action = buySellDecisionMaker();
        if (buysell_action == -1) return;

        Print("Signal provider: " + lastsignalprovider);
        if (trademode == 3)
        {

          Print(StringFormat("SV1: %f , %f   RV1: %f, %f", supportLv1, supportLv2, resistanceLv1, resistanceLv2));
          if (buysell_action == OP_BUY)
            nextAction.createMyOrder(buysell_action, initlots, "1", tradeparam, supportLv2, resistanceLv1);
          else
            nextAction.createMyOrder(buysell_action, initlots, "1", tradeparam, resistanceLv2, supportLv1);
        }
        else if (trademode == 4)
        {
          nextAction.createMyOrder(buysell_action, initlots + lotstoadd, "1", tradeparam, 0, 0);
          lotstoadd= 0;
        }
        else if (trademode == 5)
        {
            //gold.Refresh();
            //buysell_action == gold.signal;
            //if (buysell_action == -1) return;
            //nextAction.createMyOrder(buysell_action, initlots, "1", "", 0, 0);
        }
        else
        {
          nextAction.createMyOrder(buysell_action, initlots, "1", tradeparam, 0, 0);
        }
        tradeparam = "";
        
        stopcreateOrderuntil = TimeCurrent() + 60 * 5;
    }

    int buySellDecisionMaker() {
        tradeparam = "";
        int strongsign = -1;
        if (usestrongsell == 1)
            strongsign = strongSignal();
        if (strongsign != -1) {
            return strongsign;
        }

        if (usecgold == 1)
        {
            cgold.Refresh();
            int newsignal = cgold.GetSignalSide();
            if (newsignal != -1)
            {
                tradeparam = cgold.tradeparam;
                currentAction = newsignal;
                lastsignalprovider = 6;
                return newsignal;
            }
        }
        if (usestocw == 1)
        {
            stocw.Refresh();
            int newsignal = stocw.GetSignalSide();
            if (newsignal != -1) {
                tradeparam = stocw.tradeparam;
                currentAction = newsignal;
                supportLv1 = stocw.supportLv1;
                supportLv2 = stocw.supportLv2;
                resistanceLv1 = stocw.resistanceLv1;
                resistanceLv2 = stocw.resistanceLv2;
                stoploss_pt = 0;
                takeprofit_pt = 0;
                lastsignalprovider = 5;
                return newsignal;
            }
        }
        if (usestocm5 == 1) {
            stocm5.Refresh();
            int newsignal = stocm5.GetSignalSide();
            if (newsignal != -1) {
                tradeparam = stocm5.tradeparam;
                currentAction = newsignal;
                supportLv1 = 0;
                supportLv2 = 0;
                resistanceLv1 = 0;
                resistanceLv2 = 0;
                stoploss_pt = 0;
                takeprofit_pt = 0;
                lastsignalprovider = 4;
                return newsignal;
            }
        }
        if (usestocmacd == 1)
        {
            smacd.Refresh();
            int newsignal = smacd.GetSignalSide();
            if (newsignal != -1) {
                tradeparam = smacd.tradeparam;
                currentAction = newsignal;
                supportLv1 = smacd.supportLv1;
                supportLv2 = smacd.supportLv2;
                resistanceLv1 = smacd.resistanceLv1;
                resistanceLv2 = smacd.resistanceLv2;
                stoploss_pt = 0;
                takeprofit_pt = 0;
                lastsignalprovider = 3;
                return newsignal;
            }
        }
        if (usemochimoku == 1) {
            moku.Refresh();
            int newsignal = moku.GetSignalSide();
            if (newsignal != -1) {
                tradeparam = moku.tradeparam;
                currentAction = newsignal;
                supportLv1 = moku.supportLv1;
                supportLv2 = moku.supportLv2;
                resistanceLv1 = moku.resistanceLv1;
                resistanceLv2 = moku.resistanceLv2;
                stoploss_pt = moku.stoplosspoint;
                takeprofit_pt = 0;
                lastsignalprovider= 2;
                return newsignal;
            }
        }
        if (usestochastic == 1) {
            smfi.Refresh();
            int newsignal = smfi.GetSignalSide();
            if (newsignal != -1) {
                tradeparam = smfi.tradeparam;
                currentAction = newsignal;
                supportLv1 = smfi.supportLv1;
                supportLv2 = smfi.supportLv2;
                resistanceLv1 = smfi.resistanceLv1;
                resistanceLv2 = smfi.resistanceLv2;
                stoploss_pt = 0;
                takeprofit_pt = 0;
                lastsignalprovider = 1;
                return newsignal;
            }
        }

        return -1;
    }

    int strongSignal() {
        cbands.Refresh();
        int strongsign = cbands.GetSignalSide();
        if (strongsign != -1) {
            tradeparam = cbands.tradeparam;
            currentAction = strongsign;
            supportLv1 = cbands.supportLv1;
            supportLv2 = cbands.supportLv2;
            resistanceLv1 = cbands.resistanceLv1;
            resistanceLv2 = cbands.resistanceLv2;
            lastsignalprovider = 3;
            return strongsign;
        }
        return -1;
    }

    void checkNormalCloseSignal()
    {
        int firstOrderType = -1;
        double openPrice;
        int totalOrders = 0;
        int buyOrder = 0;
        int sellOrder = 0;
        bool closeOrders;
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
            if (OrderMagicNumber() != magicNumber || OrderSymbol() != symbol)
                continue;
            if (OrderComment() == "1") {
                firstOrderType = OrderType();
                openPrice = OrderOpenPrice();
            }
            if (OrderType() == OP_SELL)
                sellOrder++;
            if (OrderType() == OP_BUY)
                buyOrder++;
            totalOrders++;
        }
        if (buyOrder >= 1 && sellOrder >= 1)
            totalOrders = buyOrder + 1;

        if (lastsignalprovider == 5)
        {
            int res = stocw.GetCloseSignal(firstOrderType, openPrice);
            if (res == 1)
                closeOrders = true;
        }
        if (closeOrders)
            nextAction.closeAllOrders();
    }

    void checkTrailingProfitAction()
    {
        double totalProfit = 0;
        int totalOrders = 0;
        int buyOrder = 0;
        int sellOrder = 0;
        datetime otime  = 0;
        int firstOrderType = -1;
        double openPrice;
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
            if (OrderMagicNumber() != magicNumber || OrderSymbol() != symbol)
                continue;
            if (OrderComment() == "1") {
                otime = OrderOpenTime();
                firstOrderType = OrderType();
                openPrice = OrderOpenPrice();
            }
            totalProfit += OrderCommission() + OrderSwap() + OrderProfit();
            if (OrderType() == OP_SELL)
                sellOrder++;
            if (OrderType() == OP_BUY)
                buyOrder++;
            totalOrders++;
        }
        if (buyOrder >= 1 && sellOrder >= 1)
            totalOrders = buyOrder + 1;

        
        double preferProfit = totalOrders * targetProfitForEachOrder;
        //Print("Prefer profit: " + preferProfit + " / total profit: " + totalProfit);
        if (preferProfit <= totalProfit) {
            if (totalOrders > 1) {
                nextAction.closeAllOrders();
                return;
            }
            // Start checking trailing
            bool closeOrders = false;
            if (lastsignalprovider == 4 && firstOrderType != -1)
            {
                int res = stocm5.GetTrailingCloseSignal(firstOrderType, openPrice);
                if (res == 1)
                    closeOrders = true;
            }
            else if (lastsignalprovider == 3 && firstOrderType != -1)
            {
                int res = smacd.GetTrailingCloseSignal(firstOrderType, openPrice);
                if (res == 1)
                    closeOrders = true;
            }
            else if (lastsignalprovider == 2 && firstOrderType != -1)
            {
                int res = moku.GetTrailingCloseSignal(firstOrderType, openPrice);
                if (res == 1)
                    closeOrders = true;
            }
            else if (lastsignalprovider == 1 && firstOrderType != -1)
            {
                int res = smfi.GetTrailingCloseSignal(firstOrderType, openPrice);
                if (res == 1)
                    closeOrders = true;
            }
            else
            {
                closeOrders = true;
            }
            if (closeOrders)
                nextAction.closeAllOrders();
        }
        else if (otime > 0 && totalOrders == 1) {
            double timediff = TimeCurrent() - otime;
            if ((timediff > 1 * 60 * 60 && totalProfit > preferProfit / 2)
                    ||
                    (timediff > 3 * 60 * 60 && totalProfit > 0))
            {
                bool closeOrders = false;
            if (lastsignalprovider == 4 && firstOrderType != -1)
            {
                int res = stocm5.GetTrailingCloseSignal(firstOrderType, openPrice);
                if (res == 1)
                    closeOrders = true;
            }
            else if (lastsignalprovider == 3 && firstOrderType != -1)
            {
                int res = smacd.GetTrailingCloseSignal(firstOrderType, openPrice);
                if (res == 1)
                    closeOrders = true;
            }
            else if (lastsignalprovider == 2 && firstOrderType != -1)
            {
                int res = moku.GetTrailingCloseSignal(firstOrderType, openPrice);
                if (res == 1)
                    closeOrders = true;
            }
            else if (lastsignalprovider == 1 && firstOrderType != -1)
            {
                int res = smfi.GetTrailingCloseSignal(firstOrderType, openPrice);
                if (res == 1)
                    closeOrders = true;
            }
            else
            {
                closeOrders = true;
            }
            if (closeOrders)
                nextAction.closeAllOrders();
            }
        }
    }

    void checkHasOrderNextAction() {
        

        if (trademode == 1 && timeToCreateMartingaleOrder(0)) {
            nextAction.checkTakeProfitAndClose();
            nextAction.checkNeedMartingaleRecoveryAction();
        }
        if (trademode == 2) {
          //nextAction.checkTakeProfitAndClose();
          checkTrailingProfitAction();
          checkNormalCloseSignal();
          nextAction.checkNeedZoneCapRecoveryAction();
        }
        if (trademode == 3)
        {
            //nextAction.checkSupportResistanceAndTakeProfitStopLoss(currentAction, supportLv1, supportLv2, resistanceLv1, resistanceLv2);
        }
        if (trademode == 4)
        {
          if (true)//lastsignalprovider == 6)
          {
              double oprice = 0;
              int ordertype = -1;
              int firstorderi = -1;

              int total_orderno = 0;
              double total_profit = 0;
              double lastOpenTime;
              for (int i = 0; i < OrdersTotal(); i++)
              {
                  OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
                  if (symbol != OrderSymbol())
                    continue;
                if (firstorderi == -1)
                    firstorderi = i;
                oprice = OrderOpenPrice();
                ordertype = OrderType();
                lastOpenTime = OrderOpenTime();

                total_orderno++;
                total_profit += OrderCommission() + OrderSwap() + OrderProfit();
              }
                if (total_orderno > 0 && total_profit > 0)
                {
                    double perferprofit = total_orderno * targetProfitForEachOrder;
                    if (total_profit > perferprofit)
                    {
                        if (cgold.checkTrailingProfit(ordertype, lastOpenTime)) {
                            Print("Total profit: " + total_profit + " Perfer profit: " + perferprofit + " Close all");
                            nextAction.closeAllOrders();
                        }
                    }
                    else { 
                        checkTrailingProfitAction();
                    }
                }
                else
                {

                    if (firstorderi == -1)
                        return;
                    OrderSelect(firstorderi, SELECT_BY_POS, MODE_TRADES);
                    int csignal = cgold.GetCloseSignal(ordertype, oprice);
                    if (csignal == 1)
                    {
                        //nextAction.closeAllOrders();
                    }
                    if (csignal == 2)
                    {
                        // start martingale
                        //Print("MATRINGALE.......");
                        nextAction.checkNeedMartingaleRecoveryAction();
                    }

                    if (cgold.GetTooLongToCloseEvenLost(ordertype, lastOpenTime) == 1)
                    {
                        nextAction.closeAllOrders();
                    }
                }

          }
        }
        else if (trademode == 5) {
            
        }
    }




};
