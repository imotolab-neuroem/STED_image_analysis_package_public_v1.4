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

% check if images are 3 colors or not
three_color_input = input('Do these images have 3 channels? (y/n): ', 's');
three_color_flag = strcmpi(three_color_input, 'y');  % 1 for 'y', 0 for 'n'


if three_color_flag
% Start ImageJ/Fiji
IJ = ij.ImageJ();

% Add a pause to give ImageJ/Fiji time to initialize
pause(5);  % Pause for 5 seconds; adjust the time as needed

% Manually select multiple image files
[filenames, pathname] = selectImages();


% Process all selected images
for file_idx = 1:length(filenames)
    filename = filenames{file_idx};

    % Load the image using ImageJ
    imagePlus = ij.IJ.openImage([pathname, filename]);

    % Display the image
    imagePlus.show();

    % Convert the displayed image to a composite image
    ij.IJ.run('Make Composite', '');

    % Get the composite image from the WindowManager
    composite_image = ij.WindowManager.getCurrentImage();

    % Set the ROI size
    roi_width = 30;
    roi_height = 30;

    % Select multiple ROIs manually
    disp('Please manually select multiple ROIs and press "t" after selecting each ROI.');
    disp('Press any key on command window to finish it');
    
    % Wait for the user to finish selecting ROIs
    pause;

    % Get the ROIs from the ROI Manager
    roiManager = ij.plugin.frame.RoiManager.getInstance();
    rois = roiManager.getRoisAsArray();

    % Create the new folder for cropped images
    new_folder = fullfile(pathname, 'ROI');
    if ~exist(new_folder, 'dir')
        mkdir(new_folder);
    end

    % Process all ROIs
    for i = 1:numel(rois)
       % Extract slice number from ROI name
       roi = rois(i);
       roiName = char(roi.getName());
       tokens = regexp(roiName, '^(\d+)-\d+-\d+$', 'tokens');

       if ~isempty(tokens)
       firstNumber = str2double(tokens{1}{1});
         if mod(firstNumber, 2) == 0
              % If even, divide by 2
              slice_number = firstNumber / 2;
          else
              % If odd, add 1 then divide by 2
              slice_number = (firstNumber + 1) / 2;
          end
       

        % Set the current ROI
        composite_image.setRoi(rois(i));

        % Set the current slice of the image
        composite_image.setT(slice_number);

        % Duplicate the current ROI
        cropped_imagePlus = composite_image.crop();

        % Save the cropped image in the new folder named 'ROI'
        cropped_image_name = sprintf('%s_ROI_%d.tif', filename(1:end-4), i);
        cropped_image_path = fullfile(new_folder, cropped_image_name);
        ij.IJ.saveAs(cropped_imagePlus, 'Tiff', cropped_image_path);
            else
        disp(['Invalid ROI name format: ', roiName]);
    end
    end
    
    % Save the ROI information in a zip file
    roi_zip_name = sprintf('%s_ROI.zip', filename(1:end-4));
    roi_zip_path = fullfile(pathname, roi_zip_name);
    roiManager.runCommand('Save', roi_zip_path);

    % Close the original image and ROI manager
    composite_image.close();
    roiManager.close();
end

% Quit ImageJ after processing all images
IJ.quit();


else
    
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

    % Display the image
    %imagePlus.show();
   

    % Convert the displayed image to a composite image
    ij.IJ.run('Make Composite', '');

    % Get the composite image from the WindowManager
    try
        composite_image = ij.WindowManager.getCurrentImage();
        disp('Composite image retrieved.');
    catch e
        disp('Failed to retrieve composite image.');
        disp(getReport(e, 'extended', 'hyperlinks', 'off'));
    end

    % Set the ROI size
    roi_width = 30;
    roi_height = 30;

    % Select multiple ROIs manually
    disp('Please manually select multiple ROIs and press "t" after selecting each ROI.');
    disp('Press any key on command window to finish it');
    
    % Wait for the user to finish selecting ROIs
    pause;

    % Get the ROIs from the ROI Manager
    roiManager = ij.plugin.frame.RoiManager.getInstance();
    rois = roiManager.getRoisAsArray();

    % Create the new folder for cropped images
    new_folder = fullfile(pathname, 'ROI');
    if ~exist(new_folder, 'dir')
        mkdir(new_folder);
    end

    % Process all ROIs
    for i = 1:numel(rois)
       % Extract slice number from ROI name
       roi = rois(i);
       roiName = char(roi.getName());
       tokens = regexp(roiName, '^(\d+)-\d+-\d+$', 'tokens');

       if ~isempty(tokens)
       firstNumber = str2double(tokens{1}{1});
         if mod(firstNumber, 2) == 0
              % If even, divide by 2
              slice_number = firstNumber / 2;
          else
              % If odd, add 1 then divide by 2
              slice_number = (firstNumber + 1) / 2;
          end
       

        % Set the current ROI
        composite_image.setRoi(rois(i));

        % Set the current slice of the image
        composite_image.setT(slice_number);

        % Duplicate the current ROI
        cropped_imagePlus = composite_image.crop();

        % Save the cropped image in the new folder named 'ROI'
        cropped_image_name = sprintf('%s_ROI_%d.tif', filename(1:end-4), i);
        cropped_image_path = fullfile(new_folder, cropped_image_name);
        ij.IJ.saveAs(cropped_imagePlus, 'Tiff', cropped_image_path);
            else
        disp(['Invalid ROI name format: ', roiName]);
    end
    end

    % Save the ROI information in a zip file
    roi_zip_name = sprintf('%s_ROI.zip', filename(1:end-4));
    roi_zip_path = fullfile(pathname, roi_zip_name);
    roiManager.runCommand('Save', roi_zip_path);

    % Close the original image and ROI manager
    composite_image.close();
    roiManager.close();
end

% Quit ImageJ after processing all images
MIJ.exit();
end