function Result_Distance_to_AZ_EZ_TOP = Distribution_plot_TopView(List_xy_local_max, Contour_shape_coordinates, Result_contour_center, figHandle)
    % Check if the necessary variables are loaded
if ~exist('Contour_shape_coordinates', 'var') || ...
   ~exist('List_xy_local_max', 'var') || ...
   ~exist('Result_contour_center', 'var')
    error('One or more required variables are missing in the loaded files.');
end

pixel_resolution = 20; % 20 nm per pixel

% Load data and convert coordinates from pixels to nanometers
Contour_shape_coordinates = Contour_shape_coordinates * pixel_resolution;
xy_set = List_xy_local_max * pixel_resolution;
Result_contour_center = cellfun(@(x) x * pixel_resolution, Result_contour_center, 'UniformOutput', false);

% Ensure the contour is closed
if ~isequal(Contour_shape_coordinates(1,:), Contour_shape_coordinates(end,:))
    Contour_shape_coordinates(end+1, :) = Contour_shape_coordinates(1, :);
end

% Fit a spline to the closed contour
spline_fit = cscvn(Contour_shape_coordinates.');

% Generate a dense set of points along the spline
numPoints = 1000; % Adjust this number as needed for smoothness
splineParams = linspace(spline_fit.breaks(1), spline_fit.breaks(end), numPoints);
denseSplinePoints = fnval(spline_fit, splineParams);


% Calculate closest points on the spline-fitted contour
new_xy_set = zeros(size(xy_set));
for i = 1:size(xy_set, 1)
    idx = findClosestPointIndex(denseSplinePoints, xy_set(i,:));
    new_xy_set(i,:) = denseSplinePoints(:, idx)';
end


%% making subplot348 and 349 in main Analysis_TopView_synapses
nm_xlim = [0, 30] * pixel_resolution;
nm_ylim = [0, 30] * pixel_resolution;

% Plotting 349
figure(figHandle);
subplot(3,6,18);
plot(Contour_shape_coordinates(:,1), Contour_shape_coordinates(:,2), '-ok', 'MarkerFaceColor', 'k', 'MarkerSize', 2);
hold on;
title('Contour and Point Analysis');
xlabel('X Coordinate (nm)');
ylabel('Y Coordinate (nm)');
axis equal;
xlim(nm_xlim);
ylim(nm_ylim);

plot(denseSplinePoints(1,:), denseSplinePoints(2,:), 'Color', [1, 0.5, 0], 'LineWidth', 2);
plot(xy_set(:,1), xy_set(:,2), 'go', 'MarkerSize', 10);
plot(new_xy_set(:,1), new_xy_set(:,2), 'go', 'MarkerSize', 10);
plot(new_xy_set(:,1), new_xy_set(:,2), 'x', 'Color', [0, 0.5, 0], 'MarkerSize', 20);
center_position = Result_contour_center{2};
plot(center_position(1), center_position(2), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 10);

for i = 1:size(xy_set, 1)
    % Draw line
    line([xy_set(i,1), new_xy_set(i,1)], [xy_set(i,2), new_xy_set(i,2)], 'Color', 'm', 'LineStyle', '--');
    
    % Calculate distance
    distance_nm = sqrt((xy_set(i,1) - new_xy_set(i,1))^2 + (xy_set(i,2) - new_xy_set(i,2))^2);
    
    % Display distance as text
    text(xy_set(i,1), xy_set(i,2), sprintf('%.2f nm', distance_nm), 'Color', 'm', 'VerticalAlignment', 'bottom');
end


legend('Original Contour', 'Fitted Contour', 'List_xy_local_max', 'Closest Points on Contour', 'Center Position');
hold off;

%Calculation for subplot348 (polar plot)
% Calculate angles
angles = atan2(new_xy_set(:,2) - center_position(2), new_xy_set(:,1) - center_position(1));
angles = mod(angles, 2*pi); % Ensure angles are within 0 to 2*pi range
% Find the reference angle corresponding to the minimum distance
[~, minIndex] = min(distance_nm); % Find the index of the minimum distance
referenceAngle = angles(minIndex); % Get the angle at this index

% Normalize all angles
normalized_angles = angles - referenceAngle; % Subtract the reference angle from all angles

% Adjust any negative angles to ensure they fall within the range of 0 to 2*pi
normalized_angles(normalized_angles < 0) = normalized_angles(normalized_angles < 0) + 2*pi;

% Initialize radial_distances array
radial_distances = zeros(size(xy_set, 1), 1);

% Check if points are inside the fitted contour
isInside = inpolygon(xy_set(:,1), xy_set(:,2), denseSplinePoints(1,:), denseSplinePoints(2,:));

% Calculate distances and angles
distance_nm = zeros(size(xy_set, 1), 1);
angles = zeros(size(xy_set, 1), 1);
for i = 1:size(xy_set, 1)
    % Calculate distance_nm for the current point
    distance_nm(i) = sqrt((xy_set(i,1) - new_xy_set(i,1))^2 + (xy_set(i,2) - new_xy_set(i,2))^2);
    % Calculate angle for the current point
    angles(i) = atan2(new_xy_set(i,2) - center_position(2), new_xy_set(i,1) - center_position(1));
end
angles = mod(angles, 2*pi); % Ensure angles are within 0 to 2*pi range

% Find the reference angle corresponding to the minimum distance
[~, minIndex] = min(distance_nm); % Find the index of the minimum distance
referenceAngle = angles(minIndex); % Get the angle at this index

% Normalize all angles
normalized_angles = angles - referenceAngle; % Subtract the reference angle from all angles
normalized_angles(normalized_angles < 0) = normalized_angles(normalized_angles < 0) + 2*pi;

% Initialize radial_distances with the same number of elements as rows in xy_set
radial_distances = zeros(size(xy_set, 1), 1);

for i = 1:size(xy_set, 1)
    % Calculate the distance from the center to the closest point on the contour
    distance_to_closest_point = sqrt((new_xy_set(i,1) - center_position(1))^2 + (new_xy_set(i,2) - center_position(2))^2);

    if isInside(i)
        % If the point is inside the fitted contour
        temp_radial_distance = max([1 - (distance_nm(i) / distance_to_closest_point), 0]) * 100;
        
        if temp_radial_distance == 0
            % New condition: if max() result is 0, use alternate formula
            radial_distances(i) = (1 - distance_to_closest_point / distance_nm(i)) * 100;
        else
            radial_distances(i) = temp_radial_distance;
        end
    else
        % If the point is outside the fitted contour
        radial_distances(i) = 100 + distance_nm(i);
    end
end



% Filter out non-positive radial distances
valid_indices = radial_distances > 0;
normalized_angles = normalized_angles(valid_indices);
radial_distances = radial_distances(valid_indices);

% Prepare the cell array with labeled columns
% Create a table with labeled columns
Result_Distance_to_AZ_EZ_TOP = table(xy_set, isInside, normalized_angles, radial_distances, ...
    'VariableNames', {'Local_max', 'Inside_outside', 'Normalized_Angles', 'Radial_distance'});

end

% Function to find the closest point among a set of points to a given point
function idx = findClosestPointIndex(points, targetPoint)
    [~, idx] = min(sum((points - targetPoint').^2, 1));
end