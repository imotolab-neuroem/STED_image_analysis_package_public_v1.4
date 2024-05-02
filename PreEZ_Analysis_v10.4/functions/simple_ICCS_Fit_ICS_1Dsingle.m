function [param, fval, chisq, xOut, yOut, fvalOut] = simple_ICCS_Fit_ICS_1Dsingle(x, y, w0, Display, title1)
    % Fixed parameters
    my = min(y);
    My = max(y);

    % Define the function to minimize
    fun = @(Param) sum( (( (Param(1) + Param(2) .* exp(-((x-0) .^ 2 ./ (Param(3)^2))) ) - y ).^2) ./ (abs(y)) );
    
    % Perform minimization
    [param, chisqpar] = fminsearch(fun, [my, My, w0]);
    param(3) = abs(param(3));
    
    % Calculate fitted values
    fval = 1+(param(1) + param(2) .* exp(-((x-0) .^ 2 ./ (param(3)^2))));
    
    % Calculate chi-square
    chisq = sum( (( (param(1) + param(2) .* exp(-((x-0) .^ 2 ./ (param(3)^2))) ) - y ).^2) ./ ((param(2)^2)) );

    % Set output variables for plot data
    xOut = x;
    yOut = y;
    fvalOut = fval;

    % Display plot if required
    if Display == 1
        plot(x, y, 'o');  % Original data points
        hold on;
        plot(x, fval, '--r');  % Fitted curve
        plot(x, fval, 'ro', 'MarkerFaceColor', 'none');  % Fitted data points with red open circles
        hold off;
        title(strcat(title1, '  w=', num2str(param(3), 2), '   G0=', num2str(param(2), 2)));
    end
end