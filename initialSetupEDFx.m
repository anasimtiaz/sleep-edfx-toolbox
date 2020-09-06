function initialSetupEDFx( varargin )
%initialSetupEDFx Convenience function to download all EDF and related data
%   initialSetupEDFx(destination_dir) downloads EDF data and annotations 
%   from PhysioNet in the destination directory, converts the data to 
%   Matlab file formats and extracts the hypnogram from the annotations 
%   file.
%   initialSetupEDFx(destination_dir, src_dir) copies all EDF and related 
%   data from the source test directory to the destination directory
%   extracting the data and hypnogram files.
%   initialSetupEDFx() downloads data from PhysioNet and uses the current
%   directory as the destionation directory.


% Check if arguments entered by the user
if ~isempty(varargin)
    % Check if more than one argument entered by the user
    if length(varargin) > 2
        error('Unknown arguments - the function takes in only two optional arguments')
    elseif length(varargin) == 2
        destination_dir = varargin{1};
        if exist(destination_dir, 'dir') == 0
            fprintf('Destination directory does not exist. Creating a new directory\n\n');
            mkdir(destination_dir)
        end
        src_dir = varargin{2};
        if exist(destination_dir, 'dir') == 0
            error('Source directory with data does not exist. Please check the source path.')
        end
    else
        % Create a directory if it doesn't exist
        destination_dir = varargin{1};
        if exist(destination_dir, 'dir') == 0
            fprintf('Destination directory does not exist. Creating a new directory\n\n');
            mkdir(destination_dir)
        end
    end
else
    % Use current directory as the download directory
    destination_dir = pwd;
end

addpath(pwd);

% Download EDFx Data
if length(varargin) == 2
    downloadEDFxData(destination_dir, src_dir);
else
    downloadEDFxData(destination_dir);
end



% Download hypnogram + annotations
if length(varargin) == 2
    downloadEDFxAnnotations(destination_dir, src_dir);
else
    downloadEDFxAnnotations(destination_dir);
end

% Convert xls Data to use for later
lights_off_times = convertXLSData(destination_dir);

% Convert EDFx Data To Matlab Format
test_dirs = dir(fullfile(destination_dir, '*S*'));
test_dirs = test_dirs([test_dirs.isdir]);
for i=1:length(test_dirs)
    convertEDFxToMat(fullfile(destination_dir, test_dirs(i).name), lights_off_times(test_dirs(i).name));
end


end