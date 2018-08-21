%   Description：
%   该函数用来获取所需要的标的资产历史年化波动率、标的资产合约现价
%   Input：
%   code-合约代码
%   date-起始日期
%   calculationtime-历史波动率计算观察期
%   annualcoefficient-历史波动率计算年化系数（即一年交易日个数）
%   Output：
%   volatility-历史年化波动率
%   currentprice-期货合约现价（报价*乘数）
%   Author：
%   PageZhao 20180608

function [volatility,currentprice]=DataFetcher(code,date,calculationtime,annualcoefficient)
w=windmatlab;
[volatility,~,~,~,~]=w.wsd(code,'volatilityratio',date,date,strcat('CalculationTime=',num2str(calculationtime)),strcat('AnnualCoefficient=',num2str(annualcoefficient)));
volatility=volatility*0.01;
[unitprice,~,~,~,~]=w.wsd('AU1812.SHF','open',date,date);
[contractmultiplier,~,~,~,~]=w.wsd('AU1812.SHF','contractmultiplier',date,date);
currentprice=unitprice*contractmultiplier;
end

