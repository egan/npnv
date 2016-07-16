function s = surlread(url)
% S = surlread(U)
%
% Frontend to MATLAB's urlread function to allow us to catch errors.
%
% Written 4 March by Egan McComb.

try
	s = urlread(url);
catch err
	if strcmp(err.identifier,'MATLAB:urlread:InvalidUrl')
		error('MATLAB:surlread:InvalidUrl','Error: Could not locate resource.');
	else
		rethrow(err);
	end
end

end
