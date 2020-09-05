function [lights_off_times] = convertXLSData(download_dir)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


Y_SC = xlsread(fullfile(pwd, download_dir, 'SC-subjects.xls'));
Y_ST = xlsread(fullfile(pwd, download_dir, 'ST-subjects.xls'));

lights_off_times = containers.Map;

% SC Subjects
for i=1:length(Y_SC)
   subj_id = ['SC4', num2str(Y_SC(i,1),'%02d'), num2str(Y_SC(i,2))];
   lo_time = datestr(datetime(Y_SC(i,5), 'convertfrom', 'excel'), 'hh:MM:ss');
   lights_off_times(subj_id) = lo_time;
end

% ST Subjects
for i=1:length(Y_ST)
    % night1
    subj_id = ['ST7', num2str(Y_ST(i,1),'%02d'), num2str(Y_ST(i,4))];
    lo_time = datestr(datetime(Y_ST(i,5), 'convertfrom', 'excel'), 'hh:MM:ss');
    lights_off_times(subj_id) = lo_time;
    % night2
    subj_id = ['ST7', num2str(Y_ST(i,1),'%02d'), num2str(Y_ST(i,6))];
    lo_time = datestr(datetime(Y_ST(i,7), 'convertfrom', 'excel'), 'hh:MM:ss');
    lights_off_times(subj_id) = lo_time;
end

end

