#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

void rpt_reportmsg(string msg) {
        Print(msg);
       if (IsTesting())
           return;
        string loginname = IntegerToString(AccountNumber());
        msg = loginname + ": " + msg;
        char post[], result[];
        string headers;
        int timeout = 5000;
        int res;
        string requesturl = "http://file.traland.com/telegram/msgmarquis.php?message=" + msg;
        //Print("URL:" + requesturl);
        res = WebRequest("GET", requesturl, NULL, NULL, timeout, post, 0, result, headers);
        //Print(res);
        if (res > -1) {}
        return;

}

void rpt_openedtrade(string curpair, int ordertype, string orderticket, double openprice, double lots, string tradeparam_str) {
    if (IsTesting())
    {
        return;
    }
    
    string tgmsg = StringFormat("%s x%.2f at %.5f", curpair, lots, openprice);
    rpt_reportmsg(tgmsg);

    string loginname = IntegerToString(AccountNumber());
    string url = "http://file.traland.com/mql4/reporttrade.php";
    string poststr = StringFormat("login=%s&curpair=%s&orderticket=%s&openprice=%f&lots=%f&ordertype=%d&tradeparam=%s",
    loginname, curpair, orderticket, openprice, lots, ordertype, tradeparam_str);
    char post[], result[];
    string headers;
    int timeout = 5000;
    int res;
    StringToCharArray(poststr, post, 0, StringLen(poststr));

    Print(url + " " + poststr);
    res = WebRequest("POST", url, NULL, timeout, post, result, headers);
    //Print(res);
    if (res > -1) {}
    return;

}

void rpt_closedtrade(string curpair, string orderticket, double closeprice, double swap, double commission, double profit)
{
    if (IsTesting())
    {
        return;
    }

    string loginname = IntegerToString(AccountNumber());
        string url = StringFormat("http://file.traland.com/mql4/reporttrade.php?login=%s&curpair=%s&orderticket=%s&closeprice=%f&orderswap=%f&ordercommission=%f&orderprofit=%f", 
        loginname, curpair, orderticket, closeprice, swap, commission, profit);
        char post[], result[];
        string headers;
        int timeout = 5000;
        int res;

        Print(url);
        res = WebRequest("GET", url, NULL, NULL, timeout, post, 0, result, headers);
        //Print(res);
        if (res > -1) {}
        return;

}

int rpt_lastindex = 0;
int rpt_ticketlist[] = { 0, 0, 0, 0, 0,    0, 0, 0, 0, 0,     0, 0, 0, 0, 0,      0, 0, 0, 0, 0 };

void rpt_syncclosedtrade()
{
    if (IsTesting())
    {
        return;
    }

    int selcount = 0;
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
    {
        OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
        selcount++;
        if (selcount > 30)
            break;
        bool ctrade = false;
        for (int itt = 0; itt < rpt_lastindex && itt < ArraySize(rpt_ticketlist); itt++)
        {
            if (rpt_ticketlist[itt] == OrderTicket())
                ctrade = true;
        }
        if (ctrade)
            continue;
        rpt_closedtrade(OrderSymbol(), IntegerToString(OrderTicket()), OrderClosePrice(), OrderSwap(), OrderCommission(), OrderProfit());
        rpt_ticketlist[rpt_lastindex] = OrderTicket();
        rpt_lastindex++;
        if (rpt_lastindex >= ArraySize(rpt_ticketlist))
            rpt_lastindex = 0;
    }

}

