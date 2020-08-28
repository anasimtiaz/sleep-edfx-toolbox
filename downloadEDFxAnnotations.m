function [saved_file, status] = downloadEDFxAnnotations( varargin )
%downloadEDFxAnnotations Download EDF files from PhysioNet
%   [saved_file, status] = downloadEDFxAnnotations( ) downloads data in the current directory
%   [saved_file, status] = downloadEDFxAnnotations(destination_directory) downloads data in the destination directory
%
% saved_file is a list of all files downloaded and status corresponds to their success/failure


fprintf('Downloading ANNOTATIONS files\n\n');

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

[saved_file, status] = downloadEDFxFiles(download_dir, 'h');

