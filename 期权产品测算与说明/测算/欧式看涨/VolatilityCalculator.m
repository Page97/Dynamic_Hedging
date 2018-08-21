%   该函数使用移动平均法计算给定标的资产价格的年化波动率

function volatility=VolatilityCalculator(code,date,calculationtime,annualcoefficient)
w=windmatlab;
[volatility,~,~,~,~]=w.wsd(code,'vaolatilityrate',date,strcat('CalculationTime=',num2str(calculationtime)),strcat('AnnualCoefficient=',num2str(annualcoefficient)));
end