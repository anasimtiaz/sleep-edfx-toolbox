function [saved_file, status] = downloadEDFxFiles( destination_dir, src_dir, mode )
%downloadEDFxFiles Download EDF files from PhysioNet
%   [saved_file, status] = downloadEDFxFiles( destination_directory, src_dir, mode ) 
%   downloads data in the destination directory or copies from the source
%   to the destionation directory. If there is no source directory src_dir
%   must be passed as ''.
%   mode='h' or mode='d' will download hypnogram or data files respectively
%
% saved_file is a list of all files downloaded and status corresponds to their success/failure


base_content_url = 'https://physionet.org/content/sleep-edfx/1.0.0/';

if strcmp(src_dir, '')
    base_files_url = 'https://physionet.org/files/sleep-edfx/1.0.0/';
else
    base_files_url = src_dir;
end

% PhysioNet URL for parsing to get test names
edfx_content_url_SC = [base_content_url 'sleep-cassette/'];
edfx_content_url_ST = [base_content_url 'sleep-telemetry/'];

if strcmp(src_dir, '')
    edfx_files_url_SC = [base_files_url 'sleep-cassette/'];
    edfx_files_url_ST = [base_files_url 'sleep-telemetry/'];
else
    edfx_files_url_SC = fullfile(base_files_url, 'sleep-cassette');
    edfx_files_url_ST = fullfile(base_files_url, 'sleep-telemetry');
end

% Regular expression to get list of all edf files from the html source
if mode == 'd'
    regexp_string = '\/[A-Z]+[\d]+[A-Z\d]+-PSG.edf\"';
elseif mode == 'h'
    regexp_string = '\/[A-Z]+[\d]+[A-Z\d]+-Hypnogram.edf\"';
else
    error('Unknown download mode');
end

% Read the url
edfx_webpage_source_SC = urlread(edfx_content_url_SC);
edfx_webpage_source_ST = urlread(edfx_content_url_ST);

% Get list of edf files by regex matching
edf_files = [regexp(edfx_webpage_source_SC,regexp_string,'match'), regexp(edfx_webpage_source_ST,regexp_string,'match')];

% Create placeholders to store list of saved files and their status
saved_file = cell(length(edf_files):1);
status = cell(length(edf_files):1);

% Loop through to download each edf file
for i=1:length(edf_files)
    
    % extract name of edf file
    this_file = edf_files{i}(2:end-1);
    this_file_split = string(this_file).split('-');
    folder_name = this_file_split(1);
    folder_name = convertStringsToChars(folder_name);
    folder_name = folder_name(1:end-2);
    
    % Check if files is already downloaded (to avoid re-downloading)
    if exist(fullfile(destination_dir, folder_name, this_file), 'file') ~= 0
        % don't download the file if it exist
        fprintf('File already exist file: %s (%d of %d)\n', this_file, i, length(edf_files));
        fprintf('If you need to re-download the file, delete directory: %s \n', fullfile(destination_dir, folder_name));
        saved_file{i} = fullfile(destination_dir, folder_name, this_file);
        status{i} = 1;
    else
        % download the file
        
        % create folder for download
        if exist(destination_dir, 'dir') ~= 0
            if exist(fullfile(destination_dir, folder_name), 'dir') == 0
                mkdir(destination_dir, folder_name);
            end
        end
        path_of_file = fullfile(destination_dir, folder_name, this_file);
    
        % url of the edf file to download
        if strcmp(this_file(1:2), 'SC')
            if strcmp(src_dir, '')
                url_of_file = [edfx_files_url_SC this_file];
            else
                url_of_file = fullfile(edfx_files_url_SC, this_file);
            end
        else
            if strcmp(src_dir, '')
                url_of_file = [edfx_files_url_ST this_file];
            else
                url_of_file = fullfile(edfx_files_url_ST, this_file);
            end
        end
        
        if strcmp(src_dir, '')
            fprintf('Downloading file: %s (%d of %d)\n', this_file, i, length(edf_files));
            [saved_file{i}, status{i}]= urlwrite(url_of_file, path_of_file);
        else
            fprintf('Copying file: %s (%d of %d)\n', this_file, i, length(edf_files));
            copyfile(url_of_file, path_of_file);
            saved_file{i} = path_of_file;
            status{i} = 1;
        end
    end
end


% Download excel records for hypnograms
if mode == 'h'
    path_of_file_SC = fullfile(destination_dir, 'SC-subjects.xls');
    path_of_file_ST = fullfile(destination_dir, 'ST-subjects.xls');
    
    if strcmp(src_dir, '')
        fprintf('\nDownloading annotations spreadsheet...\n')
        url_of_file_SC = [base_files_url 'SC-subjects.xls'];
        url_of_file_ST = [base_files_url 'ST-subjects.xls'];
        urlwrite(url_of_file_SC, path_of_file_SC);
        urlwrite(url_of_file_ST, path_of_file_ST);
    else 
        fprintf('\Copying annotations spreadsheet...\n')
        url_of_file_SC = fullfile(base_files_url, 'SC-subjects.xls');
        url_of_file_ST = fullfile(base_files_url, 'ST-subjects.xls');
        copyfile(url_of_file_SC, path_of_file_SC);
        copyfile(url_of_file_ST, path_of_file_ST);
    end
    
end

if strcmp(src_dir, '')
    fprintf('\nDownload complete!\n')
else
    fprintf('\Copy of files complete!\n')
end

end


