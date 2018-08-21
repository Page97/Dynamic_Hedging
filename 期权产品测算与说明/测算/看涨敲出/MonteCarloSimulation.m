%   Description：
%   该函数进行蒙特卡罗模拟生成标的资产价格路径（几何布朗运动假设下）
%   Input：
%   S0-标的资产的初始的价格;
%   K-行权价格
%   r-无风险利率
%   sigma-波动率(收益标准差)
%   m-模拟的步数
%   dt-时间间隔(单位：年）
%   I-模拟的次数
%   Output：
%   PathChart-模拟出的标的资产价格路径表（第一列为步数序号）

function PathChart=MonteCarloSimulation(S0,m,dt,sigma,rf,T)
Path=zeros(1,m+1);
PathChart=zeros(m+1,T+1);
PathChart(:,1)=0:m;
for i=1:T
    for t=0:m
        if t==0
            Path(t+1)=S0;
        else
            z = randn(1);
            Path(t+1) = Path(t)*exp((rf-0.5*sigma^2) * dt + sigma * sqrt(dt) * z);
        end
    end
       PathChart(:,i+1)=Path;
end
