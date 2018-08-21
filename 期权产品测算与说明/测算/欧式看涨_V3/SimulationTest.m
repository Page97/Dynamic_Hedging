%   Description:
%   该脚本使用模拟数据进行Delta动态对冲的测算
%   Parameters:
%   code-挂钩资产代码
%   principal-本金
%   preserverate-保本率
%   rp-参与率
%   rf-无风险利率（年化）
%   sigma0-标的资产价格的历史波动率（年化）（用于生成价格路径）
%   sigma-对冲所使用的波动率
%   S0-标的资产期初价格（1手）
%   K-行权价
%   period-产品存续期（单位：交易日）
%   managementrate-管理费率
%   salesrate-销售费率
%   trusteerate-托管费率
%   outsourcerate-外包费率
%   tradefee-交易手续费(每手）
%   interval-调仓时间间隔（单位：交易日）
%   positionrate-仓位
%   depositrate-保证金率
%   dt-模拟生成路径步数之间的时间间隔（单位：日）
%   tradedays-一年中交易日的数量
%   times-模拟价格路径的次数
%   Author: 
%   PageZhao 20180522

%% 设定挂钩资产并获取历史价格波动率（年化）
code='AU1812.SHF';
% 参考：
% 上交所黄金1812-'AU1812.SHF'
tradedays=250;  %设定一年交易日数量（即波动率年化系数）
calculationtime=180; %设定历史价格观察期限
time=datestr(now-1,'yyyy-mm-dd'); %产品开始时间默认为今天
[sigma0,S0]=DataFetcher(code,time,calculationtime,tradedays);
disp(sigma0);

%% 设定产品相关参数
principal=30000000;
preserverate=1;
rp=0.05;
rf=0.05;
sigma=sigma0; %假设为理想状况，即对冲所使用的波动率即为历史波动率 
K=S0*1.025;
period=21; %一个月：21
managementrate=0.015;
salesrate=0.005;
trusteerate=0.001;
outsourcerate=0.0005;
tradefee=10;
interval=1;
positionrate=0.5;
depositrate=0.05;
dt=1/225;
times=10000;
netprincipal=principal*(1-(outsourcerate+salesrate)*period/tradedays);

%% 模拟出times条价格路径并排序，列序号越小则终止价格越小
PathChart=MonteCarloSimulation(S0,(period/dt),(dt/tradedays),sigma0,rf,times);
[Y,I]=sortrows(PathChart(:,2:times+1)',period/dt+1);
PathChart(:,2:times+1)=Y';
clear Y;

%% 画价格变化路径图
figure;
for i=1:times
   plot(dt*PathChart(:,1),PathChart(:,i+1))
   hold on;
end
xlabel('天数')
ylabel('期货合约的价格（元）')
xlim([0 period]);

%% 对每一种价格路径，模拟动态对冲的过程
Return=zeros(1,times);
IncreaseRate=zeros(1,times);
Cost=zeros(1,times);
PriceList=zeros(period+1,2);
PriceList(:,1)=0:period;
for i=times:times
    %提取出开盘价、收盘价、结算价，结算价使用该日的算术平均
    OpenList=zeros(period,2);
    OpenList(:,1)=1:period;
    CloseList=zeros(period,2);
    CloseList(:,1)=1:period;
    SettleList=zeros(period,2);
    SettleList(:,1)=1:period;
    for e=1:period
        OpenList(e,2)=PathChart((e-1)/dt+1,i+1);
        CloseList(e,2)=PathChart(e/dt+1,i+1);
        SettleList(e,2)=mean(PathChart((e-1)/dt+1:e/dt+1,i+1));
    end
    [PositionChart,SettleAccount]=EuropeanCallHedging(OpenList,CloseList,SettleList,K,sigma,rf,rp,netprincipal,(managementrate+trusteerate),period,interval,positionrate,depositrate,tradefee,tradedays);
    Return(i)=(tradedays/period)*((SettleAccount(period,12)/principal)-1);
    Cost(i)=netprincipal*exp(rf*period/tradedays)+(rp*netprincipal/S0)*max(CloseList(period,2)-K,0)-SettleAccount(period,12);
    IncreaseRate(i)=CloseList(period,2)/OpenList(1,2)-1;
    disp(PositionChart);
    disp(SettleAccount);
end


%% 绘制年化收益率与资产价格变化率的散点图
figure;
scatter(100*IncreaseRate,100*Return)
ylabel('年化收益率(%)')
xlabel('标的资产期末价格/期初价格(%)');

%% 绘制复制成本与资产价格变化率的散点图
figure;
scatter(100*IncreaseRate,Cost)
ylabel('复制成本')
xlabel('标的资产期末价格/期初价格(%)');

figure;
scatter(100*IncreaseRate,100*Cost/principal)
ylabel('标准化后的复制成本(%)')
xlabel('标的资产期末价格/期初价格(%)');

