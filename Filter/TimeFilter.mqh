#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BaseFilter.mqh"

class TimeFilter : public BaseFilter {
    private:
          
    public:
        
    TimeFilter() {
        filtername = "timefilter";
        filterid = TIMEFILTER;
        signal = -1;
        actiontype = -1;
        
        symbol = "EURUSD";
        period = PERIOD_M15;

        takeprofit = 0;
        stoploss = 0;

    }

    ~TimeFilter() {
        
    }

    void Refresh()
    {
        signal = actiontype;
       if (DayOfWeek() == 5 && TimeHour(TimeCurrent()) >= 21)
       {
           signal = -1;
       }
       if (DayOfWeek() == 1 && TimeHour(TimeCurrent()) < 4)
       {
           signal = -1;
       }

    }

};