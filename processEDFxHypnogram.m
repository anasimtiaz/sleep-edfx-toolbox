function [hypnogram] = processEDFxHypnogram( annotations )
%processEDFxHypnogram Reads the annotations from hypnogram edf file to 
%   produce a hypnogram in matlab format with a value every 30s.
%   [hypnogram] = processEDFxHypnogram(annotations) uses the annotations
%   from the downloaded edf to produce a per-epoch hypnogram with the 
%   following labels: W, 1, 2, 3, 4, R, M


% Define epoch size
epoch_size = 30;

% Initialize containers for hypnogram value and duration
hyp_v = char.empty(length(annotations),0); %value
hyp_d = zeros(size(annotations)); %duration

% Extract sleep stage and the duration for which it lasts
for h=1:length(annotations)
    hyp_string = annotations{h};
    split_stage_hyp_string = split(hyp_string);
    sleep_stage = split_stage_hyp_string{end}(1);
    
    % fix for movement time
    if sleep_stage == 'e'
        hyp_v(h) = 'M';
    else
        hyp_v(h) = sleep_stage;
    end
    
    % save hyp durations
    split_hyp_string = split(hyp_string, ["", "", " "]);
    hyp_d(h) = str2num(split_hyp_string{2});
end

% Total (round) number of epochs
number_of_epochs = sum(hyp_d)/epoch_size;

% Container for hypnogram
hypnogram = char.empty(number_of_epochs,0);

% Using the duration of each stage, assign hypnogram value for each 30s
% epoch in the vector
idx=0;
for h=1:length(hyp_d)
    ep_end = hyp_d(h)/epoch_size;
    hypnogram(idx+1:idx+ep_end,1)=hyp_v(h);
    idx=idx+ep_end;
end

%{
% Convert to AASM if that is the classification_mode
% Conversion is as follows
% M  -> W
% 4  -> 3
% Rest are same: W,1,2,3,R
if strcmp(classification_mode,'AASM')
    hypnogram(hypnogram=='M')='W';
    hypnogram(hypnogram=='4')='3';
end
%}