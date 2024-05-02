function writeMultiChannelTiff(img, filename)
    t = Tiff(filename, 'w');
    
    tagstruct.ImageLength = size(img, 1);
    tagstruct.ImageWidth = size(img, 2);
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 16;
    tagstruct.SamplesPerPixel = size(img, 3);  % Number of channels
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
    
    t.setTag(tagstruct);
    t.write(img);
    t.close();
end
