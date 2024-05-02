%% Segmentation code for STED images, Yuuta Imoto 2024 Jan.
clear; clc; close all;

addpath ./bfmatlab
addpath ./functions

% setup for imageJ/Fiji java
scriptDir = fileparts(mfilename('fullpath'));
ijPath = fullfile(scriptDir, 'addons', 'ij.jar');
mijPath = fullfile(scriptDir, 'addons', 'mij.jar');

javaaddpath(ijPath);
javaaddpath(mijPath);

% Manually select multiple image files
[filenames, pathname] = selectImages();
% Process all selected images
if ~isempty(filenames)
    firstFileName = fullfile(pathname, filenames{1});
    disp('Initializing bioformat importer');
    imageData = bfopen(firstFileName);
end

MIJ.start('C:\Users\yimoto1\Documents\Documents\Yuuta_Fiji.app');

% Process all selected images
for file_idx = 1:length(filenames)
    filename = filenames{file_idx};
    disp(['Processing file: ', filename]);

    % Load the image using ImageJ
    imagePlus = ij.IJ.openImage([pathname, filename]);
    disp('Image loaded.');

    % Convert the displayed image to a composite image
    ij.IJ.run('Make Composite', '');

    % Get the composite image from the WindowManager
    try
        composite_image = ij.WindowManager.getCurrentImage();
        disp('Composite image retrieved.');
        stack = composite_image.getImageStack();
        nChannels = composite_image.getNChannels();
        for ch = 1:nChannels
            processor = stack.getProcessor(ch);
            pixels = processor.getPixels();
            meanIntensity = mean(double(pixels(:)));
            disp(['Mean intensity of Channel ', num2str(ch), ': ', num2str(meanIntensity)]);
        end
    catch e
        disp('Failed to retrieve composite image.');
        disp(getReport(e, 'extended', 'hyperlinks', 'off'));
    end

   % Prompt before proceeding to the next image
    input('Press Enter to continue to the next image...', 's');

    composite_image.close();
end

% Quit ImageJ after processing all images
MIJ.exit();
