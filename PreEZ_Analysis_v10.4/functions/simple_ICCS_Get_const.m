function const=simple_ICCS_Get_const(FWHM1,FWHM2)

FWHMval=2:0.05:5;

D = [0.2175    0.2203    0.2010    0.1863    0.1755    0.1714    0.1549;
    0.2203    0.1972    0.1850    0.1815    0.1737    0.1545    0.1400;
    0.2010    0.1850    0.1788    0.1772    0.1675    0.1525    0.1435;
    0.1863    0.1815    0.1772    0.1671    0.1539    0.1452    0.1347;
    0.1755    0.1737    0.1675    0.1539    0.1512    0.1389    0.1316;
    0.1714    0.1545    0.1525    0.1452    0.1389    0.1372    0.1309;
    0.15489	  0.13998	0.14346	  0.13471	0.13159   0.13092	0.12654] ;

[Xs,Ys] = meshgrid(double(1:7),double(1:7));
[Xq,Yq] = meshgrid(1:0.1:7,1:0.1:7);
Dint = interp2(Xs,Ys,D,Xq,Yq);
if FWHM1<2
    pos1=1;
elseif FWHM1>5
    pos1=61;
else
    [~, pos1]=min(abs((FWHMval-FWHM1)));
end

if FWHM2<2
    pos2=1;
elseif FWHM2>5
    pos2=61;
else
    [~, pos2]=min(abs((FWHMval-FWHM2)));
end
    
const=Dint(pos1,pos2);

end
