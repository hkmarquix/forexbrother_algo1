#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict


class BaseRecovery {
    private:
           
    public:
        string recoverymethod;
        int recoveryid;

        int period;
        string symbol;
        int magicNumber;
        int curzone;
        int recoversignal;

    BaseRecovery() {

        initHelper();
    }

    void initHelper() {
        recoverymethod = "BaseRecovery";
        recoveryid = -1;
        curzone = 0;
        symbol = "";
        magicNumber = -1;
        recoversignal = -1;
    }

    ~BaseRecovery() {
        
    }

    void doRecovery() {

    }

    void selectLastOrder()
    {

    }

    void takeProfit()
    {
        
    }

};