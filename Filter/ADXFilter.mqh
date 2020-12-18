#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BaseFilter.mqh"

class ADXFilter : public BaseFilter {
    private:
          
    public:
        
    ADXFilter() {
        filtername = "adxfilter";
        filterid = ADXFILTER;
        signal = -1;
        actiontype = -1;
        
        symbol = "EURUSD";
        period = PERIOD_M15;

        takeprofit = 0;
        stoploss = 0;

    }

    ~ADXFilter() {
        
    }

    void Refresh()
    {
       signal = actiontype;
       double atr = iATR(symbol, period, 14, 0);
       //if (atr < 1)
       //  signal = -1;
       double adx = iADX(symbol, period, 14, PRICE_CLOSE, MODE_MAIN, 0);
       if (adx < 24)
         signal = -1;

    }

};