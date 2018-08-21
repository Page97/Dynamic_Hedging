%Draft
PathChart=MonteCarloSimulation(10000,21,1/250,0.3,0.04,1);
OpenList=[(1:21)',PathChart(1:21,2)];
CloseList=[(1:21)',PathChart(2:22,2)];
SettleList=CloseList;
[PositionChart,SettleAccount]=KnockOutCallHedging(OpenList,CloseList,SettleList,10000,11000,0,0.3,0.04,0.06,30000000,21,1,0.5,0.05,10,250);
format long g;
disp (PositionChart);
format long g;
disp (SettleAccount);

