function Result_contour_center = Active_zone_SideView_matrix(contours, axesHandle, image_size)
    if iscell(contours)
        % Initialize arrays to hold all points for the final plot
        all_x = [];
        all_y = [];
        all_x_skel = [];
        all_y_skel = [];
        
            % Check the number of contours
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
                end
            end
                % Append the original contour points for this contour to the total list
                all_x = [all_x; x];
                all_y = [all_y; y];
                
                % Create a binary image from x and y coordinates
                resolution = 60; % Resolution of the image
                xRange = linspace(min(x), max(x), resolution);
                yRange = linspace(min(y), max(y), resolution);
                [X, Y] = meshgrid(xRange, yRange);
                BW = poly2mask((x-min(x))*((resolution-1)/(max(x)-min(x))), ...
                               (y-min(y))*((resolution-1)/(max(y)-min(y))), ...
                               resolution, resolution);
                
                % Flip the binary image to match the original shape orientation
                BW = flipud(BW);
                
                %% Method 1 Modification: Apply skeletonization to the longer axis
                % Determine the orientation of the shape
                xRangeLength = max(x) - min(x);
                yRangeLength = max(y) - min(y);
                
                resultMethod1 = false(size(BW));
                
                if xRangeLength > yRangeLength
                    % Shape is horizontally elongated, process column-wise
                    for col = 1:size(BW,2)
                        if any(BW(:,col)) % Check for non-empty column
                            rowIndices = find(BW(:,col));
                            meanRow = round(mean(rowIndices));
                            resultMethod1(meanRow, col) = true;
                        end
                    end
                else
                    % Shape is vertically elongated, process row-wise
                    for row = 1:size(BW,1)
                        if any(BW(row,:)) % Check for non-empty row
                            colIndices = find(BW(row,:));
                            meanCol = round(mean(colIndices));
                            resultMethod1(row, meanCol) = true;
                        end
                    end
                end
                
               % Create merged image for the current contour
               merged1 = cat(3, BW, resultMethod1, false(size(BW)));
               merged1 = double(merged1);
               mergedImages= merged1;
        %% Convert logical array to (x,y) coordinates for the skeletonized image
        [y_skel, x_skel] = find(resultMethod1);
        x_skel = x_skel * (max(x) - min(x)) / (resolution - 1) + min(x);
        % Scale and then flip y-coordinates to match the original shape orientation
        y_skel = (resolution - y_skel) * (max(y) - min(y)) / (resolution - 1) + min(y);
        % Append the skeletonized points for this contour to the total list
        all_x_skel = [all_x_skel; x_skel];
        all_y_skel = [all_y_skel; y_skel];

        %% Display
        % Use the provided axes handle
        axes(axesHandle);
        hold on; % Hold on to plot all contours on the same axes
        if length(contours) > 1
            plot(x, y, 'g-', 'LineWidth', 2); % Plot the combined contour in green
        end

        for i = 1:length(contours)
            contour = contours{i};
            if size(contour, 2) == 2
                x_original = contour(:, 1);
                y_original = contour(:, 2);
                plot(x, y, 'b-', 'LineWidth', 2); % Original shape(s)
        
                % Find the skeleton points for this contour
                [y_skel, x_skel] = find(mergedImages(:,:,2)); % Assuming 2nd channel is skeleton
                x_skel = x_skel * (max(x) - min(x)) / (resolution - 1) + min(x);
                y_skel = (resolution - y_skel) * (max(y) - min(y)) / (resolution - 1) + min(y);
                scatter(x_skel, y_skel, 20, 'r', 'filled'); % Red filled dots with a size of 20

                % Identifying points
                startPoint = [x_skel(1), y_skel(1)];
                endPoint = [x_skel(end), y_skel(end)];
                centerPointIndex = round(length(x_skel) / 2);
                centerPoint = [x_skel(centerPointIndex), y_skel(centerPointIndex)];

                scatter(x_skel, y_skel, 20, 'r', 'filled'); % Red filled dots for the skeleton
                scatter(startPoint(1), startPoint(2), 30, 'c', 'filled'); % Light blue, size 30 for start
                scatter(endPoint(1), endPoint(2), 30, 'c', 'filled');    % Light blue, size 30 for end
                scatter(centerPoint(1), centerPoint(2), 50, 'c', 'filled'); % Light blue, size 50 for center

                Result_contour_center = cell(1, 5); % Initialize the cell array
                Result_contour_center{1, 1} = [x, y];
                Result_contour_center{1, 2} = [x_skel, y_skel];
                Result_contour_center{1, 3} = [x_skel(1), y_skel(1)];
                Result_contour_center{1, 4} = [x_skel(end), y_skel(end)];
                midIndex = round(length(x_skel) / 2);
                Result_contour_center{1, 5} = [x_skel(midIndex), y_skel(midIndex)];

            else
                warning('Contour %d does not contain a 2-column matrix.', i);
            end
        end
        hold off;

    else
        error('The loaded .mat file does not contain "contours" or it is not a cell array.');
    end
end