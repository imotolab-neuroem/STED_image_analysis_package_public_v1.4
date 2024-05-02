function [y, NpACF, varargout] = simple_PadForICS_fromMask_whole(x1, Extra, fullSizeMask)
    [m, n, p] = size(x1);
    fullSizeMask = double(fullSizeMask);

    % Initialize MeanInt
    MeanInt = zeros(1, p);

    % Padding
    y = zeros(m + 2 * Extra, n + 2 * Extra, p);
    for k = 1:p
        y(Extra + 1:Extra + m, Extra + 1:Extra + n, k) = x1(:,:,k);
    end

    % Calculate the mean intensity of x1
    meanIntensity = mean(x1(:));

    % Resizing the mask with zeros in the padded area
    MaskResized = padarray(fullSizeMask, [Extra Extra], 0, 'both');

    % Fill the padded area with the mean intensity of x1
    for k = 1:p
        paddedArea = y(:,:,k);
        paddedArea(1:Extra, :) = meanIntensity;
        paddedArea(end-Extra+1:end, :) = meanIntensity;
        paddedArea(:, 1:Extra) = meanIntensity;
        paddedArea(:, end-Extra+1:end) = meanIntensity;
        y(:,:,k) = paddedArea;

        % Update MeanInt for each channel
        MeanInt(k) = meanIntensity;
    end

    NpACF = repmat(Extra * (2 * (m + n) + 4 * Extra), 1, p);

    % Smoothing and median calculation
    B = zeros(1, p);
    for k = 1:p
        Aroi = y(:,:,k) .* MaskResized;
        A = simpleICCS_smooth_simple(Aroi, 0.2, 1);
        B(k) = median(A(A > 0));
    end

    % Assigning the resized mask, MeanInt, and B to varargout if requested
    if nargout > 2
        varargout{1} = MaskResized;
    end
    if nargout > 3
        varargout{2} = B;
    end
    if nargout > 4
        varargout{3} = MeanInt;
    end
end

function y = simpleICCS_smooth_simple(M, sm, n)
    y = M;
    if sm > 0
        filt = (1 / (8 + 1 / sm)) * [1 1 1; 1 1/sm 1; 1 1 1]; 
        for i = 1:n
            y = filter2(filt, y);
        end
    end
end

