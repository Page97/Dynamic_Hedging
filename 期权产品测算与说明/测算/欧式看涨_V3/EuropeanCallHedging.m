%   Description:
%   �ú�������ģ����ж�̬����Ͷ������з����ʲ����޷����ʲ�ͷ��Ӷ�����Delta��̬����ŷʽ������Ȩ�Ĺ���
%   Hedging Rules��
%   1. ����Delta��̬�Գ壬ʹ���ڻ���Լ�������ڻ���Լ�۸�ҹ���ŷʽ������Ȩ
%   2. ÿ�������յ��ս���
%   4. ��һ���趨Ϊ�����գ����һ�ղ����е��֡�
%   Note:
%   1. �ú���ʹ�ù̶�Ƶ�ʵ��ַ�ʽ
%   2. �ú����������ڻ��ĸ�ҹ���գ����ڶ��տ��̼۵���ǰһ�����̼ۣ�
%   Input:
%   OpenList-����ʲ����̼۵���ʱ����������
%   CloseList-����ʲ����̼۵���ʱ����������
%   SettleList-����ʲ�����۵���ʱ����������
%   K-��Ȩ��
%   sigma-����ʲ��۸���껯������
%   rf-�޷�������
%   rr-����������(�껯)
%   rp-������
%   netprincipal-�۳�ǰ�˷���֮��ı���
%   feerate-���������������ķ��ʣ��������+�йܷ��ʣ�
%   period-��Ʒ���ڣ���λ�������գ�
%   T-���ּ��ʱ�䣨����������λ�������գ�
%   depositrate-�ڻ��ı�֤����
%   tradedays-һ���н����յ�����
%   tradefee-���׵������ѣ�ÿ�֣�
%   Output:
%   PositionChart-ÿ�տ���ʱ�ڻ��˻��г��еĺ�Լ�����ı仯��
%   -���У�
%    ��һ�У�Ϊ�����
%    �ڶ��У����տ��̼�
%    �����У����տ���ʱ�ĺ�Լ����
%    �����У������ǰһ�շ����ı仯��
%   SettleAccount-ÿ�յĽ����˻���
%   -����
%    ��һ�У��������
%    �ڶ��У����ս����
%    �����У����ս���ʱ�ڻ��˻���Ȩ��
%    �����У��ڻ��˻���֤��
%    �����У��ڻ��˻��ܸ���ӯ��
%    �����У��ڻ��˻���ʵ��ӯ��
%    �����У��ڻ��˻������ʽ�
%    �ڰ��У��ڻ��˻���ȡ�ʽ�
%    �ھ��У��޷����˻��ʽ�
%    ��ʮ�У������ܼ�ֵ���ڻ��˻�Ȩ��+�޷����˻��ʽ�
%    ��ʮһ�У����ռ���������з���
%    ��ʮ���У�����ֵ���ڻ��˻�Ȩ��+�޷����˻��ʽ�-����Ĺ���Ѻ��йܷѣ�
%   Author:
%   PageZhao 20180522

function [PositionChart,SettleAccount]=EuropeanCallHedging(HedgeList,SettleList,TradeList,openprice,closeprice,hedgetime,K,sigma,rf,rr,rp,netprincipal,feerate,period,interval,depositrate,tradefee,tradedays)
BoardLot=zeros(1,period);   %���յ��ֺ�ʱӦ���е��ڻ�������
BoardLotVar=zeros(1,period);  %���յ�������

FuturesEquity=zeros(1,period); %ÿ�ս���ʱ�ڻ��˻�Ȩ��
Real=zeros(1,period);   %�ڻ��˻����ۼ�ƽ��ӯ��
RealChange=zeros(1,period);
Float=zeros(1,period); %�ڻ��˻����ۼƸ���ӯ��
FloatChange=zeros(1,period);
Deposit=zeros(1,period);  %�ڻ��˻���ռ�ñ�֤��
Available=zeros(1,period);  %�ڻ��˻��Ŀ����ʽ�
Drawable=zeros(1,period); %�ڻ��˻��Ŀ�ȡ�ʽ�
SafePos=zeros(1,period);    %ÿ�ս���ʱ�޷����ʲ�ͷ��ļ�ֵ
GrossValue=zeros(1,period);   %δ������õĻ����ֵ
Fee=zeros(1,period);    %������Ҫ����ķ���
NetValue=zeros(1,period);    %ÿ�ս���ʱ����ľ�ֵ

%����һ�Ž��׼�¼����һ�У�����ʱ�䣻�ڶ��У������������У�δƽ�������������У����׼۸�
TradeRecord=zeros(1,4); 

n=rp*netprincipal/openprice;  %��Ҫ������Ȩ�ķ���

SafePos0=((1+rr)*period/tradedays)/((1+rf)*period/tradedays)*netprincipal;  %����Ҫ��ı������ʿɼ����޷����˻���ͷ��
FuturesEquity0=netprincipal-SafePos;

%ģ���һ�յĶԳ����
delta1=EuropeanCallDelta(HedgeList(1,2),K,sigma,rf,(period-1+hedgetime)/tradedays);   %�ڳ���delta

BoardLot(1)=round(delta1*n);    %BoardLotΪ�������ͷ��Ϊ�������ͷ
BoardLotVar(1)=BoardLot(1);

if FuturesEquity0-tradefee*abs(BoardLot(1))<abs(BoardLot(1))*HedgeList(1,2)*depositrate %����һ�ο���ʱ�˻��Ŀ����ʽ𲻹�������ı�֤��
    if BoardLot(1)>=0
        BoardLot(1)=floor(FuturesEquity0/(depositrate*HedgeList(1,2)*depositrate));
        BoardLotVar(1)=BoardLot(1);
    else
        BoardLot(1)=-floor(FuturesEquity0/(depositrate*HedgeList(1,2)*depositrate));
        BoardLotVar(1)=BoardLot(1);
    end
end   
    
TradeRecord(1,:)=[1 BoardLotVar(1) BoardLotVar(1) TradeList(1,2)];   %���׼�¼��

%��һ�ս���ʱ�˻����
FloatChange(1)=BoardLot(1)*(SettleList(1,2)-TradeList(1,2));
Float(1)=FloatChange(1);
RealChange(1)=0;
Deposit(1)=abs(BoardLot(1))*SettleList(1,2)*depositrate;
FuturesEquity(1)=FuturesEquity0+Float(1)+RealChange(1);
Available(1)=FuturesEquity(1)-Deposit(1);
Drawable(1)=max(0,Available(1)-max(Float(1),0));
SafePos(1)=SafePos0*exp(rf*interval/tradedays);

if Available(1)<0
    disp ('wrong');
end
    
GrossValue(1)=FuturesEquity(1)+SafePos(1);
Fee(1)=GrossValue(1)*(feerate/tradedays);
NetValue(1)=GrossValue(1)-Fee(1);

for i=2:period-1
      
    if mod(i,interval)==0    %�ж��Ƿ�Ϊ������
        delta=EuropeanCallDelta(HedgeList(i,2),K,sigma,rf,(period-i+hedgetime)/tradedays); %�Ե�����ǰ�����̼���Ϊ�Գ�۸񲢼���Delta
        BoardLot(i)=round(delta*n);
        BoardLotVar(i)=BoardLot(i)-BoardLot(i-1); 
        
        
        %�迼�Ǹôε���ʱ�ֲ�������ϴε��ֵĳֲ����ޱ仯�����
        if BoardLotVar==0
            RealChange(i)=0;
            Real(i)=Real(i-1)+RealChange(i);
            Float(i)=sum((SettleList(i,2)-TradeRecord(:,4)).*(TradeRecord(:,3)));%���ճֲָ���ӯ��
            FloatChange(i)=Float(i)-Float(i-1);
            Deposit(i)=BoardLot(i)*SettleList(i,2)*depositrate;
            FuturesEquity(i)=FuturesEquity(i-1)+FloatChange(i)+RealChange(i);
            Available(i)=FuturesEquity(i)-Deposit(i);
            Drawable(i)=max(0,Available(i)-max(Float(i),0));
            SafePos(i)=SafePos(i-1)*exp(rf/tradedays);
            GrossValue(i)=FuturesEquity(i)+SafePos(i);
            Fee(i)=GrossValue(i)*(feerate/tradedays);
            NetValue(i)=GrossValue(i)-sum(Fee);
            continue;
        end
        
        if sign(BoardLotVar(i))==sign(BoardLotVar(i-1)) %���뷽����δƽ�ַ�����ͬ������Ҫƽ�֣�ֱ���½�һ���µĽ��׼�¼
            sz=size(TradeRecord);
            TradeRecord(sz(1)+1,:)=[i BoardLotVar(i) BoardLotVar(i) TradeList(i,2)];
        else %�����뷽����δƽ�ַ����෴���Ƚ���ƽ��
            boardchange=BoardLotVar(i); %����ƽ�ֵ�����Ϊboardchange
            RealChange(i)=0; %����ʼ�ĸ���ʵ��ӯ����Ϊ0
            sz=size(TradeRecord);
            for e=1:sz(1)
                if sign(TradeRecord(e,3)+boardchange)==sign(TradeRecord(e,3))                    
                    RealChange(i)=RealChange(i)+(-boardchange)*(TradeList(i,2)-TradeRecord(e,4));
                    TradeRecord(e,3)=TradeRecord(e,3)+boardchange;
                    boardchange=0;
                    break;
                else
                    RealChange(i)=RealChange(i)+TradeRecord(e,3)*(TradeList(i,2)-TradeRecord(e,4));
                    boardchange=boardchange+TradeRecord(e,3);
                    TradeRecord(e,3)=0;
                end
            end
            if boardchange~=0   %������ȫƽ�ֲ�����Ҫ���෴�ķ��򽨲֣������½�һ�����׼�¼
                TradeRecord(sz(1)+1,:)=[i boardchange boardchange TradeList(i,2)];
            end                               
        end
        
        Real(i)=Real(i-1)+RealChange(i);
        Float(i)=sum((SettleList(i,2)-TradeRecord(:,4)).*(TradeRecord(:,3)));%���ճֲָ���ӯ��
        FloatChange(i)=Float(i)-Float(i-1);
        Deposit(i)=abs(BoardLot(i))*SettleList(i,2)*depositrate;
        FuturesEquity(i)=FuturesEquity(i-1)+FloatChange(i)+RealChange(i);
        Available(i)=FuturesEquity(i)-Deposit(i);
        Drawable(i)=max(0,Available(i)-max(Float(i),0));
        SafePos(i)=SafePos(i-1)*exp(rf/tradedays);
        
        if Available(1)<0
            disp ('wrong');
        end
                
        GrossValue(i)=FuturesEquity(i)+SafePos(i);
        Fee(i)=GrossValue(i)*(feerate/tradedays);
        NetValue(i)=GrossValue(i)-sum(Fee);
    end
end

%���һ�ղ��ٵ���,����ʱ�����е��ڻ���Լȫ��ƽ��
BoardLot(period)=BoardLot(period-1);
BoardLotVar(period)=0;
RealChange(period)=sum((closeprice-TradeRecord(:,4)).*(TradeRecord(:,3)));
Real(period)=Real(period-1)+RealChange(period);
Float(period)=0;
FloatChange(period)=Float(period)-Float(period-1);
Deposit(period)=0;
FuturesEquity(period)=FuturesEquity(period-1)+FloatChange(period)+RealChange(period);
Available(period)=FuturesEquity(period)-Deposit(period);
Drawable(period)=max(0,Available(period)-max(Float(period),0));
SafePos(period)=SafePos(period-1)*exp(rf/tradedays);

GrossValue(period)=FuturesEquity(period)+SafePos(period);
Fee(period)=GrossValue(period)*(feerate/tradedays);
NetValue(period)=GrossValue(period)-sum(Fee);

%����PositionChart
PositionChart=[(1:period)',HedgeList(:,2),BoardLot',BoardLotVar'];

%����SettleAccount
SettleAccount=[(1:period)',SettleList(:,2),FuturesEquity',Deposit',Float',Real',Available',Drawable',SafePos',GrossValue',Fee',NetValue'];

end
