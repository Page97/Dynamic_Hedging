%   Description:
%   �ýű�ʹ��ģ�����ݽ���Delta��̬�Գ�Ĳ���
%   Parameters:
%   code-�ҹ��ʲ�����
%   principal-����
%   preserverate-������
%   rp-������
%   rf-�޷������ʣ��껯��
%   sigma0-����ʲ��۸����ʷ�����ʣ��껯�����������ɼ۸�·����
%   sigma-�Գ���ʹ�õĲ�����
%   S0-����ʲ��ڳ��۸�1�֣�
%   K-��Ȩ��
%   period-��Ʒ�����ڣ���λ�������գ�
%   managementrate-�������
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

%% �趨�ҹ��ʲ�����ȡ��ʷ�۸񲨶��ʣ��껯��
code='AU1812.SHF';
% �ο���
% �Ͻ����ƽ�1812-'AU1812.SHF'
tradedays=250;  %�趨һ�꽻�������������������껯ϵ����
calculationtime=180; %�趨��ʷ�۸�۲�����
time=datestr(now-1,'yyyy-mm-dd'); %��Ʒ��ʼʱ��Ĭ��Ϊ����
[sigma0,S0]=DataFetcher(code,time,calculationtime,tradedays);
disp(sigma0);

%% �趨��Ʒ��ز���
principal=30000000;
preserverate=1;
rp=0.05;
rf=0.05;
sigma=sigma0; %����Ϊ����״�������Գ���ʹ�õĲ����ʼ�Ϊ��ʷ������ 
K=S0*1.025;
period=21; %һ���£�21
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

%% ģ���times���۸�·�������������ԽС����ֹ�۸�ԽС
PathChart=MonteCarloSimulation(S0,(period/dt),(dt/tradedays),sigma0,rf,times);
[Y,I]=sortrows(PathChart(:,2:times+1)',period/dt+1);
PathChart(:,2:times+1)=Y';
clear Y;

%% ���۸�仯·��ͼ
figure;
for i=1:times
   plot(dt*PathChart(:,1),PathChart(:,i+1))
   hold on;
end
xlabel('����')
ylabel('�ڻ���Լ�ļ۸�Ԫ��')
xlim([0 period]);

%% ��ÿһ�ּ۸�·����ģ�⶯̬�Գ�Ĺ���
Return=zeros(1,times);
IncreaseRate=zeros(1,times);
Cost=zeros(1,times);
PriceList=zeros(period+1,2);
PriceList(:,1)=0:period;
for i=times:times
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
    [PositionChart,SettleAccount]=EuropeanCallHedging(OpenList,CloseList,SettleList,K,sigma,rf,rp,netprincipal,(managementrate+trusteerate),period,interval,positionrate,depositrate,tradefee,tradedays);
    Return(i)=(tradedays/period)*((SettleAccount(period,12)/principal)-1);
    Cost(i)=netprincipal*exp(rf*period/tradedays)+(rp*netprincipal/S0)*max(CloseList(period,2)-K,0)-SettleAccount(period,12);
    IncreaseRate(i)=CloseList(period,2)/OpenList(1,2)-1;
    disp(PositionChart);
    disp(SettleAccount);
end


%% �����껯���������ʲ��۸�仯�ʵ�ɢ��ͼ
figure;
scatter(100*IncreaseRate,100*Return)
ylabel('�껯������(%)')
xlabel('����ʲ���ĩ�۸�/�ڳ��۸�(%)');

%% ���Ƹ��Ƴɱ����ʲ��۸�仯�ʵ�ɢ��ͼ
figure;
scatter(100*IncreaseRate,Cost)
ylabel('���Ƴɱ�')
xlabel('����ʲ���ĩ�۸�/�ڳ��۸�(%)');

figure;
scatter(100*IncreaseRate,100*Cost/principal)
ylabel('��׼����ĸ��Ƴɱ�(%)')
xlabel('����ʲ���ĩ�۸�/�ڳ��۸�(%)');

