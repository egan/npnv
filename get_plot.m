function [] = get_plot(filter_method,filter,coll_bool,regexps,case_bools,names,years,speeches)
% get_plot(filter_method,filter,coll_bool,regexps,case_bool,names,years,speeches)
%
% Frontend plotting function.
%
% Written 16 March by Egan McComb.

%% Generate filtered indices.
if filter_method == 'p'
	[i n p] = filter_by_pres(filter,names);
elseif filter_method == 'y'
	i = filter_by_year(filter,years);
else
	fprintf('Error: Improper filter method.');
	return
end

%% Retrieve statistics.
freqs = get_freqs(speeches(i),regexps,case_bools);

%% Plot data.
if filter_method == 'p'
	freqs = collate_pres(freqs,filter,n,coll_bool);
	plot_bar_pres(freqs,regexps,p);
else
	plot_bar_year(freqs,i,regexps,years);
end

end
