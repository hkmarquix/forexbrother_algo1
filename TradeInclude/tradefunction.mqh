#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

void tf_closeAllOrders(string symbol, int magicNumber) {

    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != magicNumber || OrderSymbol() != symbol)
            continue;

        Print("Close this order @", i);
        OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, Red);
    }
}


void tf_createorder(string symbol, int ordertype, double lots, string orderi, string tradeparam, double stoploss, double takeprofit, string entrymethod, int magicNumber) {
    int ticket = 0;
    double price = 0;

    string comment = tf_commentencode(EA_NAME, entrymethod, orderi, tradeparam);

    //Print("new comment: " + comment);
    if (ordertype == OP_BUY) {
        price = MarketInfo(symbol, MODE_ASK);
        Print("Create buy order x" + DoubleToString(lots, 2));
        ticket = OrderSend(symbol, OP_BUY, lots, price, 3, stoploss, takeprofit, comment, magicNumber, 0, Blue);
    }
    if (ordertype == OP_SELL) {
        Print("Create sell order x" + DoubleToString(lots, 2));
        price = MarketInfo(symbol, MODE_BID);
        ticket = OrderSend(symbol, OP_SELL, lots, price, 3, stoploss, takeprofit, comment, magicNumber, 0, Red);
    }

    if (ticket > 0) {
        Print("Create success");
    } else {
        Alert(symbol + ": Failed to create order type: " + ordertype + " x" + lots + " at " + price + " " + GetLastError());
    }
}


int tf_getCurrencryMultipier(string symbol)
{
    double times = 1;
        for (int i = 0; i < MarketInfo(symbol, MODE_DIGITS); i++) {
            times *= 10;
        }
        return times;
}

bool tf_haszonecaprecoverorders(int magicnumber, string symbol) {
    int firsttype = -1;
    for (int i = 0; i < OrdersTotal(); i++) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != magicnumber || OrderSymbol() != symbol)
            continue;
        if (firsttype == -1)
            firsttype = OrderType();
        else if (firsttype != OrderType())
            return true;
    }
    return false;
}

int tf_countRecoveryCurPair(int magicnumber, string symbol) {
    int recoveryOrder = 0;
    for (int i = 0; i < ArraySize(curlist); i++) {
        string cur = curlist[i];
        int sameOrder = 0;
        for (int io = 0; io < OrdersTotal(); io++) {
            if (OrderMagicNumber() != magicnumber || OrderSymbol() != symbol)
                continue;
            sameOrder++;
        }

        if (sameOrder > 1)
            recoveryOrder++;
    }
    return recoveryOrder;
}

int tf_countOpenedCurPair(int magicnumber, string symbol) {
    int orderno = 0;
    for (int i = 0; i < ArraySize(curlist); i++) {
        string cur = curlist[i];
        int sameOrder = 0;
        for (int io = 0; io < OrdersTotal(); io++) {
            if (OrderMagicNumber() != magicnumber || OrderSymbol() != symbol)
                continue;
            sameOrder++;
        }

        if (sameOrder > 0)
            orderno++;
    }
    return orderno;
}

int tf_findMaxCommentOrder(string symbol, int magicnumber) {
    int maxComment = -1;
    for (int i = 0; i < OrdersTotal(); i++) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != magicnumber || OrderSymbol() != symbol)
            continue;

        string commentd[];
        tf_commentdecode(OrderComment(), commentd);
        if (ArraySize(commentd) != 4)
            continue;

        int curComment = StringToInteger(commentd[2]);
        if (curComment > maxComment)
            maxComment = curComment;
    }
    //Print(maxComment);
    return maxComment;
}

bool tf_findFirstOrder(string symbol, int magicnumber) {
    for (int i = 0; i < OrdersTotal(); i++) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != magicnumber || OrderSymbol() != symbol)
            continue;

        int curComment = StringToInteger(OrderComment());
        if (curComment == 1) {
            return true;
        }
    }
    return false;
}

string tf_commentencode(string message, string ea, int orderi, string remark)
{
    string comment = StringFormat("%s|%s|%d|%s", message, ea, orderi, remark);
    return comment;
}

void tf_commentdecode(string comment, string &result[])
{
    int resk = StringSplit(comment, StringGetCharacter("|", 0), result);
}

int tf_countAllOrders(string symbol, int magicnumber) {
    int torder = 0;
    for (int i = 0; i < OrdersTotal(); i++) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() == magicnumber && OrderSymbol() == symbol)
            torder++;
    }
    return torder;
}

double tf_orderTotalProfit(string symbol, int magicnumber)
{
    double tprofit = 0;
    for (int i = 0; i < OrdersTotal(); i++) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != magicnumber || OrderSymbol() != symbol)
            continue;
        tprofit += OrderProfit() + OrderSwap() + OrderCommission();
    }
    return tprofit;
}
