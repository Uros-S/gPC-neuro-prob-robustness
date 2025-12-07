function dYdt = Hindmarsh_Rose(t,Y,parameters)

dYdt = zeros(3,1);

%parameters setting
a = parameters(1);
b = parameters(2);
c = parameters(3);
d = parameters(4);
I = parameters(5);
r = parameters(6); 
s = parameters(7);
x_R = parameters(8); 

% Hindmarsh-Rose model equations
x = Y(1); y = Y(2); z = Y(3);
dYdt(1) = -a*x^3+b*x^2+y-z+I;
dYdt(2) = c-d*x^2-y;
dYdt(3) = r*(s*(x-x_R)-z);

end