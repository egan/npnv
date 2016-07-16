function [speech_indices,speech_numbers,pres_names] = filter_by_pres(pres_indices,names)
% [I, N, P] = filter_by_pres(P,D)
%
% Takes an input of a numeric vector corresponding to input president 
% names and returns the indices in data.mat containing speeches by
% each of those presidents, as well as the number of speeches given by
% that president, and the names themselves. Requires an input of the
% names array from the database.
%
% Written 7-8 March by Aaron Huffman.

speech_indices = [];
speech_numbers = zeros(length(pres_indices), 1);
a = 0;
b = 0;

if pres_indices(1)==1
	pres_names = names(1,:);
else
	pres_names = '';
end

%% Iterate through provided president indices.
for i = 1:length(pres_indices)
	% Reset conditions.
	pres_counter = 1;
	prev_row = names(1,:);

	% Iterate through president names.
	for j = 1:size(names,1)
		curr_row = names(j,:); 
		% Is current president different from previous?
		if strcmp(curr_row,prev_row) == 0
			pres_counter = pres_counter+1;
			a = 1;
		end
		% Is current president requested?
		if pres_counter == pres_indices(i)
			speech_indices = vertcat(speech_indices,j);
			speech_numbers(i) = speech_numbers(i)+1;
			b = 1;
		end
		if a == 1 && b == 1 && strcmp(pres_names,'') == 1
			pres_names = names(j,:);
		elseif a == 1 && b == 1
			pres_names = char(pres_names, names(j,:));
		end
		a = 0;
		b = 0;
		prev_row = curr_row;
	end
end

if max(pres_indices) > pres_counter || min(pres_indices) < 1
	error('MATLAB:ngram:filter_by_pres:InvalidInd','Error: Invalid president query.');
end
end
