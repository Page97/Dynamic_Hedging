%   �ú���ʹ���ƶ�ƽ���������������ʲ��۸���껯������

function volatility=VolatilityCalculator(code,date,calculationtime,annualcoefficient)
w=windmatlab;
[volatility,~,~,~,~]=w.wsd(code,'vaolatilityrate',date,strcat('CalculationTime=',num2str(calculationtime)),strcat('AnnualCoefficient=',num2str(annualcoefficient)));
end