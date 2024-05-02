function  Output=simple_ICCS_CCFmean(x1,x2)

NumberOfAngles=180;
[X,Y]=size(x1);
%ACF=conv2(x1,x2,'same');
F1=fft2(x1);
F2=fft2(x2);
ACF= F1.*conj(F2);
G=((sum(sum(x1)))*(sum(sum(x2)))/X/Y);
ACF= ifft2(ACF);
ACF= fftshift(ACF)./G-1;

[R, C]=size(ACF);
if mod(R, 2) == 0
r0=R/2+1;
else
r0=(R+1)/2;
end
if mod(C, 2) == 0
c0=C/2+1;
else
c0=(C+1)/2;
end
Radius=min(r0-1,c0-1);

if NumberOfAngles==1
    Output=ACF(r0,c0:end);
else
ACF1=flipud(ACF(1:r0-1,c0:end));
ACF2=ACF(r0:end,c0:end);
ProfMat=zeros(NumberOfAngles*2,Radius);

for j=1:2
    if j==1
        y=ACF1';
    else
        y=ACF2;
    end
    
% CALCULATION OF ROTATIONAL MEAN
% Definition of angles
t=(pi/NumberOfAngles/2:pi/NumberOfAngles/2:pi/2);
   
% Matrix
y=y(1:Radius,1:Radius);
% Cycle between the 2nd and 2nd to last angles
[~, y1y]=size(y);

for i=1:NumberOfAngles
   rt=ceil(cos(t(i))*(1:Radius));
   ct=ceil(sin(t(i))*(1:Radius));
   profile=y((rt-1).*y1y+ct);

   if j==1
   ProfMat(NumberOfAngles+i,:)=profile;
   else
   ProfMat(i,:)=profile;
   end   
end

end


Output=[double(ACF(r0,c0)) sum(ProfMat)./(2*NumberOfAngles)];

end


end