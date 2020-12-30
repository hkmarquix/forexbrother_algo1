#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

bool of_selectlastorder(string symbol, int magicNumber) {

    int maxorderi = -1; 
    int lastpos = -1;
    string cstr = "";

    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != magicNumber || OrderSymbol() != symbol)
            continue;
        if (!(OrderType() == OP_BUY || OrderType() == OP_SELL))
            continue;

        string param[];
        tf_commentdecode(OrderComment(), param);

        cstr += param[2] + ",";

        int orderi = StrToInteger(param[2]);
        if (orderi > maxorderi) {
            maxorderi = orderi;
            lastpos = i;
        }
    }

    if (lastpos > -1)
    {
        //Print(cstr + " ::: " + maxorderi + ":: " + lastpos);
        OrderSelect(lastpos, SELECT_BY_POS, MODE_TRADES);
        return true;
    }
    return false;
}

bool of_selectlastclosedorder(string symbol, int magicNumber) {

    int maxorderi = -1; 
    int lastpos = -1;
    string cstr = "";

    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
        OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
        if (OrderMagicNumber() != magicNumber || OrderSymbol() != symbol)
            continue;
        if (!(OrderType() == OP_BUY || OrderType() == OP_SELL))
            continue;

        return true;
    }

    return false;
}

bool of_selectfirstorder(string symbol, int magicNumber)
{
    return of_selectrecoverypair(symbol, magicNumber, 1, 0);
}

bool of_selectrecoverypair(string symbol, int magicNumber, int pair_i, int pair_offset)
{
    int norderi = 0;
    if (pair_i > 1)
    {
        norderi = (pair_i - 1) * 2 + 1;
    }
    else
    {
        norderi = pair_i;
    }
    norderi = norderi + pair_offset;

    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() != magicNumber || OrderSymbol() != symbol)
            continue;
        if (!(OrderType() == OP_BUY || OrderType() == OP_SELL))
            continue;

        string param[];
        tf_commentdecode(OrderComment(), param);

        int orderi = StrToInteger(param[2]);
        if (orderi == norderi) {
            return true;    
        }
    }

    return false;
}


int of_getcurrencrymultipier(string symbol)
{
    double times = 1;
        for (int i = 0; i < MarketInfo(symbol, MODE_DIGITS); i++) {
            times *= 10;
        }
        return times;
}
