function convertEDFxToMat( test_dir, l_off_time )
%convertEDFxToMat Convert EDF file to .mat files
%   convertEDFxToMat(saved_file, status) converts the EDF file saved_file
%   to separate Matlab compatible files for each channel of data and
%   retrieves the sampling frequency and the list of channels. The status
%   needs to be non-zero for this to function and requires the use of
%   EEGLAB toolbox.


% Check for EEGLAB toolbox (BioSig plugin is needed too! [Hassan])
if exist('sload') ~=2
    error('EEGLAB/BioSig does not exist or not added to search path')
end

% Check status - needed only if directly passed from downloadEDFxData()
if status == 0
    error('This file has not been downloaded correctly - please try downloading again')
end

% Save the current cirectory and move to the test directory
init_dir = pwd;
cd(test_dir);
current_dir = test_dir;

% Folders to save files in
mkdir('matlab'); % Create folder to store matlab variables
if exist('info', 'dir') == 0
    mkdir('info'); % Create folder to store additional info if needed
end

% Get the PSG edf file by checking for extension
psg_edf_file_name = dir('*PSG*');

% Load edf file in Matlab - requires BioSig toolbox
% http://biosig.sourceforge.net/download.html
[edf, header] = sload(psg_edf_file_name.name);

fprintf('Converting PSG Data ......\n');
fprintf('Converting file %s ......\n', psg_edf_file_name.name);

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


% Get the HYP edf file by checking for extension
hyp_edf_file_name = dir('*Hyp*');

% Load edf file in Matlab
[edf, header] = sload(hyp_edf_file_name.name);

fprintf('Converting PSG Data ......\n');
fprintf('Converting file %s ......\n', hyp_edf_file_name.name);

% load annotations
annotations = convertCharsToStrings(header.EDFplus.ANNONS);
annotations = convertStringsToChars(annotations.split('+'));

% remove first two lines
annotations(1:2)=[];

% get hypnogram from annotations
hypnogram = processEDFxHypnogram(annotations);

% get start times
rec_start_time = convertStringsToChars(num2str(header.T0(4), '%02d') + ":" + num2str(header.T0(5), '%02d') + ":" + num2str(header.T0(6), '%02d'));

split_string = split(annotations{1}, ["", "", " "]);
hyp_offset = str2num(split_string{1});
hyp_start_time = datestr(datetime(rec_start_time) + seconds(hyp_offset), 'hh:MM:ss');

lights_off_time = l_off_time;

% get end times

% get time for last Wake annotation
x = length(annotations);
while x>0
    if contains(annotations{x}, 'stage W')
        split_string = split(annotations{x}, ["", "", " "]);
        last_W_time = str2num(split_string{1});
        break;
    end
    x=x-1;
end
lights_on_time = datestr(datetime(hyp_start_time) + seconds(last_W_time) + minutes(15), 'hh:MM:ss');

% find length of recording duration
split_string = split(annotations{end}, ["", "", " "]);
length_rec = str2num(split_string{1});
rec_stop_time = datestr(datetime(rec_start_time) + seconds(length_rec), 'hh:MM:ss');



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

% Save lights off time on file
fid = fopen('lights_off_time.txt', 'w');
fprintf(fid, '%d', lights_off_time);
fclose(fid);

% Save recording start time on file
fid = fopen('rec_start_time.txt', 'w');
fprintf(fid, '%d', rec_start_time);
fclose(fid);

% Save hypnogram start time on file
fid = fopen('hyp_start_time.txt', 'w');
fprintf(fid, '%d', hyp_start_time);
fclose(fid);

% Save lights on time on file
fid = fopen('lights_on_time.txt', 'w');
fprintf(fid, '%d', lights_on_time);
fclose(fid);

% Save recording stop time on file
fid = fopen('rec_stop_time.txt', 'w');
fprintf(fid, '%d', rec_stop_time);
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

% Save hypnogram
save('hypnogram.mat', 'hypnogram');

% Move to test directory
cd(old_folder);
cd(init_dir);

% Conversion complete
fprintf('Conversion of %s file complete\n\n', edf_file_name.name);

end

