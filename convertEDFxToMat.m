function convertEDFxToMat( saved_file, status )
%convertEDFxToMat Convert EDF file to .mat files
%   convertEDFxToMat(saved_file, status) converts the EDF file saved_file
%   to separate Matlab compatible files for each channel of data and
%   retrieves the sampling frequency and the list of channels. The status
%   needs to be non-zero for this to function and requires the use of
%   EEGLAB toolbox.


% Check for EEGLAB toolbox (BioSig plugnin is needed too! [Hassan])
if exist('eeglab') ~=2
    error('EEGLAB does not exist or not added to search path')
end

% Check status - needed only if directly passed from downloadEDFxData()
if status == 0
    error('This file has not been downloaded correctly - please try downloading again')
end

% Get file name and path of the saved file
[test_dir,file_name,file_extension] = fileparts(saved_file); 

% Save the current cirectory and move to the test directory
init_dir = pwd;
cd(test_dir);
current_dir = test_dir;

% Folders to save files in
mkdir('matlab'); % Create folder to store matlab variables
if exist('info', 'dir') == 0,
    mkdir('info'); % Create folder to store additional info if needed
end

% Get the edf file by checking for extension
edf_file_name = dir([file_name file_extension]);

% Load edf file in Matlab - requires BioSig toolbox
% http://biosig.sourceforge.net/download.html
[edf, header] = sload(edf_file_name.name);

fprintf('Converting file %s ......\n', edf_file_name.name);

% Extract the channel names and clean the string
channel_names = header.Label;
number_of_channels = length(channel_names);
for i=1:number_of_channels
    temp_name = channel_names{i};
    truncate_flag = strfind(temp_name, '-');
    if (isempty(truncate_flag) == 0)
        channel_names{i} = temp_name(1:truncate_flag-1);
    else
        channel_names{i} = temp_name;
    end
    temp_name = strtrim(lower(channel_names{i})); % Convert to lowercase and remove spaces
    channel_names{i} = strrep(temp_name, ' ', '_');
end

% Extract sampling frequency
sampling_frequency = header.SampleRate;

% Change directory to folder info
old_folder = cd('info');
% Save the sampling frequency on file
fid = fopen('sampling_frequency.txt', 'w');
fprintf(fid, '%d', sampling_frequency);
fclose(fid);
% Save list of channels on file
fid = fopen('list_of_channels.txt', 'w');
for i=1:number_of_channels
    fprintf(fid, '%s\n', channel_names{i});
end
fclose(fid);

% Change back to test directory
cd(old_folder);

% Change directory to folder matlab
old_folder = cd('matlab');

% Segment channels and save separate matlab variables
for i=1:number_of_channels
    signal = edf(:,i);
    save(channel_names{i}, 'signal');
end

% Move to test directory
cd(old_folder);
cd(init_dir);

% Conversion complete
fprintf('Conversion of %s file complete\n\n', edf_file_name.name);

end

