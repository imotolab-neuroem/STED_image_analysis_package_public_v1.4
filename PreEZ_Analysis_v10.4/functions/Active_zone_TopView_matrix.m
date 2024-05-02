function Result_contour_center = Active_zone_TopView_matrix(contours, axesHandle, image_size)
    if iscell(contours)
        % Check the number of contours and combine if necessary
        if length(contours) > 1
            combinedContour = combine_contours(contours);
            x = combinedContour{1}(:, 1);
            y = combinedContour{1}(:, 2);
        else
            contour = contours{1};
            if size(contour, 2) == 2
                x = contour(:, 1);
                y = contour(:, 2);
            else
                warning('Contour does not contain a 2-column matrix.');
                return;
            end
        end
        
        % Calculate the center point of the contour
        centerX = mean(x);
        centerY = mean(y);
        
        % Plot the contour
        axes(axesHandle);
        hold on;
        plot(x, y, 'b-', 'LineWidth', 2); % Plot contour

        % Plot an 'X' mark at the center
        scatter(centerX, centerY, 100, 'x', 'c', 'LineWidth', 2); % Light blue 'X' mark

        % Save the contour and center point coordinates
        Result_contour_center = {[x, y], [centerX, centerY]};
        
        hold off;
    else
        error('The loaded .mat file does not contain "contours" or it is not a cell array.');
    end
end
