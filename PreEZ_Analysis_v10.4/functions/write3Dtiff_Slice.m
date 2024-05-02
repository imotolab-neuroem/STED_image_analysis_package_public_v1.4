function write3Dtiff_Slice(array, filename, three_color_Flag)
dims = size(array);

% Ensure the array has four dimensions
if length(dims) < 4
    dims(end+1:4) = 1;
end

% Set data type specific fields
if isa(array, 'single')
    bitsPerSample = 32;
    sampleFormat = Tiff.SampleFormat.IEEEFP;
elseif isa(array, 'uint16') || isa(array, 'int16')
    bitsPerSample = 16;
    sampleFormat = Tiff.SampleFormat.UInt;
elseif isa(array, 'uint8')
    bitsPerSample = 8;
    sampleFormat = Tiff.SampleFormat.UInt;
else
    disp('Unsupported data type');
    return;
end

% Open TIFF file for each slice in append mode
outtiff = Tiff(filename, 'a');

% Loop through slices
for s = 1:dims(4)
    % Set tag structure for each frame
    tagstruct.ImageLength = dims(1);
    tagstruct.ImageWidth = dims(2);
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.ExtraSamples = Tiff.ExtraSamples.AssociatedAlpha;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    % Set SamplesPerPixel based on the number of channels
    if three_color_Flag
        tagstruct.SamplesPerPixel = 3; % Three channels
    else
        tagstruct.SamplesPerPixel = 2; % Two channels
    end
    tagstruct.BitsPerSample = bitsPerSample;
    tagstruct.SampleFormat = sampleFormat;
    
    % Set the tag for the current frame
    outtiff.setTag(tagstruct);
    
    % Write the frame
    outtiff.write(array(:,:,:,s));
    
    % Create a new directory for the next frame
    if s ~= dims(4)
        outtiff.writeDirectory();
    end
end

% Close the file
outtiff.close();
end

