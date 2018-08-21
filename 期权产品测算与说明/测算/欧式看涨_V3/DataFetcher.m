%   Description��
%   �ú���������ȡ����Ҫ�ı���ʲ���ʷ�껯�����ʡ�����ʲ���Լ�ּ�
%   Input��
%   code-��Լ����
%   date-��ʼ����
%   calculationtime-��ʷ�����ʼ���۲���
%   annualcoefficient-��ʷ�����ʼ����껯ϵ������һ�꽻���ո�����
%   Output��
%   volatility-��ʷ�껯������
%   currentprice-�ڻ���Լ�ּۣ�����*������
%   Author��
%   PageZhao 20180608

function [volatility,currentprice]=DataFetcher(code,date,calculationtime,annualcoefficient)
w=windmatlab;
[volatility,~,~,~,~]=w.wsd(code,'volatilityratio',date,date,strcat('CalculationTime=',num2str(calculationtime)),strcat('AnnualCoefficient=',num2str(annualcoefficient)));
volatility=volatility*0.01;
[unitprice,~,~,~,~]=w.wsd('AU1812.SHF','open',date,date);
[contractmultiplier,~,~,~,~]=w.wsd('AU1812.SHF','contractmultiplier',date,date);
currentprice=unitprice*contractmultiplier;
end

