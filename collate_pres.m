function coll_freqs = collate_pres(freqs,pres_indices,speech_numbers,bool)
% A = collate_pres(F,I,N,B)
%
% Takes an input frequency array, president indices, the number of speeches
% given by each, and outputs a new frequency array with the data collated
% for each president, either as an average (0) or sum (1).
%
% Written 13 March by Aaron Huffman.

l = length(pres_indices);

k = 1;
coll_freqs = zeros(l,size(freqs,2));

for i = 1:l
	j = speech_numbers(i)-1;
	if bool==1
		coll_freqs(i,:) = sum(freqs((k:(j+k)),:),1);
	else
		coll_freqs(i,:) = sum(freqs((k:(j+k)),:),1)./speech_numbers(i);
	end
	k = j+k;
end

end
