function [plasma_membrane_Start, plasma_membrane_End] = making_plasma_membrane(axesHandle, startPoint, endPoint)
    % Function for manual line drawing from start and end points on a given axes

    % Select the axes for plotting
    axes(axesHandle);
    hold on;

    % Function to draw line starting from a given point
    function linePoints = drawLineFromPoint(startingPoint)
        linePoints = startingPoint; % Initialize with starting point

        % Function to highlight a point with a light blue circle
        function highlightPoint(point)
            circleRadius = 2.5; % Adjust the radius as needed
            rectangle('Position', [point(1)-circleRadius/2, point(2)-circleRadius/2, circleRadius, circleRadius], ...
                      'Curvature', [1, 1], 'EdgeColor', [0.678, 0.847, 0.902], 'LineWidth', 2, 'FaceColor', 'none');
        end

        % Highlight the starting point with a light blue larger circle
        highlightPoint(startingPoint);

        title('Click to draw the line, double-click the last point when done.');

        % User clicks to add points
        but = 1;
        while but == 1
            [xi, yi, but] = ginput(1);
            if isempty(xi) || isempty(yi)
                break;
            end
            newPoint = [xi, yi];
            linePoints = [linePoints; newPoint]; % Append new point
            plot(linePoints(:,1), linePoints(:,2), '-r'); % Draw line
            highlightPoint(newPoint); % Highlight the new point
        end
    end

    % Draw line from startPoint
    plasma_membrane_Start = drawLineFromPoint(startPoint);

    % Draw line from endPoint
    plasma_membrane_End = drawLineFromPoint(endPoint);
end
