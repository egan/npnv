function regexp_str = regexp_asphrase(user_input)
% R = regexp_asphrase(S)
%
% Convert spaces in a user string to \s+.
%
% Written 7 March by Aaron Huffman.

len = length(user_input);
regexp_str = '\s+';
for i = 1:len
	if (user_input(i) == ' ')
		regexp_str = horzcat(regexp_str, '\s+');
	else
		regexp_str = horzcat(regexp_str, user_input(i));
	end
end
regexp_str = horzcat(regexp_str, '\s+'); 

end

