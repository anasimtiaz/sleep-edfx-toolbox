function viewEDFxSignals( signal, ref_times, start_time, end_time, f_samp, hypnogram )
%viewEDFxSignals Plots a signal in time interval with its hypnogram
%   viewEDFxSignals(signal, ref_times, start_time, end_time, f_samp, hypnogram)
%   Plots a signal together with its hypnogram between start_time and
%   end_time where ref_times is obtained from the loadEDFx() function
%   Time can be entered as string in this format: hh:mm:ss


% Get reference start and end times
ref_start_time  = ref_times(1,:);
ref_end_time    = ref_times(2,:);
data_start_time = datevec(start_time);
data_end_time   = datevec(end_time);

% If start and end times are on different days (past midnight) the vector
% needs to be corrected for that
if ref_start_time(3) ~= ref_end_time(3)
    % temporary end time
    temp_end_time = data_end_time;
    temp_end_time(3)=ref_end_time(3);
    if etime(temp_end_time, ref_end_time) > 0
        data_end_time(3) = ref_start_time(3);
    else
        data_end_time(3) = ref_end_time(3);
    end
    if etime(data_start_time, ref_start_time) < 0
        data_start_time(3) = ref_end_time(3);
    end
else
    data_start_time(3) = ref_start_time(3);
    data_end_time(3) = ref_end_time(3);
end


% Check if the start time entered is more than the reference start time
if etime(data_start_time, ref_start_time) < 0 || etime(data_start_time, ref_end_time) > 0
    error('Start time entered is less than reference data start time or greater than end time');
end

% Check if the start time entered is more than the reference start time
if etime(data_end_time, ref_end_time) > 0
    error('End time entered is more than reference data end time');
end

% Check if the end time is more than reference start time
if etime(data_end_time, ref_start_time) < 0
    error('End time entered is more than reference data end time or less than data start time');
end

% Check if the entered start and end times make sense
if etime(data_start_time, data_end_time) > 0
    error('Incorrect start or end time')
end

  
% Start and end indices used to plot data
plot_start_sample = (etime(data_start_time, ref_start_time))*f_samp + 1;
plot_end_sample = (etime(data_end_time, ref_start_time))*f_samp;
dispdata_signal = signal(plot_start_sample:plot_end_sample);
n = length(dispdata_signal);
start_date = datenum(data_start_time);
end_date = datenum(data_end_time);
time_data = linspace(start_date,end_date,n);

% Extract hypnogram from the expanded hypnogram
expanded_hypnogram = getResampledHypnogram(hypnogram, f_samp);
dispdata_hypnogram = expanded_hypnogram(plot_start_sample:plot_end_sample);

% Plot data
figure
subplot(2,1,1)
plot(time_data,dispdata_signal)
datetick('x','HH:MM:SSPM')
axis 'auto x'
xlimits = get(gca, 'xlim');

% Plot hypnogram and convert numberical labels to slep stages
subplot(2,1,2)
plot(time_data,dispdata_hypnogram)
datetick('x','HH:MM:SSPM')
set(gca, 'ytick', [-1, 0, 1, 2, 3, 4, 7, 9]);
ylim([-2,10]);
set(gca,'yticklabel',{'M', 'X', '1', '2', '3', '4', 'R', 'W'});
set(gca, 'xlim', xlimits)
%axis 'auto x'

% Label mapping
% W -> 9
% 1 -> 1
% 2 -> 2
% 3 -> 3
% 4 -> 4
% R -> 7
% M -> -1
% X -> 0

end

