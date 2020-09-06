function [saved_file, status] = downloadEDFxData( varargin )
%downloadEDFxData Download EDF files from PhysioNet
%   [saved_file, status] = downloadEDFxData( ) downloads data in the current directory
%   [saved_file, status] = downloadEDFxData( destination_directory ) downloads data in the destination directory
%   [saved_file, status] = downloadEDFxData( destination_directory, src_dir ) copies data from the source directory in to the destination directory
%
% saved_file is a list of all files downloaded and status corresponds to their success/failure


fprintf('Downloading DATA files\n\n');

% Check if arguments entered by the user
if ~isempty(varargin)
    % Check if more than one argument entered by the user
    if length(varargin) > 2
        error('Unknown arguments - the function takes in only two optional arguments')
    elseif length(varargin) == 2
        % Create a directory if it doesn't exist
        destination_dir = varargin{1};
        if exist(destination_dir, 'dir') == 0
            fprintf('Destination directory does not exist. Creating a new directory\n\n');
            mkdir(destination_dir)
        end
        src_dir = varargin{2};
        if exist(destination_dir, 'dir') == 0
            error('Source directory with data does not exist. Please check the source path.')
        end
    else
        % Create a directory if it doesn't exist
        destination_dir = varargin{1};
        if exist(destination_dir, 'dir') == 0
            fprintf('Destination directory does not exist. Creating a new directory\n\n');
            mkdir(destination_dir)
        end
        src_dir = '';
    end
else
    % Use current directory as the download directory
    destination_dir = pwd;
    src_dir = '';
end

[saved_file, status] = downloadEDFxFiles(destination_dir, src_dir, 'd');