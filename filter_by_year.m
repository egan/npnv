function speech_indices = filter_by_year(yearv,years)
% I = filter_by_year(Y,D)
%
% Takes an input of a vector of 4 digit years and returns the indices 
% in data.mat containing speeches given in each of those years. Also
% requires vector years from data.mat.
%
% Written 7-8 March by Aaron Huffman.

speech_indices = [];

for i = 1:length(yearv)
	speech_indices = vertcat(speech_indices,find(years==yearv(i)));
end

if min(yearv) < min(years) || max(yearv) > max(years)
	error('MATLAB:ngram:filter_by_year:InvalidYr', 'Error: Invalid year query.');
end
end
