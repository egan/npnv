function list = load_file(file)
% L = load_file(F)
%
% Loads plaintext file, removes duplicate records, and returns
% a vertical array.
%
% Written 3 March by Egan McComb.

%% Open file handle.
fid = fopen(file);

%% Load file as strings.
try
	list = textscan(fid,'%s');
catch err
	if strcmp(err.identifier,'MATLAB:FileIO:InvalidFid')
		error('MATLAB:load_file:InvalidFid','Error: Could not open file.');
	else
		rethrow(err);
	end
end

%% Close file handle.
fclose('all');
end
