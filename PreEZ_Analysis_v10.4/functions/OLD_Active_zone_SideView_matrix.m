function Active_zone_SideView_matrix(contours, axesHandle)
    % contours is now a cell array where each cell contains [x, y] coordinates of a contour

    for i = 1:length(contours)
        contour = contours{i};
        x = contour(:, 1);
        y = contour(:, 2);

        % Call the local fit_ellipse function with the current contour coordinates
        ellipse_t = local_fit_ellipse(x, y);
        
        % Check if the ellipse fitting was successful
        if isempty(ellipse_t.a)
            disp(['Ellipse fitting was unsuccessful for contour: ', num2str(i)]);
            disp('Debug info:');
            disp(ellipse_t);
            continue; % Skip to the next contour
        end

    % Now plot the fitted ellipse
    hold(axesHandle, 'on'); % Ensure we are adding to the existing plot, not replacing it

    % Rotation matrix to rotate the axes with respect to an angle phi
    R = [cos(ellipse_t.phi), sin(ellipse_t.phi); -sin(ellipse_t.phi), cos(ellipse_t.phi)];
    
    % the ellipse
    theta_r = linspace(0, 2*pi);
    ellipse_x_r = ellipse_t.X0_in + ellipse_t.a * cos(theta_r);
    ellipse_y_r = ellipse_t.Y0_in + ellipse_t.b * sin(theta_r);
    rotated_ellipse = R * [ellipse_x_r; ellipse_y_r];
    
    % draw the ellipse
    plot(axesHandle, rotated_ellipse(1,:), rotated_ellipse(2,:), 'r', 'LineWidth', 2);
    
    hold(axesHandle, 'off'); % Release the hold on the axes
    end
end
 
function ellipse_t = local_fit_ellipse(x, y)
    % Local function to fit an ellipse to the selected contour coordinates
    % This is adapted from the provided fit_ellipse.m script and includes only the fitting logic

    % Prepare vectors, must be column vectors
    x = x(:);
    y = y(:);

    % Remove bias of the ellipse - to make matrix inversion more accurate. (will be added later on)
    mean_x = mean(x);
    mean_y = mean(y);
    x = x - mean_x;
    y = y - mean_y;

    % The estimation for the conic equation of the ellipse
    X = [x.^2, x.*y, y.^2, x, y];
    a = (X' * X) \ (X' * ones(length(x), 1));

    % Extract parameters from the conic equation
    [a, b, c, d, f] = deal(a(1), a(2), a(3), a(4), a(5));

    % Remove the orientation from the ellipse
    orientation_tolerance = 1e-3;
    if min(abs(b/a), abs(b/c)) > orientation_tolerance
        orientation_rad = 1/2 * atan(b / (c - a));
        cos_phi = cos(orientation_rad);
        sin_phi = sin(orientation_rad);
        [a, b, c, d, f] = deal(...
            a * cos_phi^2 - b * cos_phi * sin_phi + c * sin_phi^2, ...
            0, ...
            a * sin_phi^2 + b * cos_phi * sin_phi + c * cos_phi^2, ...
            d * cos_phi - f * sin_phi, ...
            d * sin_phi + f * cos_phi);
        [mean_x, mean_y] = deal(...
            cos_phi * mean_x - sin_phi * mean_y, ...
            sin_phi * mean_x + cos_phi * mean_y);
    else
        orientation_rad = 0;
    end

    % Check if conic equation represents an ellipse
    if a * c > 0
        % make sure coefficients are positive as required
        if a < 0, [a, c, d, f] = deal(-a, -c, -d, -f); end

        % Final ellipse parameters
        X0_in = mean_x - d / (2 * a);
        Y0_in = mean_y - f / (2 * c);
        F = 1 + (d^2) / (4 * a) + (f^2) / (4 * c);
        [a, b] = deal(sqrt(F / a), sqrt(F / c));

        % pack ellipse into a structure
        ellipse_t = struct(...
            'a', a, ...
            'b', b, ...
            'phi', orientation_rad, ...
            'X0', X0_in, ...
            'Y0', Y0_in, ...
            'X0_in', X0_in + mean_x, ...
            'Y0_in', Y0_in + mean_y, ...
            'status', '');
    else
        % If it's not an ellipse, return an empty structure
        ellipse_t = struct(...
            'a', [], ...
            'b', [], ...
            'phi', [], ...
            'X0', [], ...
            'Y0', [], ...
            'X0_in', [], ...
            'Y0_in', [], ...
            'status', 'Not an ellipse');
    end
end

