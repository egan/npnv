function freqs = get_data(filter_method,filter,coll_bool,regexps,case_bools,names,years,speeches)
% freqs = get_data(filter_method,filter,coll_bool,regexps,case_bool,names,years,speeches)
%
% Frontend data mining function.
%
% Written 16 March by Egan McComb.

%% Generate filtered indices.
if filter_method == 'p'
	[i n p] = filter_by_pres(filter,names);
elseif filter_method == 'y'
	i = filter_by_year(filter,years);
else
	fprintf('Error: Improper filter method.');
	return;
end

%% Retrieve statistics.
freqs = collate_pres(get_freqs(speeches(i),regexps,case_bools),filter,n,coll_bool);

end
