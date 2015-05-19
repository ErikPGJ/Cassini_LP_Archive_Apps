% scan nodata_log.dat and extract days and filenames

fid = fopen('nodata_log.dat'); nodatalog = textscan(fid, '%d %d %d %d %d %d %s'); fclose(fid);

% this is the date matrix [YYYY MM DD hh mm ss]
ndlog = [nodatalog{1,1} nodatalog{1,2} nodatalog{1,3} nodatalog{1,4} nodatalog{1,5} nodatalog{1,6}];

% this is the filename matrix
filenames = []; 
for i=1:length(nodatalog{1,7})
    filenames = [filenames; nodatalog{1,7}{i,1}];
end

