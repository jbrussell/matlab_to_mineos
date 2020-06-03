function writeMINEOSexecfile( execfile,cardfile,modefile,eigfile,ascfile,logfile)
% writeMINEOSexecfile( execfile,cardfile,modefile,eigfile,ascfile,logfile)
%
% Function to write execution file for MINEOS code
%
% INPUTS:
%  execfile  - name of execution file to write
%  cardfile  - name of card file with model description
%  modefile  - name of mode file (standard input)
%  eigfile   - name of eigenfunctions output binary file
%  ascfile    - name of output ascii file
%  logfile   - name of file to print screen output to



if exist(execfile,'file')==2
    delete(execfile); % kill if it is there
end

%% write synth.in parameter file
fid = fopen(execfile,'w');
fprintf(fid,'#!/bin/csh\n');
%
fprintf(fid,'#\n');
%
fprintf(fid,'echo "Calculating eigenfunctions with MINEOS"\n');
%
fprintf(fid,'#\n');
%
% fprintf(fid,'set xdir=/Users/zeilon/Work/codes/CADMINEOS/bin\n');
% fprintf(fid,'$xdir/mineos_nohang << ! > %s\n',logfile);
fprintf(fid,'mineos_nohang << ! > %s\n',logfile);
fprintf(fid,'%s\n',cardfile);
fprintf(fid,'%s\n',ascfile);
fprintf(fid,'%s\n',eigfile);
fprintf(fid,'%s\n',modefile);
fprintf(fid,'!\n');
%
fprintf(fid,'#\n');
%
fprintf(fid,'rm %s\n',logfile);

fclose(fid);

end
