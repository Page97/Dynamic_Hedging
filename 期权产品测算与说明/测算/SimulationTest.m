%   Description:
%   �ýű�ʹ��ģ�����ݽ���Delta��̬�Գ�Ĳ���
%   Parameters:
%   principal-����
%   preserverate-������
%   rp-������
%   rf-�޷������ʣ��껯��
%   sigma-����ʲ��۸񲨶��ʣ��껯��
%   S0-����ʲ��ڳ��۸�1�֣�
%   K-��Ȩ��
%   period-��Ʒ�����ڣ���λ�������գ�
%   managerate-�������
%   salesrate-���۷���
%   trusteerate-�йܷ���
%   outsourcerate-�������
%   tradefee-����������(ÿ�֣�
%   interval-����ʱ��������λ�������գ�
%   positionrate-��λ
%   depositrate-��֤����
%   dt-ģ������·������֮���ʱ��������λ���գ�
%   tradedays-һ���н����յ�����
%   times-ģ��۸�·���Ĵ���
%   Author: 
%   PageZhao 20180522

%�趨����
principal=30000000;
preserverate=1;
rp=0.075;
rf=0.05;
sigma=0.3;
S0=270000;
K=270000*1.05;
period=21;%һ���£�21
managerate=0.015;
salesrate=0.005;
trusteerate=0.001;
outsourcerate=0.0005;
tradefee=10;
interval=1;
positionrate=0.5;
depositrate=0.05;
dt=1/225;
tradedays=250;
times=1000;
netprincipal=principal*(1-(outsourcerate+salesrate)*period/tradedays);

%ģ���times���۸�·�������������ԽС����ֹ�۸�ԽС
PathChart=MonteCarloSimulation(S0,(period/dt),(dt/tradedays),sigma,rf,times);
[Y,I]=sortrows(PathChart(:,2:times+1)',period/dt+1);
PathChart(:,2:times+1)=Y';

%���۸�仯·��ͼ
figure;
for i=1:times
   plot(dt*PathChart(:,1),PathChart(:,i+1))
   hold on;
end
xlabel('����')
ylabel('�ڻ���Լ�ļ۸�Ԫ��');

%��ÿһ�ּ۸�·����ģ�⶯̬�Գ�Ĺ���
Return=zeros(1,times);
IncreaseRate=zeros(1,times);
PriceList=zeros(period+1,2);
PriceList(:,1)=0:period;
for i=1:times
    %��ȡ�����̼ۡ����̼ۡ�����ۣ������ʹ�ø��յ�����ƽ��
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
    [PositionChart,SettleAccount]=EuropeanCallHedging(OpenList,CloseList,SettleList,K,sigma,rf,rp,netprincipal,period,interval,positionrate,depositrate,tradefee,tradedays);
    managementfee=(managerate/tradedays)*sum(SettleAccount(1:period,9),1);   %�������Ѱ�ÿ�վ�ֵ�ɱ�������
    trustfee=(trusteerate/tradedays)*sum(SettleAccount(1:period,9),1);   %�����йܷѰ�ÿ�վ�ֵ�ɱ�������
    endvalue=SettleAccount(period,9)-managementfee-trustfee;
    Return(i)=(tradedays/period)*((endvalue/principal)-1);
    IncreaseRate(i)=CloseList(period,2)/OpenList(1,2)-1;
end

%�����껯���������ʲ��۸�仯�ʵ�ɢ��ͼ
figure;
scatter(100*IncreaseRate,100*Return)
ylabel('�껯������(%)')
xlabel('����ʲ��۸�仯��(%)');



