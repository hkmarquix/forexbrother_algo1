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

    doRecovery() {
        
    }

};