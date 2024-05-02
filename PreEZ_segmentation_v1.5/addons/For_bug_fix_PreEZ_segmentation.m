% Install MIJ firs(see: https://www.mathworks.com/matlabcentral/fileexchange/47545-mij-running-imagej-and-fiji-within-matlab).
% Add MIJ to the Java classpath
javaaddpath('D:\Dropbox\Documents\MATLAB\PreEZ_analysis_software\PreEZ_segmentation_v1.3\ij.jar');
javaaddpath('D:\Dropbox\Documents\MATLAB\PreEZ_analysis_software\PreEZ_segmentation_v1.3\mij.jar');
% Add the Fiji jar file to the Java classpath
addpath('D:\Dropbox\Documents\MATLAB\PreEZ_analysis_software\PreEZ_Analysis_v10.0\bfmatlab');

% Start ImageJ/Fiji
MIJ.start('C:\Users\yimoto1\Documents\Documents\Yuuta_Fiji.app');

% Add a pause to give ImageJ/Fiji time to initialize
pause(5);  % Pause for 5 seconds; adjust the time as needed

% Manually select multiple image files
[filenames, pathname] = selectImages();


% Process all selected images
for file_idx = 1:length(filenames)
    filename = filenames{file_idx};
    fullFileName = fullfile(pathname, filename);

    % Load the image using Bio-Formats
    imageData = bfopen(fullFileName);

end

