function [y,Np, varargout]=simple_PadForICS_fromMask_OutOne(x1,Extra,Mask)
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
    c=0; % Initialize counter for each color channel
    for i=1:m+2*Extra
        for j=1:n+2*Extra
            if MaskResized(i,j)==0 || isnan(MaskResized(i,j))
                y(i,j,k)=1; % Set the value to 1 instead of the mean intensity
                c=c+1; % Increment counter
            elseif MaskResized(i,j)==1 && y(i,j,k)==0
            y(i,j,k)=1; % Set pixels inside the mask but outside x1 to 1

            end
        end
    end
    Np(k)=c; % Store the count for the current color channel


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