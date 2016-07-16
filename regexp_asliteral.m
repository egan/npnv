function regexp_str = regexp_asliteral(user_input)
% R = regexp_asliteral(S)
%
% Escape special regex characters.
%
% Written 16 March by Egan McComb.

user_input = regexprep(user_input,'\\','\\\\');
user_input = regexprep(user_input,'\[','\\[');
user_input = regexprep(user_input,'\]','\\]');
user_input = regexprep(user_input,'\^','\\^');
user_input = regexprep(user_input,'\$','\\$');
user_input = regexprep(user_input,'\.','\\.');
user_input = regexprep(user_input,'\|','\\|');
user_input = regexprep(user_input,'\?','\\?');
user_input = regexprep(user_input,'\*','\\*');
user_input = regexprep(user_input,'\+','\\+');
user_input = regexprep(user_input,'\(','\\(');
user_input = regexprep(user_input,'\)','\\)');

regexp_str = user_input;

end
