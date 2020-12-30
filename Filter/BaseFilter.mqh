#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict


class BaseFilter {
    private:
          
    public:
        int filterid;
        int signal;
        int closesignal;

        int actiontype;
        int lotsize;

        double takeprofit;
        double stoploss;
        
        string symbol;
        int period;
        string filtername;

        int magicNumber;

    BaseFilter() {
        filtername = "";
        filterid = -1;
        signal = -1;
        magicNumber = -1;
        
        symbol = "EURUSD";
        period = PERIOD_M15;

        takeprofit = 0;
        stoploss = 0;

    }

    ~BaseFilter() {
        
    }

    void Refresh()
    {
        

        //Print("Base signal refresh");
    }

};