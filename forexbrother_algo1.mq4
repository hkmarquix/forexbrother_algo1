//+------------------------------------------------------------------+
//|                                               synceatoserver.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "config.mqh"
#include "TradeInclude\tradefunction.mqh"
#include "TradeInclude\orderfunction.mqh"
#include "TradeInclude\TradeHelper.mqh"




int default_magicNumber = 18291;
double closeprice = 0.0;
bool keepsilence = false;

int processOrders = 0;

TradeHelper *tHelper;
TradeHelper *curPairs[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    initCurPair();

   if (IsTesting())
    keepsilence = true;
//---
   return(INIT_SUCCEEDED);
  }
  
  void initCurPair()
  {
      
      ArrayResize(curPairs, ArraySize(curlist), 0);
      if (IsTesting())
        ArrayResize(curPairs, 1, 0);
      for (int i = 0; i < ArraySize(curlist); i++)
      {
         string cur = curlist[i];
         tHelper = new TradeHelper();
         tHelper.magicNumber = default_magicNumber;
         tHelper.symbol = cur;
         tHelper.period = curperiod[i];
         tHelper.trademode = curtrademode[i];
         tHelper.initHelper();
         curPairs[i] = tHelper;

         Print("TradeHelper init: " + cur + "/" + curperiod[i]);

         if (IsTesting())
           break;
      }
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
    for (int i = 0; i < ArraySize(curPairs); i++)
    {
      TradeHelper *th = (TradeHelper *)curPairs[i];
      delete(th);
    }
   ArrayFree(curPairs);
   ObjectsDeleteAll();
  }


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
    if (processOrders == 1)
      return;
    processOrders = 1;
    for (int i = 0; i < ArraySize(curPairs); i++)
      {
         TradeHelper *tHelper = curPairs[i];
         tHelper.refreshRobot();
      }
    
    processOrders = 0;

  }

