function [y,Np, varargout]=simple_PadForICS_fromMask(x1,Extra,Mask)
[m,n,p]=size(x1);
Mask=double(Mask);

%% padding
y=zeros(m+2*Extra,n+2*Extra,p);
for k=1:p
    y(Extra+1:Extra+m,Extra+1:Extra+n,k)=x1(:,:,k);
end
MaskResized = padarray(Mask, [Extra Extra], 'replicate', 'both');
%% adding average on zeros
for k=1:p
    x=y(:,:,k);
    MeanInt(k)=mean(x(MaskResized>0));
    c=0;
    for i=1:m+2*Extra
        for j=1:n+2*Extra
            %if Mask(i,j)==0 || isnan(Mask(i,j))
            if MaskResized(i,j)==0 || isnan(MaskResized(i,j))
            y(i,j,k)=MeanInt(k) ;
            c=c+1;
            end
        end
    end
Np(k)=c;

if nargout > 2
varargout{1} = MaskResized;
end

if nargout > 3
    for k=1:p
      Aroi=y(:,:,k).*MaskResized;
      A=simpleICCS_smooth_simple(Aroi,0.2,1);
      B(k)=median(A(A>0));
    end    
varargout{2} = B;
end

if nargout > 4   
varargout{3} = MeanInt;
end



    
end

end

function y = simpleICCS_smooth_simple(M, sm, n)
    y = M;
    if sm > 0
        filt = (1 / (8 + 1 / sm)) * [1 1 1; 1 1/sm 1; 1 1 1]; % sm factor <= 1 
        for i = 1:n
            y = filter2(filt, y);
        end
    end
end