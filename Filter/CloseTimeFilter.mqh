#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BaseFilter.mqh"

class CloseTimeFilter : public BaseFilter {
    private:
          
    public:
        
    CloseTimeFilter() {
        filtername = "ctimefilter";
        filterid = CTIMEFILTER;
        signal = -1;
        actiontype = -1;
        
        symbol = "EURUSD";
        period = PERIOD_M15;

        takeprofit = 0;
        stoploss = 0;

    }

    ~CloseTimeFilter() {
        
    }

    void Refresh()
    {
        signal = actiontype;

        if (!of_selectlastclosedorder(symbol, magicNumber))
            return;
        if (OrderType() != actiontype)
            return;
        //Print("Last order close time: " + OrderCloseTime());
       if (TimeCurrent() - OrderCloseTime() < period * 60)
       {
           signal = -1;
       }
       
    }

};