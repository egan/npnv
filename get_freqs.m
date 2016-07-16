function freqs = get_freqs(strings,regexps,case_bools)
% A = get_freqs(S,R,B)
%
% Takes a cell array of strings, a cell array of regular expressions, and
% an array of  boolean values for their case sensitivity, returning an
% array of frequency values for the matches of each regular expression in
% each string.
%
% The output array shows one record per speech, one field per regular expression.
%
% Written 10-11 March by Richard Perez.

freqs=[];

for i = 1:size(strings,1)
	for j = 1:size(regexps,1)
		freqs(i,j) = regexp_freq(strings{i},regexps{j,:},case_bools(j));
	end
end

end
