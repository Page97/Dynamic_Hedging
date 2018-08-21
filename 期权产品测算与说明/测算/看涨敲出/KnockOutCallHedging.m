%   Description:
%   该函数用来模拟进行动态调整投资组合中风险资产与无风险资产头寸从而进行Delta动态复制看涨敲出期权
%   Hedging Rules：
%   1. 采用Delta动态对冲，使用期货合约复制与期货合约价格挂钩的看涨敲出期权
%   2. 期货账户会设定一定的仓位，每日结算时若权益小于保证金÷仓位，则需要动用无风险账户补足保证金；若结算时扣除可去资金后总权益仍大于保证金÷仓位，则取出账户中的保证金放入无风险账户
%   3. 每个调仓日一开盘进行调仓，对冲价格为前一日的收盘价
%   4. 第一日设定为调仓日；最后一日不进行调仓。
%   Note:
%   1. 该函数使用固定频率调仓方式
%   2. 该函数不考虑期货的隔夜风险（即第二日开盘价等于前一日收盘价）
%   Input:
%   OpenList-标的资产开盘价的日时间序列数据
%   CloseList-标的资产收盘价的日时间序列数据
%   SettleList-标的资产结算价的日时间序列数据
%   K-行权价
%   H-敲出价（数值，非百分比）
%   sigma-标的资产价格的年化波动率
%   rf-无风险利率
%   rp-参与率
%   netprincipal-扣除前端费用之后的本金
%   period-产品周期（单位：交易日）
%   T-调仓间隔时间（整数）（单位：交易日）
%   positionrate-期货的仓位
%   depositrate-期货的保证金率
%   tradedays-一年中交易日的数量
%   tradefee-交易的手续费（每手）
%   Output:
%   PositionChart-每日开盘时期货账户中持有的合约份数的变化表
%   -其中：
%    第一列：为日序号
%    第二列：当日开盘价
%    第三列：当日开盘时的合约份数
%    第四列：相对于前一日份数的变化量
%   SettleAccount-每日的结算账户表
%   -其中
%    第一列：天数序号
%    第二列：当日结算价
%    第三列：保证金
%    第四列：当日结算时期货账户总权益
%    第五列：期货账户总浮动盈亏
%    第六列：期货账户总实际盈亏
%    第七列：期货账户可用资金
%    第八列：期货账户可取资金
%    第九列：无风险账户资金
%    第十列：基金总净值（期货账户权益+无风险账户资金）
%   Author:
%   PageZhao 20180522

function [PositionChart,SettleAccount]=KnockOutCallHedging(OpenList,CloseList,SettleList,K,H,E,sigma,rf,rp,netprincipal,period,interval,positionrate,depositrate,tradefee,tradedays)
BoardLot=zeros(1,period);   %开盘时持有期货的手数
BoardLotVar=zeros(1,period);  %当日调仓手数


FuturesEquity=zeros(1,period); %每日结算时期货账户权益
Real=zeros(1,period);   %期货账户的累计平仓盈亏
RealChange=zeros(1,period);
Float=zeros(1,period); %期货账户的累计浮动盈亏
FloatChange=zeros(1,period);
Deposit=zeros(1,period);  %期货账户的占用保证金
Available=zeros(1,period);  %期货账户的可用资金
Drawable=zeros(1,period); %期货账户的可取资金
SafePos=zeros(1,period);    %每日结算时无风险资产头寸的价值

%创建一张交易记录表（第一列：交易时间；第二列：手数，第三列：未平仓手数；第四列：交易价格）
TradeRecord=zeros(1,4); 

%第一日PositionChart情况
S0=OpenList(1,2);  %标的资产期初价格
delta0=KnockOutCallDelta(S0,K,H,E,sigma,rf,period/tradedays);   %期初的delta
n=rp*netprincipal/S0;  %需要复制期权的份数
BoardLot(1)=round(delta0*n);    %BoardLot为正代表多头，为负代表空头
BoardLotVar(1)=BoardLot(1);
TradeRecord(1,:)=[1 BoardLotVar(1) BoardLotVar(1) S0];   %交易记录表

%第一日开盘完成调仓时账户情况
Deposit0=abs(BoardLot(1))*S0*depositrate;
FuturesEquity0=Deposit0/positionrate-tradefee*BoardLotVar(1);
SafePos0=netprincipal-(FuturesEquity0+tradefee*BoardLotVar(1));

%第一日结算时账户情况
FloatChange(1)=BoardLot(1)*(SettleList(1,2)-S0);
Float(1)=FloatChange(1);
RealChange(1)=0;
Deposit(1)=abs(BoardLot(1))*SettleList(1,2)*depositrate;
FuturesEquity(1)=FuturesEquity0+Float(1)+RealChange(1);
Available(1)=FuturesEquity(1)-Deposit(1);
Drawable(1)=max(0,Available(1)-max(Float(1),0));
SafePos(1)=SafePos0*exp(rf*interval/tradedays);

%若权益小于保证金÷仓位，则需要动用无风险账户补足保证金
if FuturesEquity(1)<Deposit(1)/positionrate
    increase=Deposit(1)/positionrate-FuturesEquity(1);
    FuturesEquity(1)=FuturesEquity(1)+increase;
    Available(1)=Available(1)+increase;
    Drawable(1)=max(0,Available(1)-max(Float(1),0));
    SafePos(1)=SafePos(1)-increase;
end

%若结算时扣除可去资金后总权益仍大于保证金÷仓位，则取出账户中的保证金放入无风险账户
if FuturesEquity(1)-Drawable(1)>Deposit(1)/positionrate
    out=Drawable(1);
    Drawable(1)=0;
    Available(1)=Available(1)-out;
    FuturesEquity(1)=FuturesEquity(1)-out;
    SafePos(1)=SafePos(1)+out;
end

for i=2:period-1
      
    if mod(i-1,interval)==0    %判断是否为调仓日
        delta=KnockOutCallDelta(CloseList(i-1,2),K,H,E,sigma,rf,(period-i+1)/tradedays); %以调仓日前日收盘价作为对冲价格并计算Delta
        BoardLot(i)=round(delta*n);
        BoardLotVar(i)=BoardLot(i)-BoardLot(i-1);
        
        %需考虑该次调仓时持仓量相对上次调仓的持仓量无变化的情况
        if BoardLotVar==0
            RealChange(i)=0;
            Real(i)=Real(i-1)+RealChange(i);
            Float(i)=sum((SettleList(i,2)-TradeRecord(:,4)).*(TradeRecord(:,3)));%当日持仓浮动盈亏
            FloatChange(i)=Float(i)-Float(i-1);
            Deposit(i)=BoardLot(i)*SettleList(i,2)*depositrate;
            FuturesEquity(i)=FuturesEquity(i-1)+FloatChange(i)+RealChange(i);
            Available(i)=FuturesEquity(i)-Deposit(i);
            Drawable(i)=max(0,Available(i)-max(Float(i),0));
            SafePos(i)=SafePos(i-1)*exp(rf/tradedays);
            continue;
        end
        
        if sign(BoardLotVar(i))==sign(BoardLotVar(i-1)) %买入方向与未平仓方向相同，不需要平仓，直接新建一条新的交易记录
            sz=size(TradeRecord);
            TradeRecord(sz(1)+1,:)=[i BoardLotVar(i) BoardLotVar(i) OpenList(i,2)];
        else %需买入方向与未平仓方向相反，先进行平仓
            boardchange=BoardLotVar(i); %将待平仓的量设为boardchange
            RealChange(i)=0; %将初始的该日实际盈亏设为0
            sz=size(TradeRecord);
            for e=1:sz(1)
                if sign(TradeRecord(e,3)+boardchange)==sign(TradeRecord(e,3))                    
                    RealChange(i)=RealChange(i)+(-boardchange)*(OpenList(i,2)-TradeRecord(e,4));
                    TradeRecord(e,3)=TradeRecord(e,3)+boardchange;
                    boardchange=0;
                    break;
                else
                    RealChange(i)=RealChange(i)+TradeRecord(e,3)*(OpenList(i,2)-TradeRecord(e,4));
                    boardchange=boardchange+TradeRecord(e,3);
                    TradeRecord(e,3)=0;
                end
            end
            if boardchange~=0   %若已完全平仓并且需要向相反的方向建仓，则需新建一条交易记录
                TradeRecord(sz(1)+1,:)=[i boardchange boardchange OpenList(i,2)];
            end                               
        end
        
        Real(i)=Real(i-1)+RealChange(i);
        Float(i)=sum((SettleList(i,2)-TradeRecord(:,4)).*(TradeRecord(:,3)));%当日持仓浮动盈亏
        FloatChange(i)=Float(i)-Float(i-1);
        Deposit(i)=abs(BoardLot(i))*SettleList(i,2)*depositrate;
        FuturesEquity(i)=FuturesEquity(i-1)+FloatChange(i)+RealChange(i);
        Available(i)=FuturesEquity(i)-Deposit(i);
        Drawable(i)=max(0,Available(i)-max(Float(i),0));
        SafePos(i)=SafePos(i-1)*exp(rf/tradedays);
        
        %若权益小于保证金÷仓位，则需要动用无风险账户补足保证金
        if FuturesEquity(i)<Deposit(i)/positionrate
            increase=Deposit(i)/positionrate-FuturesEquity(i);
            FuturesEquity(i)=FuturesEquity(i)+increase;
            Available(i)=Available(i)+increase;
            Drawable(i)=max(0,Available(i)-max(Float(i),0));
            SafePos(i)=SafePos(i)-increase;
        end
        
        %若结算时扣除可去资金后总权益仍大于保证金÷仓位，则取出账户中的保证金放入无风险账户
        if FuturesEquity(i)-Drawable(i)>Deposit(i)/positionrate
            out=Drawable(i);
            Drawable(i)=0;
            Available(i)=Available(i)-out;
            FuturesEquity(i)=FuturesEquity(i)-out;
            SafePos(i)=SafePos(i)+out;
        end
        
        % 若K>H,则直接敲出
        if CloseList(i-1,2)>H
            for j=i+1:period-1
                BoardLot(j)=BoardLot(j-1);
                BoardLotVar(j)=0;
                FuturesEquity(j)=0;
                Deposit(j)=0;
                Float(j)=Float(j-1);
                Real(j)=Real(j-1);
                Available(j)=Available(j-1);
                Drawable(j)=Drawable(j-1);
                SafePos(j)=SafePos(j-1)*exp(rf/tradedays);
            end
            break;
        end
   
    else
        BoardLot(i)=BoardLot(i-1);
        BoardLotVar(i)=0;
        
        RealChange(i)=0;
        Real(i)=Real(i-1)+RealChange(i);
        Float(i)=sum((SettleList(i,2)-TradeRecord(:,4)).*(TradeRecord(:,3)));%当日持仓浮动盈亏
        FloatChange(i)=Float(i)-Float(i-1);
        Deposit(i)=abs(BoardLot(i))*SettleList(i,2)*depositrate;
        FuturesEquity(i)=FuturesEquity(i-1)+FloatChange(i)+RealChange(i);
        Available(i)=FuturesEquity(i)-Deposit(i);
        Drawable(i)=max(0,Available(i)-max(Float(i),0));
        SafePos(i)=SafePos(i-1)*exp(rf/tradedays);
       
        %若权益小于保证金÷仓位，则需要动用无风险账户补足保证金
        if FuturesEquity(i)<Deposit(i)/positionrate
            increase=Deposit(i)/positionrate-FuturesEquity(i);
            FuturesEquity(i)=FuturesEquity(i)+increase;
            Available(i)=Available(i)+increase;
            Drawable(i)=max(0,Available(i)-max(Float(i),0));
            SafePos(i)=SafePos(i)-increase;
        end
        
        %若结算时扣除可去资金后总权益仍大于保证金÷仓位，则取出账户中的保证金放入无风险账户
        if FuturesEquity(i)-Drawable(i)>Deposit(i)/positionrate
            out=Drawable(i);
            Drawable(i)=0;
            Available(i)=Available(i)-out;
            FuturesEquity(i)=FuturesEquity(i)-out;
            SafePos(i)=SafePos(i)+out;
        end    
    end
end

%最后一日不再调仓,收盘时将持有的期货合约全部平仓
BoardLot(period)=BoardLot(period-1);
BoardLotVar(period)=0;
RealChange(period)=sum((CloseList(period,2)-TradeRecord(:,4)).*(TradeRecord(:,3)));
Real(period)=Real(period-1)+RealChange(period);
Float(period)=0;
FloatChange(period)=Float(period)-Float(period-1);
Deposit(period)=0;
FuturesEquity(period)=FuturesEquity(period-1)+FloatChange(period)+RealChange(period);
Available(period)=FuturesEquity(period)-Deposit(period);
Drawable(period)=max(0,Available(period)-max(Float(period),0));
SafePos(period)=SafePos(period-1)*exp(rf/tradedays);

%生成PositionChart
PositionChart=[(1:period)',OpenList(:,2),BoardLot',BoardLotVar'];

%生成SettleAccount
SettleAccount=[(1:period)',SettleList(:,2),FuturesEquity',Deposit',Float',Real',Available',Drawable',SafePos',(FuturesEquity+SafePos)'];

end

