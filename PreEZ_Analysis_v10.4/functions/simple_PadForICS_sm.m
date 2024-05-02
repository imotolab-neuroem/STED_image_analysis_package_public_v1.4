function [y, Np, varargout] = simple_PadForICS_sm(x1, Extra, Thr, sm)
    [m, n, p] = size(x1);
    if p == 1
        p = 2;
        x1(:,:,2) = x1(:,:,1);  % Duplicate the channel if it's single-channel
    end

    % Smoothing Step
    for kk = 1:p
        x1s(:,:,kk) = simpleICCS_smooth_simple(x1(:,:,kk), sm, 2);
    end
    %% Padding
    y = zeros(m + 2 * Extra, n + 2 * Extra, p);
    ys = y;
    for k = 1:p
        y(Extra + 1 : Extra + m, Extra + 1 : Extra + n, k) = x1(:,:,k);
        ys(Extra + 1 : Extra + m, Extra + 1 : Extra + n, k) = x1s(:,:,k);
    end
    %% Adding average on zeros
    Mask = ys(:,:,1);
    Mask2 = ys(:,:,2);
    Mask(Mask <= Thr(1) & Mask2 <= Thr(2)) = 0;
    Mask(Mask2 > Thr(2) | Mask > Thr(1)) = 1;

for k=1:p
    x=y(:,:,k);
    MeanInt(k)=mean(x(Mask>0));
    c=0;
    for i=1:m+2*Extra
        for j=1:n+2*Extra
            if Mask(i,j)==0 
            y(i,j,k)=MeanInt(k) ;
            c=c+1;
            end
        end
    end
Np(k)=c;

if nargout > 2
varargout{1} = Mask;
end

if nargout > 3
    for k=1:p
      Aroi=y(:,:,k).*Mask;
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