
class TradeMaster {
    private:

    public:
        string symbol;
        int period;
        datetime signalValidUntilTime;
        string tradeparam;
        int entrysignal;
        int trailingsignal;
        int closesignal;
        int recoverysignal;

    TradeMaster() {
        symbol = "";
        period = PERIOD_M15;
        signalValidUntilTime = TimeCurrent();
        tradeparam = "";
        entrysignal = -1;
        trailingsignal = -1;
        closesignal = -1;
        recoverysignal = -1;
    }

    ~TradeMaster() {

    }

    void checkEntrySignal() {

    }

    void checkTrailingSignal()
    {

    }

    void checkCloseSignal()
    {

    }

    void checkRecoverySignal()
    {

    }

};