function initialSetupEDFx( varargin )
%initialSetupEDFx Convenience function to download all EDF and related data
%   initialSetupEDFx(destination_dir) downloads EDF data and annotations in
%   the destination directory, converts the data to Matlab file formats and
%   extractions the hypnogram from the annotations file

% Check if arguments entered by the user
if ~isempty(varargin)
    % Check if more than one argument entered by the user
    if length(varargin) > 1
        error('Unknown arguments - the function takes in only one optional argument')
    else
        % Create a directory if it doesn't exist
        download_dir = varargin{1};
        if exist(download_dir, 'dir') == 0
            fprintf('Destination directory does not exist. Creating a new directory\n\n');
            mkdir(download_dir)
        end
    end
else
    % Use current directory as the download directory
    download_dir = pwd;
end


% Download EDFx Data
downloadEDFxData(download_dir);

%DEBUG REPORT
%disp('DR: Completed: downloadEDFxData'); pause;

% Download hypnogram + annotations
downloadEDFxAnnotations(download_dir);


%DEBUG REPORT
%disp('DR: Completed: downloadEDFxAnnotations'); pause;

% Convert xls Data to use for later
lights_off_times = convertXLSData(download_dir);

% Convert EDFx Data To Matlab Format
test_dirs = dir(fullfile(download_dir, '*S*'));
test_dirs = test_dirs([test_dirs.isdir]);
for i=1:length(test_dirs)
    convertEDFxToMat(test_dirs(i).name, lights_off_times(test_dirs(i).name));
end


end