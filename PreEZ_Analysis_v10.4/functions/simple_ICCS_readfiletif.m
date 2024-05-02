function A=simple_ICCS_readfiletif(fname)
info = imfinfo(fname);
nslice = numel(info);
A=imread(fname, 1);  % read tif stack data
for k = 2:nslice
    B = imread(fname, k);
    A=cat(3,A,B);
end

end 