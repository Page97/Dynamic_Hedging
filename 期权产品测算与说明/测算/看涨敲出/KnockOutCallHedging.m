%   Description:
%   �ú�������ģ����ж�̬����Ͷ������з����ʲ����޷����ʲ�ͷ��Ӷ�����Delta��̬���ƿ����ó���Ȩ
%   Hedging Rules��
%   1. ����Delta��̬�Գ壬ʹ���ڻ���Լ�������ڻ���Լ�۸�ҹ��Ŀ����ó���Ȩ
%   2. �ڻ��˻����趨һ���Ĳ�λ��ÿ�ս���ʱ��Ȩ��С�ڱ�֤��²�λ������Ҫ�����޷����˻����㱣֤��������ʱ�۳���ȥ�ʽ����Ȩ���Դ��ڱ�֤��²�λ����ȡ���˻��еı�֤������޷����˻�
%   3. ÿ��������һ���̽��е��֣��Գ�۸�Ϊǰһ�յ����̼�
%   4. ��һ���趨Ϊ�����գ����һ�ղ����е��֡�
%   Note:
%   1. �ú���ʹ�ù̶�Ƶ�ʵ��ַ�ʽ
%   2. �ú����������ڻ��ĸ�ҹ���գ����ڶ��տ��̼۵���ǰһ�����̼ۣ�
%   Input:
%   OpenList-����ʲ����̼۵���ʱ����������
%   CloseList-����ʲ����̼۵���ʱ����������
%   SettleList-����ʲ�����۵���ʱ����������
%   K-��Ȩ��
%   H-�ó��ۣ���ֵ���ǰٷֱȣ�
%   sigma-����ʲ��۸���껯������
%   rf-�޷�������
%   rp-������
%   netprincipal-�۳�ǰ�˷���֮��ı���
%   period-��Ʒ���ڣ���λ�������գ�
%   T-���ּ��ʱ�䣨����������λ�������գ�
%   positionrate-�ڻ��Ĳ�λ
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
%    �����У���֤��
%    �����У����ս���ʱ�ڻ��˻���Ȩ��
%    �����У��ڻ��˻��ܸ���ӯ��
%    �����У��ڻ��˻���ʵ��ӯ��
%    �����У��ڻ��˻������ʽ�
%    �ڰ��У��ڻ��˻���ȡ�ʽ�
%    �ھ��У��޷����˻��ʽ�
%    ��ʮ�У������ܾ�ֵ���ڻ��˻�Ȩ��+�޷����˻��ʽ�
%   Author:
%   PageZhao 20180522

function [PositionChart,SettleAccount]=KnockOutCallHedging(OpenList,CloseList,SettleList,K,H,E,sigma,rf,rp,netprincipal,period,interval,positionrate,depositrate,tradefee,tradedays)
BoardLot=zeros(1,period);   %����ʱ�����ڻ�������
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

%����һ�Ž��׼�¼����һ�У�����ʱ�䣻�ڶ��У������������У�δƽ�������������У����׼۸�
TradeRecord=zeros(1,4); 

%��һ��PositionChart���
S0=OpenList(1,2);  %����ʲ��ڳ��۸�
delta0=KnockOutCallDelta(S0,K,H,E,sigma,rf,period/tradedays);   %�ڳ���delta
n=rp*netprincipal/S0;  %��Ҫ������Ȩ�ķ���
BoardLot(1)=round(delta0*n);    %BoardLotΪ�������ͷ��Ϊ�������ͷ
BoardLotVar(1)=BoardLot(1);
TradeRecord(1,:)=[1 BoardLotVar(1) BoardLotVar(1) S0];   %���׼�¼��

%��һ�տ�����ɵ���ʱ�˻����
Deposit0=abs(BoardLot(1))*S0*depositrate;
FuturesEquity0=Deposit0/positionrate-tradefee*BoardLotVar(1);
SafePos0=netprincipal-(FuturesEquity0+tradefee*BoardLotVar(1));

%��һ�ս���ʱ�˻����
FloatChange(1)=BoardLot(1)*(SettleList(1,2)-S0);
Float(1)=FloatChange(1);
RealChange(1)=0;
Deposit(1)=abs(BoardLot(1))*SettleList(1,2)*depositrate;
FuturesEquity(1)=FuturesEquity0+Float(1)+RealChange(1);
Available(1)=FuturesEquity(1)-Deposit(1);
Drawable(1)=max(0,Available(1)-max(Float(1),0));
SafePos(1)=SafePos0*exp(rf*interval/tradedays);

%��Ȩ��С�ڱ�֤��²�λ������Ҫ�����޷����˻����㱣֤��
if FuturesEquity(1)<Deposit(1)/positionrate
    increase=Deposit(1)/positionrate-FuturesEquity(1);
    FuturesEquity(1)=FuturesEquity(1)+increase;
    Available(1)=Available(1)+increase;
    Drawable(1)=max(0,Available(1)-max(Float(1),0));
    SafePos(1)=SafePos(1)-increase;
end

%������ʱ�۳���ȥ�ʽ����Ȩ���Դ��ڱ�֤��²�λ����ȡ���˻��еı�֤������޷����˻�
if FuturesEquity(1)-Drawable(1)>Deposit(1)/positionrate
    out=Drawable(1);
    Drawable(1)=0;
    Available(1)=Available(1)-out;
    FuturesEquity(1)=FuturesEquity(1)-out;
    SafePos(1)=SafePos(1)+out;
end

for i=2:period-1
      
    if mod(i-1,interval)==0    %�ж��Ƿ�Ϊ������
        delta=KnockOutCallDelta(CloseList(i-1,2),K,H,E,sigma,rf,(period-i+1)/tradedays); %�Ե�����ǰ�����̼���Ϊ�Գ�۸񲢼���Delta
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
            continue;
        end
        
        if sign(BoardLotVar(i))==sign(BoardLotVar(i-1)) %���뷽����δƽ�ַ�����ͬ������Ҫƽ�֣�ֱ���½�һ���µĽ��׼�¼
            sz=size(TradeRecord);
            TradeRecord(sz(1)+1,:)=[i BoardLotVar(i) BoardLotVar(i) OpenList(i,2)];
        else %�����뷽����δƽ�ַ����෴���Ƚ���ƽ��
            boardchange=BoardLotVar(i); %����ƽ�ֵ�����Ϊboardchange
            RealChange(i)=0; %����ʼ�ĸ���ʵ��ӯ����Ϊ0
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
            if boardchange~=0   %������ȫƽ�ֲ�����Ҫ���෴�ķ��򽨲֣������½�һ�����׼�¼
                TradeRecord(sz(1)+1,:)=[i boardchange boardchange OpenList(i,2)];
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
        
        %��Ȩ��С�ڱ�֤��²�λ������Ҫ�����޷����˻����㱣֤��
        if FuturesEquity(i)<Deposit(i)/positionrate
            increase=Deposit(i)/positionrate-FuturesEquity(i);
            FuturesEquity(i)=FuturesEquity(i)+increase;
            Available(i)=Available(i)+increase;
            Drawable(i)=max(0,Available(i)-max(Float(i),0));
            SafePos(i)=SafePos(i)-increase;
        end
        
        %������ʱ�۳���ȥ�ʽ����Ȩ���Դ��ڱ�֤��²�λ����ȡ���˻��еı�֤������޷����˻�
        if FuturesEquity(i)-Drawable(i)>Deposit(i)/positionrate
            out=Drawable(i);
            Drawable(i)=0;
            Available(i)=Available(i)-out;
            FuturesEquity(i)=FuturesEquity(i)-out;
            SafePos(i)=SafePos(i)+out;
        end
        
        % ��K>H,��ֱ���ó�
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
        Float(i)=sum((SettleList(i,2)-TradeRecord(:,4)).*(TradeRecord(:,3)));%���ճֲָ���ӯ��
        FloatChange(i)=Float(i)-Float(i-1);
        Deposit(i)=abs(BoardLot(i))*SettleList(i,2)*depositrate;
        FuturesEquity(i)=FuturesEquity(i-1)+FloatChange(i)+RealChange(i);
        Available(i)=FuturesEquity(i)-Deposit(i);
        Drawable(i)=max(0,Available(i)-max(Float(i),0));
        SafePos(i)=SafePos(i-1)*exp(rf/tradedays);
       
        %��Ȩ��С�ڱ�֤��²�λ������Ҫ�����޷����˻����㱣֤��
        if FuturesEquity(i)<Deposit(i)/positionrate
            increase=Deposit(i)/positionrate-FuturesEquity(i);
            FuturesEquity(i)=FuturesEquity(i)+increase;
            Available(i)=Available(i)+increase;
            Drawable(i)=max(0,Available(i)-max(Float(i),0));
            SafePos(i)=SafePos(i)-increase;
        end
        
        %������ʱ�۳���ȥ�ʽ����Ȩ���Դ��ڱ�֤��²�λ����ȡ���˻��еı�֤������޷����˻�
        if FuturesEquity(i)-Drawable(i)>Deposit(i)/positionrate
            out=Drawable(i);
            Drawable(i)=0;
            Available(i)=Available(i)-out;
            FuturesEquity(i)=FuturesEquity(i)-out;
            SafePos(i)=SafePos(i)+out;
        end    
    end
end

%���һ�ղ��ٵ���,����ʱ�����е��ڻ���Լȫ��ƽ��
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

%����PositionChart
PositionChart=[(1:period)',OpenList(:,2),BoardLot',BoardLotVar'];

%����SettleAccount
SettleAccount=[(1:period)',SettleList(:,2),FuturesEquity',Deposit',Float',Real',Available',Drawable',SafePos',(FuturesEquity+SafePos)'];

end

