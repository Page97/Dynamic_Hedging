%   该函数用来计算某时刻欧式看涨期权的delta值
%   Input:
%   S-标的资产的现价
%   K-行权价
%   segma-标的资产价格的年化波动率
%   rf-无风险利率
%   T-距到期日的时间（单位：年）
%   Output:
%   delta-该期权的delta值
%   Author:
%   PageZhao 20180522

function delta=EuropeanCallDelta(S,K,v,rf,T)
d1=(log(S/K)+(rf+0.5*v^2)*T)/(v*T^0.5);
delta=normcdf(d1); %期权的delta值
end
