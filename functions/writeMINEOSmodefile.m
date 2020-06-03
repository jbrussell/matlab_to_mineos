function writeMINEOSmodefile( modefile, modetype,lmin,lmax,fmin,fmax  )
% writeMINEOSmodefile( modefile, modetype,lmin,lmax,fmin,fmax  )
% 
% Function to write mode parameter file for MINEOS to use
% 
% INPUTS:
%  modefile  - name of mode file to write
%  modetype  - 'S' or 'T' or 'R' etc. (the type of mode)
%  lmin      - minimum angular order to compute
%  lmax      - maximum angular order to compute
%  fmin      - minimum freq to compute (in mHz)
%  fmax      - maximum freq to compute (in mHz)

%% defaults
if nargin < 3 || isempty(lmin)
    lmin = 0;
end
if nargin < 4 || isempty(lmax)
    lmax = 3500;
end
if nargin < 5 || isempty(fmin)
    fmin = 0.05;
end
if nargin < 6 || isempty(fmax)
    fmax = 200.05;
end



if exist(modefile,'file')==2
    delete(modefile); % kill if it is there 
end

switch modetype
    case {'S','Spheroidal','spheroidal','Rayleigh','rayleigh'}
        jcom = 3;
        accstr = '1.d-12  1.d-12  1.d-12 .126';
    case {'T','Toroidal','toroidal','Love','love','L'}
        jcom = 2;
        accstr = '1.d-11  1.d-11  1.d-11 .126';
    case {'R','Radial','radial'}
        jcom = 1;
        accstr = '1.d-12  1.d-12  1.d-12 .126';
end
        

%% write modefile parameter file
fid = fopen(modefile,'w');
fprintf(fid,'%s\n',accstr);
fprintf(fid,'%u\n',jcom);
fprintf(fid,'%u %u %.3f %.3f 1\n',lmin,lmax,fmin,fmax);
fprintf(fid,'0\n');
fclose(fid);

end




