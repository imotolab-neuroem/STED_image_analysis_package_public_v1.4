function [filenames, pathname] = selectImages()
    % Select multiple image files using a file dialog
    [filenames, pathname] = uigetfile({'*.tif;*.jpg;*.png', 'Image files (*.tif, *.jpg, *.png)'; ...
                                      '*.*', 'All Files (*.*)'}, ...
                                      'Select image files', ...
                                      'MultiSelect', 'on');
    if isequal(filenames, 0)
        error('No files were selected.');
    end

    % Convert to cell array if a single file is selected
    if ischar(filenames)
        filenames = {filenames};
    end
end
