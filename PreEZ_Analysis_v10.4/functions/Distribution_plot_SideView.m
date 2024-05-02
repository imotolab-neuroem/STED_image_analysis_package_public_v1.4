function Result_Distance_to_AZ_EZ = Distribution_plot_SideView(ActiveZone_Plasma_membrane_Sorted, List_xy_local_max, Result_contour_center, figHandle)
% Check if the necessary variables are loaded
if ~exist('ActiveZone_Plasma_membrane_Sorted', 'var') || ...
   ~exist('List_xy_local_max', 'var') || ...
   ~exist('Result_contour_center', 'var')
    error('One or more required variables are missing in the loaded files.');
end

pixel_resolution = 20; % 20 nm per pixel

% Load data and convert coordinates from pixels to nanometers
ActiveZone_Plasma_membrane_Sorted = ActiveZone_Plasma_membrane_Sorted * pixel_resolution;
xy_set = List_xy_local_max * pixel_resolution;
Result_contour_center = cellfun(@(x) x * pixel_resolution, Result_contour_center, 'UniformOutput', false);

% Choose the degree of the polynomial
degree = 6; % Example: a sextic polynomial

% Fit the polynomial
p = polyfit(ActiveZone_Plasma_membrane_Sorted(:,1), ActiveZone_Plasma_membrane_Sorted(:,2), degree);

% Generate a range of x values for plotting the fit
x_fit = linspace(min(ActiveZone_Plasma_membrane_Sorted(:,1)), max(ActiveZone_Plasma_membrane_Sorted(:,1)), 100);

% Calculate the fitted y values
y_fit = polyval(p, x_fit);

% Create a new figure
figure;

nm_xlim = [0, 30] * pixel_resolution;
nm_ylim = [0, 30] * pixel_resolution;


% Define the distance function
distanceToCurve = @(x, point) (polyval(p, x) - point(2))^2 + (x - point(1))^2;

% Initialize new arrays for projected points
new_xy_set = zeros(size(xy_set));
new_startPoint = zeros(size(Result_contour_center{3}));
new_endPoint = zeros(size(Result_contour_center{4}));

% Optimize and project each point in xy_set onto the curve
for i = 1:size(xy_set, 1)
    x_opt = fminsearch(@(x) distanceToCurve(x, xy_set(i,:)), xy_set(i,1));
    new_xy_set(i,:) = [x_opt, polyval(p, x_opt)];
end

% Optimize and project startPoint onto the curve
x_opt_start = fminsearch(@(x) distanceToCurve(x, Result_contour_center{3}), Result_contour_center{3}(1));
new_startPoint = [x_opt_start, polyval(p, x_opt_start)];

% Optimize and project endPoint onto the curve
x_opt_end = fminsearch(@(x) distanceToCurve(x, Result_contour_center{4}), Result_contour_center{4}(1));
new_endPoint = [x_opt_end, polyval(p, x_opt_end)];

% Calculate the center point on the curve
x_range = linspace(new_startPoint(1), new_endPoint(1), 1000);
y_range = polyval(p, x_range);
curve_segment = [x_range; y_range]';
arc_lengths = [0; cumsum(sqrt(diff(curve_segment(:,1)).^2 + diff(curve_segment(:,2)).^2))];
total_length = arc_lengths(end);
[~, center_idx] = min(abs(arc_lengths - total_length / 2));
center_point = curve_segment(center_idx, :);

distance_to_center = zeros(size(new_xy_set, 1), 1);
distance_to_membrane = zeros(size(xy_set, 1), 1);

%% Updated plot with projected points and center point (subplot 1,2,2)
figure(figHandle);
subplot(349);
plot(ActiveZone_Plasma_membrane_Sorted(:,1), ActiveZone_Plasma_membrane_Sorted(:,2), '-ok', 'MarkerFaceColor', 'k', 'MarkerSize', 2);
hold on;
plot(x_fit, y_fit, 'Color', [1, 0.5, 0], 'LineWidth', 2);
plot(xy_set(:,1), xy_set(:,2), 'go', 'MarkerSize', 10);
plot(new_xy_set(:,1), new_xy_set(:,2), 'go', 'MarkerSize', 10);
plot(new_xy_set(:,1), new_xy_set(:,2), 'x', 'Color', [0, 0.5, 0], 'MarkerSize', 20); % Dark green 'x' marks on the circles
plot(new_startPoint(1), new_startPoint(2), 'o', 'Color', [0.678, 0.847, 1], 'MarkerSize', 10);
plot(new_endPoint(1), new_endPoint(2), 'bo', 'MarkerSize', 10);
plot(center_point(1), center_point(2), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 10); % Center point in red

% Draw lines connecting corresponding points of XY_set and new_xy_set
for i = 1:size(xy_set, 1)
    line([xy_set(i,1), new_xy_set(i,1)], [xy_set(i,2), new_xy_set(i,2)], 'Color', 'm', 'LineStyle', '--');
    % Calculate distance in nanometers
    distance_nm = sqrt((xy_set(i,1) - new_xy_set(i,1))^2 + (xy_set(i,2) - new_xy_set(i,2))^2);
    distance_to_membrane(i) = distance_nm; % Save to array
    % Annotate the plot with the distance in nanometers
    text(xy_set(i,1), xy_set(i,2), sprintf('%.2f nm', distance_nm), 'Color', [0, 0.5, 0], 'VerticalAlignment', 'bottom');
end
plot(center_point(1), center_point(2), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 10); % Center point in red


% Calculate and annotate arc distances for start and end points to center point
start_to_center_idx = find(x_range == new_startPoint(1));
end_to_center_idx = find(x_range == new_endPoint(1));
start_to_center_distance = sum(sqrt(diff(curve_segment(1:center_idx,1)).^2 + diff(curve_segment(1:center_idx,2)).^2));
end_to_center_distance = sum(sqrt(diff(curve_segment(center_idx:end,1)).^2 + diff(curve_segment(center_idx:end,2)).^2));

% Annotate distances
text(new_startPoint(1), new_startPoint(2), sprintf('%.2f', start_to_center_distance), 'VerticalAlignment', 'bottom');
text(new_endPoint(1), new_endPoint(2), sprintf('%.2f', end_to_center_distance), 'VerticalAlignment', 'bottom');

% Calculate and annotate arc distances from center_point to each point in new_xy_set
for i = 1:size(new_xy_set, 1)
    % Determine the range for the segment
    if new_xy_set(i,1) < center_point(1)
        x_range_segment = linspace(new_xy_set(i,1), center_point(1), 500);
    else
        x_range_segment = linspace(center_point(1), new_xy_set(i,1), 500);
    end
    y_range_segment = polyval(p, x_range_segment);
    
    % Calculate arc length for the segment
    segment_arc_length = sum(sqrt(diff(x_range_segment).^2 + diff(y_range_segment).^2));
    distance_to_center(i) = segment_arc_length; % Save to array

    % Annotate the plot with the distance
    text(new_xy_set(i,1), new_xy_set(i,2), sprintf('%.2f', segment_arc_length), 'VerticalAlignment', 'bottom');
end

axis equal;
xlim(nm_xlim);
ylim(nm_xlim);
title('Updated Plot with Projected Points and Center Point');
xlabel('X Coordinate');
ylabel('Y Coordinate');
legend('ActiveZone Plasma Membrane Sorted', 'Fitted Curve', 'Local maxima', 'Projected XY Set', 'Connection Lines', 'Projected Start Point', 'Projected End Point', 'Center Point', 'Location', 'eastoutside');
hold off;

% Create a table with the calculated distances
Result_Distance_to_AZ_EZ = table(distance_to_center, distance_to_membrane, 'VariableNames', {'Distance_to_Center', 'Distance_to_Membrane'});

% Find the larger distance between end_to_center_distance and start_to_center_distance
larger_center_distance = max(start_to_center_distance, end_to_center_distance);
AZ_EZ_Identifier = zeros(size(Result_Distance_to_AZ_EZ.Distance_to_Center));

% Perform the check and fill the AZ_EZ_Identifier column
for i = 1:size(Result_Distance_to_AZ_EZ.Distance_to_Center, 1)
    if Result_Distance_to_AZ_EZ.Distance_to_Center(i) < larger_center_distance
        AZ_EZ_Identifier(i) = 0;
    else
        AZ_EZ_Identifier(i) = 1;
    end
end

% Add the AZ_EZ_Identifier column to the table
Result_Distance_to_AZ_EZ.AZ_EZ_Identifier = AZ_EZ_Identifier;

% Initialize the Normalized Distance column
Normalized_Distance = zeros(size(Result_Distance_to_AZ_EZ.Distance_to_Center));
for i = 1:size(Result_Distance_to_AZ_EZ.Distance_to_Center, 1)
    if Result_Distance_to_AZ_EZ.AZ_EZ_Identifier(i) == 0
        % If AZ_EZ_Identifier is 0
        Normalized_Distance(i) = (Result_Distance_to_AZ_EZ.Distance_to_Center(i) / larger_center_distance) * 100;
    else
        % If AZ_EZ_Identifier is 1
        Normalized_Distance(i) = ((Result_Distance_to_AZ_EZ.Distance_to_Center(i) - larger_center_distance) + 100);
    end
end
Result_Distance_to_AZ_EZ.Normalized_Distance = Normalized_Distance;
