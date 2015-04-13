function [ all_data, f_samp, number_of_epochs, hypnogram_f, times ] = loadEDFx( test_dir, classification_mode )
%loadEDFx Reads sleep data for a test in specified classification mode
%   [all_data, f_samp, number_of_epochs, hypnogram, times] = loadEDFx(test_dir, classification_mode)
%   Data from the test_dir is read in the classification mode as RK or AASM
%   all_data is container (key-value) with all channels of data
%   To get channel fpz, use all_data('fpz')
%   Sampling frequency, number of 30s epochs and hypnogram are also
%   provided and times contains the start and end times used for
%   viewing/plotting data

% Check if the classification mode is correct
if ~(strcmp(classification_mode,'AASM') || strcmp(classification_mode,'RK'))
   error('Unknown classification mode: User RK or AASM') 
end

% Define epoch size
ep = 30;

% Read sampling frequency and hypnogram
f_samp = textread(fullfile(test_dir, 'info', 'sampling_frequency.txt'));
hypnogram = load(fullfile(test_dir, 'matlab', 'hypnogram.mat'));
hypnogram = hypnogram.hypnogram;


% Load all time values from text files
lights_off_time = textread(fullfile(test_dir, 'info', 'lights_off_time.txt'),'%s');
lights_off_time = lights_off_time{1};
rec_start_time = textread(fullfile(test_dir, 'info', 'rec_start_time.txt'),'%s');
rec_start_time = rec_start_time{1};
hyp_start_time  = textread(fullfile(test_dir, 'info', 'hyp_start_time.txt'),'%s');
hyp_start_time  = hyp_start_time{1};
lights_on_time   = textread(fullfile(test_dir, 'info', 'lights_on_time.txt'),'%s');
lights_on_time   = lights_on_time{1};
rec_stop_time   = textread(fullfile(test_dir, 'info', 'rec_stop_time.txt'),'%s');
rec_stop_time   = rec_stop_time{1};

% Convert the times to a date vector
lights_off_vec = datevec(lights_off_time);
rec_start_vec = datevec(rec_start_time);
lights_on_vec = datevec(lights_on_time);
hyp_start_vec = datevec(hyp_start_time);
rec_stop_vec = datevec(rec_stop_time);

% Check if hyp_start_time and rec_start_time are different and of different
% days (i.e. past midnight)
hs_flag = ~(sum(hyp_start_vec==rec_start_vec)==6); 
hs_diff = etime(hyp_start_vec,rec_start_vec);
if hs_flag
    if hs_diff < 0
        hyp_start_vec(3)=2;
        hs_diff = etime(hyp_start_vec,rec_start_vec);
    end
end

% Check if lights on and recording start time are same day or different
et_diff = etime(lights_on_vec,rec_start_vec);
if et_diff < 0
    lights_on_vec(3)=2;
    et_diff = etime(lights_on_vec,rec_start_vec);
end
rec_stop_vec(3)=lights_on_vec(3);

% Check if lights off and recording start time are same day or different
lo_diff = etime(lights_off_vec,rec_start_vec);
if lo_diff < 0 && lights_off_vec(4)-rec_start_vec(4)<0
    lights_off_vec(3)=2;
    lo_diff = etime(lights_off_vec,rec_start_vec);
end


% At this point all the dates have been corrected for
% the next step is to choose either hyp_start of lights_off
% as the begin time


% Determine which is the latest time to use as the begin time 
% from which to read data from
bt_diff = etime(lights_off_vec,hyp_start_vec);
if bt_diff > 0
    begin_time = lights_off_time;
    btvec = lights_off_vec;
else
    begin_time = hyp_start_time;
    btvec = hyp_start_vec;
end


% Read the list of channels and save all channels in a container
all_channels = textread(fullfile(test_dir, 'info', 'list_of_channels.txt'),'%s');
all_data = containers.Map();
for i=1:length(all_channels)
    this_channel = fullfile(test_dir, 'matlab', all_channels{i});
    load(this_channel);
    all_data(all_channels{i}) = signal;
    clear signal
end


% Load data from the first channel in list for calculation (all channels are of same size)
first_channel = fullfile(test_dir, 'matlab', all_channels{1});
load(first_channel);
EXG_i=signal;
clear signal


% Find length of data and its duration
% number_of_epochs = length(EXG_i)/(f_samp*ep);
% data_duration_orig = etime(rec_stop_vec, rec_start_vec);

% Difference between recording stop and lights on time to determine which
% to use as the end time
end_time_diff = etime(rec_stop_vec,lights_on_vec);
if end_time_diff < 0
    ftvec = rec_stop_vec;
else
    ftvec = lights_on_vec;
end

% The start and end times are btvec and ftvec
times = [btvec; ftvec];

% Duration of time between these times
data_duration = etime(ftvec, btvec);

% Number of epochs obtained from this duration
epochs_from_duration = floor(data_duration / ep);

% Select the right number of epochs to use in case the size of hypnogram
% shows a different number of epochs
if length(hypnogram)  < epochs_from_duration
    epochs_to_use = length(hypnogram);
else
    epochs_to_use = epochs_from_duration;
end

% Index of start and end samples to read data
e_start = etime(btvec,rec_start_vec) * f_samp + 1;
e_stop  = e_start + epochs_to_use * ep * f_samp - 1;

% Read each channel between the two indices
for i=1:length(all_channels)
    data_i = all_data(all_channels{i});
    all_data(all_channels{i}) = data_i(e_start:e_stop);
    clear data_i
end

% Determine number of epochs
number_of_epochs = length(all_data(all_channels{1}))/(f_samp*ep);

% Find the hypnogram start index for slicing since that is not the same as
% data start time or end time
hyp_offset = etime(btvec, hyp_start_vec) / 30;
if (hyp_offset < 0)
    error('ERROR: hyp_offset < 0');
end

% Hypnogram start index
h_start = hyp_offset + 1;

% Hypnogram end index
h_end = hyp_offset + epochs_to_use;

hypnogram_f = hypnogram(h_start:h_end);


% Convert to AASM if that is the classification_mode
% Conversion is as follows
% M  -> W
% 4  -> 3
% Rest are same: W,1,2,3,R
if strcmp(classification_mode,'AASM')
    hypnogram_f(hypnogram_f=='M')='W';
    hypnogram_f(hypnogram_f=='4')='3';
end

%{
% Print test details
if ~isempty(varargin)
    if (varargin{1}==1)
        % Print diagnostic summary
        fprintf('Test      : %s\n', test_dir);
        fprintf('Sampling F: %d\n', f_samp);
        
        fprintf('Recording Start Time : %s\n', rec_start_time);
        fprintf('Lights Off Time      : %s\n', lights_off_time);
        fprintf('Hypnogram Start Time : %s\n', hyp_start_time);
        fprintf('Lights On Time       : %s\n', lights_on_time);
        fprintf('Recording Stop Time  : %s\n', rec_stop_time);
        
        %fprintf('Start Flag: %d\n', st_flag);
        fprintf('Hypno Flag: %d\n', hs_flag);
        fprintf('Begin Time: %s\n', begin_time);
        
        fprintf('Epochs in data: %d\n', number_of_epochs);
        fprintf('Epochs from all data duration: %d\n', data_duration_orig/ep);
        fprintf('Epochs in hypnogram : %d\n', length(hypnogram));
        fprintf('Epochs from sleep data duration: %d\n', epochs_from_duration);
        
        fprintf('Epochs from sliced EEG: %d\n', (length(all_data(all_channels{1}))/(f_samp*ep)));
        fprintf('Epochs from sliced Hyp: %d\n', length(hypnogram_f));
        fprintf('Hyp start and end indices: %d %d\n', h_start, h_end);
        
        %if length(hypnogram_f) ~= (length(EEG)/(f_samp*ep))
        %    error('ERROR: Hypnogram and EEG sliced epochs mismatch');
        %end
        
        fprintf('\n\n\n\n');
    else
        fprintf('WARNING: Unknown second argument');
    end
end
%}

end

