function myvalue=CallValue(my_S,my_K,my_H,my_E,my_sigma,my_rf,my_T)
syms S K H E v rf T;
P=exp(-rf*T)*(log(H/S)/(2*pi*v^2*T^3)^0.5)*exp(-0.5*(log(H/S)/(v*T^0.5)+0.5*T^0.5*(v-2*rf/v))^2);
V0=E*int(P,T,0,my_T);
d1=(log(S/K)+(rf+v^2/2)*T)/(v*T^0.5);
d2=d1-v*T^0.5;
lambda=(rf+v^2/2)/v^2;
y=(log(H^2/(S*K)))/(v*T^0.5)+lambda*v*T^0.5;
x1=log(S/H)/(v*T^0.5)+lambda*v*T^0.5;
y1=log(H/S)/(v*T^0.5)+lambda*v*T^0.5;
V1=S*normcdf(d1)-K*exp(-rf*T)*normcdf(d2)-S*normcdf(x1)+K*exp(-rf*T)*normcdf(x1-v*T^0.5)+S*(H/S)^(2*lambda)*(normcdf(-y)-normcdf(-y1))-K*exp(-rf*T)*(H/S)^(2*lambda-2)*(normcdf(-y+v*T^0.5)-normcdf(-y1+v*T^0.5));
V=V0+V1;
myvalue=subs(V,{S,K,H,E,v,rf,T},{my_S,my_K,my_H,my_E,my_sigma,my_rf,my_T});
end