%   �ú�����������ĳʱ��ŷʽ������Ȩ��deltaֵ
%   Input:
%   S-����ʲ����ּ�
%   K-��Ȩ��
%   H-�ó��۸�
%   O-�ó�����
%   segma-����ʲ��۸���껯������
%   rf-�޷�������
%   T-�ൽ���յ�ʱ�䣨��λ���꣩
%   Output:
%   delta-����Ȩ��deltaֵ
%   Author:
%   PageZhao 20180522
%   Notice:
%   �����ó���Ȩ��delta�ǿ��ܳ��ָ�ֵ��

% ���¼���Ϊ�����ó���Ȩdelta��ϸ�ı�׼������̣�����Ч�ʱȽϵ�
% function delta=KnockOutCallDelta(my_S,my_K,my_H,my_E,my_sigma,my_rf,my_T)
% syms S K H E v rf T;
% P=exp(-rf*T)*(log(H/S)/(2*pi*v^2*T^3)^0.5)*exp(-0.5*(log(H/S)/(v*T^0.5)+0.5*T^0.5*(v-2*rf/v))^2);
% V0=E*int(P,T,0,my_T);
% d1=(log(S/K)+(rf+v^2/2)*T)/(v*T^0.5);
% d2=d1-v*T^0.5;
% lambda=(rf+v^2/2)/v^2;
% y=(log(H^2/(S*K)))/(v*T^0.5)+lambda*v*T^0.5;
% x1=log(S/H)/(v*T^0.5)+lambda*v*T^0.5;
% y1=log(H/S)/(v*T^0.5)+lambda*v*T^0.5;
% V1=S*normcdf(d1)-K*exp(-rf*T)*normcdf(d2)-S*normcdf(x1)+K*exp(-rf*T)*normcdf(x1-v*T^0.5)+S*(H/S)^(2*lambda)*(normcdf(-y)-normcdf(-y1))-K*exp(-rf*T)*(H/S)^(2*lambda-2)*(normcdf(-y+v*T^0.5)-normcdf(-y1+v*T^0.5));
% V=V0+V1;
% dVS=diff(V,'S');
% delta=subs(dVS,{S,K,H,E,v,rf,T},{my_S,my_K,my_H,my_E,my_sigma,my_rf,my_T});
% end

function delta=KnockOutCallDelta(S,K,H,E,v,rf,T)
if S<=H
    syms t;
    delta=erfc((2^(1/2)*(log(S/H)/(T^(1/2)*v) + (T^(1/2)*(v^2/2 + rf))/v))/2)/2 - erfc((2^(1/2)*(log(S/K) + T*(v^2/2 + rf)))/(2*T^(1/2)*v))/2 + E*int((exp(-((t^(1/2)*(v - (2*rf)/v))/2 + log(H/S)/(t^(1/2)*v))^2/2)*exp(-rf*t)*log(H/S)*((t^(1/2)*(v - (2*rf)/v))/2 + log(H/S)/(t^(1/2)*v)))/(S*t^(1/2)*v*(2*t^3*v^2*pi)^(1/2)) - (exp(-((t^(1/2)*(v - (2*rf)/v))/2 + log(H/S)/(t^(1/2)*v))^2/2)*exp(-rf*t))/(S*(2*t^3*v^2*pi)^(1/2)), t, 0, T) - (H/S)^((2*(v^2/2 + rf))/v^2)*(erfc((2^(1/2)*(log(H/S)/(T^(1/2)*v) + (T^(1/2)*(v^2/2 + rf))/v))/2)/2 - erfc((2^(1/2)*(log(H^2/(K*S))/(T^(1/2)*v) + (T^(1/2)*(v^2/2 + rf))/v))/2)/2) - S*(H/S)^((2*(v^2/2 + rf))/v^2)*((2^(1/2)*exp(-(log(H/S)/(T^(1/2)*v) + (T^(1/2)*(v^2/2 + rf))/v)^2/2))/(2*S*T^(1/2)*v*pi^(1/2)) - (2^(1/2)*exp(-(log(H^2/(K*S))/(T^(1/2)*v) + (T^(1/2)*(v^2/2 + rf))/v)^2/2))/(2*S*T^(1/2)*v*pi^(1/2))) + K*exp(-T*rf)*((2^(1/2)*exp(-(log(H/S)/(T^(1/2)*v) - T^(1/2)*v + (T^(1/2)*(v^2/2 + rf))/v)^2/2))/(2*S*T^(1/2)*v*pi^(1/2)) - (2^(1/2)*exp(-(log(H^2/(K*S))/(T^(1/2)*v) - T^(1/2)*v + (T^(1/2)*(v^2/2 + rf))/v)^2/2))/(2*S*T^(1/2)*v*pi^(1/2)))*(H/S)^((2*(v^2/2 + rf))/v^2 - 2) - (2^(1/2)*exp(-(log(S/H)/(T^(1/2)*v) + (T^(1/2)*(v^2/2 + rf))/v)^2/2))/(2*T^(1/2)*v*pi^(1/2)) + (2^(1/2)*exp(-(log(S/K) + T*(v^2/2 + rf))^2/(2*T*v^2)))/(2*T^(1/2)*v*pi^(1/2)) + (2*H*(v^2/2 + rf)*(H/S)^((2*(v^2/2 + rf))/v^2 - 1)*(erfc((2^(1/2)*(log(H/S)/(T^(1/2)*v) + (T^(1/2)*(v^2/2 + rf))/v))/2)/2 - erfc((2^(1/2)*(log(H^2/(K*S))/(T^(1/2)*v) + (T^(1/2)*(v^2/2 + rf))/v))/2)/2))/(S*v^2) - (H*K*exp(-T*rf)*(H/S)^((2*(v^2/2 + rf))/v^2 - 3)*(erfc((2^(1/2)*(log(H/S)/(T^(1/2)*v) - T^(1/2)*v + (T^(1/2)*(v^2/2 + rf))/v))/2)/2 - erfc((2^(1/2)*(log(H^2/(K*S))/(T^(1/2)*v) - T^(1/2)*v + (T^(1/2)*(v^2/2 + rf))/v))/2)/2)*((2*(v^2/2 + rf))/v^2 - 2))/S^2 + (2^(1/2)*K*exp(-T*rf)*exp(-(log(S/H)/(T^(1/2)*v) - T^(1/2)*v + (T^(1/2)*(v^2/2 + rf))/v)^2/2))/(2*S*T^(1/2)*v*pi^(1/2)) - (2^(1/2)*K*exp(-T*rf)*exp(-(T^(1/2)*v - (log(S/K) + T*(v^2/2 + rf))/(T^(1/2)*v))^2/2))/(2*S*T^(1/2)*v*pi^(1/2));
else
    delta=0;
end
end