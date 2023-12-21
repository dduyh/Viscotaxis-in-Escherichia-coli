%2D gaussian fit function.

function f = gauss2DY(v,R,C,Z)
a = v(1);
b = v(2);
c = v(3);
d = v(4);
P=a*(exp(-(((((R-b)/c).^2)+(((C-d)/c).^2)))));
f=sum(sum((P-Z).^2));