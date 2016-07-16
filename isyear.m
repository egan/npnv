function bool = isyear(year,years)
% B = check_year(Y,D)
%
% Takes an input and checks whether it is a valid year in the years array.
%
% Written 17 March by Egan McComb

if isempty(year)
	bool = 0;
elseif length(find(years==year)) ~= 0
	bool = 1;
else
	bool = 0;
end

end
