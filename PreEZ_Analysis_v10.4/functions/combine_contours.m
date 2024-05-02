function combinedContour = combine_contours(contours)
    % This function returns a cell array with a single element containing
    % the combined contour created from a convex hull of multiple contours.

    % Check if the input is a cell array
    if ~iscell(contours)
        error('Input must be a cell array of contours.');
    end

    % Initialize an array to hold all points
    allPoints = [];

    % Combine all contour points into a single array
    for i = 1:length(contours)
        contour = contours{i};
        if size(contour, 2) == 2
            allPoints = [allPoints; contour]; % Append points
        else
            disp(['Contour ', num2str(i), ' does not have two columns. Skipped.']);
        end
    end

    % Compute the convex hull of the combined points, if any
    combinedContour = {}; % Initialize an empty cell array
    if ~isempty(allPoints)
        k = convhull(allPoints(:,1), allPoints(:,2));
        combinedContour{1} = allPoints(k,:); % Get the points that make up the convex hull and store in a cell
    else
        disp('No points to combine.');
    end
    
    % The combinedContour is now a cell array with a single cell containing the convex hull points
end
