function [ resampled_hypnogram ] = getResampledHypnogram( hypnogram, f_samp )
%getResampledHypnogram Create a vector of hypnogram values size of data
%   [resampled_hypnogram] = getResampledHypnogram(hypnogram, f_samp)
%   returns a vector of hypnogram values which is the same dimension as
%   that of data. It takes in the original hypnogram and sampling frequency
%   and returns the resampled hypnogram with the following mapping to
%   easily plot hypnogram on top of data
%   W -> 9
%   1 -> 1
%   2 -> 2
%   3 -> 3
%   4 -> 4
%   R -> 7
%   M -> -1
%   X -> 0

% Define epoch size
epoch_size = 30;


% Convert to numbers to make plotting easy
num_hypnogram = zeros(size(hypnogram));
num_hypnogram(hypnogram=='W')=9;
num_hypnogram(hypnogram=='1')=1;
num_hypnogram(hypnogram=='2')=2;
num_hypnogram(hypnogram=='3')=3;
num_hypnogram(hypnogram=='4')=4;
num_hypnogram(hypnogram=='R')=7;
num_hypnogram(hypnogram=='M')=-1;
num_hypnogram(hypnogram=='X')=0;
num_hypnogram(hypnogram=='?')=0;

% Container for the new larger hypnogram vector
resampled_hypnogram = zeros(length(num_hypnogram)*epoch_size*f_samp, 1);

% Expand each hypnogram value over a period of 30s * sampling frequency
for i=1:length(num_hypnogram)
    rh_start = epoch_size * f_samp * (i-1) + 1;
    rh_end = epoch_size * f_samp * i;
    resampled_hypnogram(rh_start:rh_end, 1) = num_hypnogram(i,1);
end






