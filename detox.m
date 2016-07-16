function out_str = detox(in_str)
% Y = detox(X)
%
% Replace undesirable character and character sequences from input
% string, including non-ASCII characters and HTML markup and escapes.
%
% Note that rather than delete offending sequences, we replace them
% with a single space, since this is the least disruptive.
% Well-formed regexes should take this into account anyway.
%
% Written 7 March by Egan McComb.

out_str = in_str;

% Remove HTML markup.
out_str = regexprep(out_str,'<[^>]*>',' ');

% Replace HTML escape sequences in speech text.
out_str = regexprep(out_str,'&amp;','&');
out_str = regexprep(out_str,'&mdash;','---');
out_str = regexprep(out_str,'&nbsp;',' ');
out_str = regexprep(out_str,'&ndash;','--');
out_str = regexprep(out_str,'&quot;','"');

% Remove bracketed parentheticals.
% XXX: Note that some of the speeches use other, unhandled conventions.
out_str = regexprep(out_str,'\[[^\]]*\]',' ');

end
