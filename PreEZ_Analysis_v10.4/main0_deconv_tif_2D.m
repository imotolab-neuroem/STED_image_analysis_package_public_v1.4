%% Deconvolution for 2ch STEDYCON .tif images, Yuuta Imoto 2023 Aug.

% Close all figures, clear variables, and clear the command window
close all;
clear;
clc;

% Add necessary paths
addpath ./bfmatlab;
addpath ./functions;

% Select the folder containing the TIFF files
imageDirectory = uigetdir('', 'Please select the folder containing two-channel TIFF files');
tifList = dir(fullfile(imageDirectory, '*.tif'));

% Load PSF images using tiffRead function
[filename_635, pathname_635, ~] = uigetfile('*.tif', 'Please select the PSF for 635 channel');
[filename_594, pathname_594, ~] = uigetfile('*.tif', 'Please select the PSF for 594 channel');

PSF_635 = double(tiffRead(fullfile(pathname_635, filename_635)));
PSF_594 = double(tiffRead(fullfile(pathname_594, filename_594)));

% Create output directory
numberIterations = 10;
outputDirectory = fullfile(imageDirectory, strcat('decon_', num2str(numberIterations)));
mkdir(outputDirectory);

% Loop through each TIFF file in the selected folder
for ii = 1:length(tifList)
    tifFilename = tifList(ii).name;

    % Read the TIFF file using tiffRead function
    tifPath = fullfile(imageDirectory, tifFilename);
    temp_data = tiffRead(tifPath);

    % Determine the total number of slices and divide by 2 (for two channels)
    totalSlices = size(temp_data, 3);
    slicesPerChannel = floor(totalSlices / 2);

    % Initialize the 4D array using the dimensions of the processed images
    height = size(temp_data, 1);
    width = size(temp_data, 2);
    numChannels = 2; % Two channels
    img_composite_deconv_slice = zeros(height, width, numChannels, slicesPerChannel, 'uint16');

    % Process each slice for each channel
    for sliceIndex = 1:slicesPerChannel
        % Process slice for 635 channel
        img_635 = temp_data(:, :, sliceIndex);
        img_635 = imgaussfilt(img_635, 1.2);
        [img_635_deconv, enhancedPSF_635] = twoStepDeconvolution_ModifyMaxIntensity(img_635, PSF_635, numberIterations);

        % Process corresponding slice for 594 channel
        img_594 = temp_data(:, :, sliceIndex + slicesPerChannel);
        img_594 = imgaussfilt(img_594, 1.2);
        [img_594_deconv, enhancedPSF_594] = twoStepDeconvolution_ModifyMaxIntensity(img_594, PSF_594, numberIterations);

        % Combine the deconvolved channels into a composite image
        img_composite_deconv = zeros(size(img_635_deconv, 1), size(img_635_deconv, 2), 2);
        img_composite_deconv(:,:,1) = img_635_deconv;
        img_composite_deconv(:,:,2) = img_594_deconv;

        % Ensure the composite image is in uint16 format
        img_composite_deconv = uint16(img_composite_deconv);

        % Store the processed composite image in the 4D array
        img_composite_deconv_slice(:, :, :, sliceIndex) = img_composite_deconv;
   
    end
        % Save the deconvolved composite image using write3Dtiff function
        outputFilename = fullfile(outputDirectory, strcat(tifFilename(1:end-4), '_slice_', num2str(sliceIndex), '_DualBlindDecon_', num2str(numberIterations), '.tif'));
        write3Dtiff(img_composite_deconv_slice, outputFilename);

    % Save enhanced PSFs using tiffWrite function
    tiffWrite(uint16(enhancedPSF_635 ./ max(enhancedPSF_635(:)) .* 2^16), fullfile(outputDirectory, 'enhancedPSF_635.tif'));
    tiffWrite(uint16(enhancedPSF_594 ./ max(enhancedPSF_594(:)) .* 2^16), fullfile(outputDirectory, 'enhancedPSF_594.tif'));
end