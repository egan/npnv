function [] = get_db()
% getdb()
%
% Frontend function for the database module.
%
% Written 16 March by Egan McComb.

[N Y S] = parse_db(get_pids());
create_db(N,Y,S);
end
