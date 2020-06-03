function [] = set_binpath()
    % Path to mineos fortran binaries
    path2BIN = '../../MINEOS/bin';
    % Path to gtimeout
    path2gtimeout = '/usr/local/bin';
    setenv('PATH', [path2BIN,':',path2gtimeout,':',getenv('PATH')]);
end