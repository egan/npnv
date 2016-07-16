function [] = create_db(names, years, speeches)
% create_db(N, Y, S)
%
% Given arrays of names, years, and speeches, saves a database
% containing the data sorted chronologically.
%
% Written 3 March by Egan McComb.

%% Find the first index of each duplicate year.
years_uniq = unique(years);
years_freq = hist(years,years_uniq);
i_dup = find(years_freq~=1);
years_dup = years_uniq(i_dup);
i_dup = [];
for k = 1:length(years_dup)
	i_dup = [i_dup find(years==years_dup(k),1,'first')];
end

%% Flip records with duplicate years if necessary.
for k = i_dup
	if strcmp(names(k+1,:),names(k+2,:))~=1
		name_temp = names(k,:);
		speech_temp = speeches{k};
		names(k,:) = names(k+1,:);
		speeches{k} = speeches{k+1};
		names(k+1,:) = name_temp;
		speeches{k+1} = speech_temp;
	end
end

%% Transpose.
years = years';
speeches = speeches';

%% Save the database.
save data.mat names years speeches;
end
