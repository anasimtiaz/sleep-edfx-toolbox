function [saved_file, status] = downloadEDFxData( varargin )
%downloadEDFxData Download EDF files from PhysioNet
%   [saved_file, status] = downloadEDFxData( ) downloads data in the current directory
%   [saved_file, status] = downloadEDFxData( destination_directory ) downloads data in the destination directory
%
% saved_file is a list of all files downloaded and status corresponds to their success/failure





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

%current_dir = pwd;

% PhysioNet URL for parsing to get test names
edfx_url = 'http://physionet.org/physiobank/database/sleep-edfx/';

% Regular expression to get list of all edf files from the html source
regexp_string = '\"[A-Z]+[\d]+[A-Z\d]+-PSG.edf\"';

% Read the url
edfx_webpage_source = urlread(edfx_url);

% Get list of edf files by regex matching
edf_files = regexp(edfx_webpage_source,regexp_string,'match');

% Create placeholders to store list of saved files and their status
saved_file = cell(length(edf_files):1);
status = cell(length(edf_files):1);

% Loop through to download each edf file
for i=1:length(edf_files)
    
    % extract name of edf file
    this_file = edf_files{i}(2:end-1);
    folder_name = this_file(1:end-8);
         
    % create folder for download
    if exist(download_dir, 'dir') == 0,
        mkdir(download_dir, folder_name);
    end
    path_of_file = fullfile(download_dir, folder_name, this_file);
    
    % url of the edf file to download
    url_of_file = [edfx_url this_file];
    
    % Check if files is already downloaded (to avoid re-downloading)
    if exist(folder_name, 'dir') == 0,

    % don't download the file if it exist
    fprintf('File already exist file: %s (%d of %d)\n', this_file, i, length(edf_files));
    fprintf('If you need to re-download the file, delete directory: %s \n', fullfile(download_dir, folder_name));
    saved_file{i} = path_of_file;
    status{i} = 1;
    
    else
        
    % download the file
    fprintf('Downloading file: %s (%d of %d)\n', this_file, i, length(edf_files));
    [saved_file{i}, status{i}] = urlwrite(url_of_file,path_of_file);
    end
end

fprintf('\nDownload complete!\n')

end

