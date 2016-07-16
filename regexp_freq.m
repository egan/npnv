function freq = regexp_freq(string,reg_exp,case_bool)
% N = regexp_freq(S,R,B)
%
% Takes a string and a regular expression and returns the number of times
% the regular expression is matched in the string. Depending on case_bool,
% this is done either case sensitively (0), or not (1).
%
% Written 9-10 March by Richard Perez.

if case_bool == 1
	freq = length(regexpi(string,reg_exp)); 
else
	freq = length(regexp(string,reg_exp)); 
end

end
