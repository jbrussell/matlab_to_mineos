function ikernelfiles = writeKERNELCALCexecfile(swperiods,R_or_L,ph_gr,execfile,stripfile,eigfile,qmod,tabfile,qfile,kernelfile,ikprefix,logfile)
% ikernelfiles = writeKERNELCALCexecfile(swperiods,R_o_rL,ph_or_gr,execfile,stripfile,eigfile,tabfile,qfile,kernelfile,ikprefix,logfile)
%   
% Function to write execution file for kernel calculator having run MINEOS code
% 
% INPUTS:
%  swperiods - vector of surface wave periods (will be rounded to integers)
%  R_or_L    - string of Rayleygh ('Ray'|'R') or Love ('Lov'|'R')
%  ph_gr     - (1x2) vector to do phase [1 0] or group [0 1] or both [1 1]
%  swperiods - vector of surface wave periods (will be rounded to integers)
%  execfile  - name of executable file 
%  modefile  - name of strip file
%  eigfile   - name of eigenfunctions output binary file
%  qmod      - name of qmod file with details about (unused) Q model
%  tabfile   - name of output table file
%  qfile     - name of output q file (= output from mineos_q; not the same as the Q model)
%  kernelfile- name of output frechet kernel file -- this is a key file
%  ikprefix  - prefix for output individual kernel files at each freq.
%  logfile   - name of file to print screen output to

ikernelfiles = cell({});

if exist(execfile,'file')==2
    delete(execfile); % kill if it is there 
end

switch R_or_L
    case {'R','Ray','Rayleigh'}
        maxangl = 3000;
    case {'L','Lov','Love'}
        maxangl = 3500;
end




%% write synth.in parameter file
fid = fopen(execfile,'w');
fprintf(fid,'#!/bin/csh\n');
%
fprintf(fid,'#\n');
fprintf(fid,'set xdir=/Users/zeilon/Work/codes/CADMINEOS/bin\n');
fprintf(fid,'#\n');
%% =======================================================================
fprintf(fid,'echo "=================================================" > %s\n',logfile);
fprintf(fid,'echo "Stripping mineos" >> %s\n',logfile);
%
fprintf(fid,'#\n');
%
fprintf(fid,'$xdir/mineos_strip <<! >> %s\n',logfile);
fprintf(fid,'%s\n',stripfile);
fprintf(fid,'%s\n',eigfile);
fprintf(fid,'\n');
fprintf(fid,'!\n');
%
fprintf(fid,'#\n');
%% =======================================================================
fprintf(fid,'echo "=================================================" >> %s\n',logfile);
fprintf(fid,'echo "Done stripping, now calculating tables" >> %s\n',logfile);
%
fprintf(fid,'#\n');
%
fprintf(fid,'$xdir/mineos_table <<! >> %s\n',logfile);
fprintf(fid,'%s\n',tabfile);
fprintf(fid,'40000\n');
fprintf(fid,'0 200.1\n');
fprintf(fid,'0 %.0f\n',maxangl);
fprintf(fid,'%s\n',qfile);
fprintf(fid,'%s\n',stripfile);
fprintf(fid,'\n');
fprintf(fid,'!\n');
%
fprintf(fid,'#\n');
%% =======================================================================
fprintf(fid,'echo "=================================================" >> %s\n',logfile);
fprintf(fid,'echo "Creating branch file" >> %s\n',logfile);
%
fprintf(fid,'#\n');
fprintf(fid,'# to create branch file needed for frechet derivatives:\n');
fprintf(fid,'# second line says stop searching (or could add more parameters to search)\n');
fprintf(fid,'# 3rd line gives frequency range to search in (mHz)\n');
fprintf(fid,'#\n');
%
fprintf(fid,'$xdir/plot_wk <<! >> %s\n',logfile);
fprintf(fid,'table %s_hdr\n',tabfile);
fprintf(fid,'search\n');
fprintf(fid,'1 0.0 200.05\n');
fprintf(fid,'99 0 0\n');
fprintf(fid,'branch\n');
fprintf(fid,'\n');
fprintf(fid,'quit\n');
fprintf(fid,'!\n');
%
fprintf(fid,'#\n');
%% =======================================================================
fprintf(fid,'echo "=================================================" >> %s\n',logfile);
ckernelfile = regexprep(kernelfile,'.frech','.cvfrech');
fprintf(fid,'echo "Making frechet phV kernels binary" >> %s\n',logfile);
%
fprintf(fid,'#\n');
%
fprintf(fid,'rm %s\n',ckernelfile);
fprintf(fid,'$xdir/frechet_cv_G <<! >> %s\n',logfile);
fprintf(fid,'%s\n',qmod);
fprintf(fid,'%s_hdr.branch\n',tabfile);
fprintf(fid,'%s\n',ckernelfile);
fprintf(fid,'%s\n',eigfile);
fprintf(fid,'0\n');
fprintf(fid,'\n');
fprintf(fid,'!\n');
%
fprintf(fid,'#\n');

%% =======================================================================
if ph_gr(2)
gkernelfile = regexprep(kernelfile,'.frech','.gvfrech');
% frechet file
fprintf(fid,'echo "=================================================" >> %s\n',logfile);
fprintf(fid,'echo "Making frechet file in prep for grV kernels" >> %s\n',logfile);
%
fprintf(fid,'#\n');
%
fprintf(fid,'rm %s\n',kernelfile);
fprintf(fid,'$xdir/frechet <<! >> %s\n',logfile);
fprintf(fid,'%s\n',qmod);
fprintf(fid,'%s_hdr.branch\n',tabfile);
fprintf(fid,'%s\n',kernelfile);
fprintf(fid,'%s\n',eigfile);
fprintf(fid,'0\n');
fprintf(fid,'\n');
fprintf(fid,'!\n');
%
fprintf(fid,'#\n');
% gvfrechet file
fprintf(fid,'echo "=================================================" >> %s\n',logfile);
fprintf(fid,'echo "Making frechet grV kernels binary" >> %s\n',logfile);
%
fprintf(fid,'#\n');
%
fprintf(fid,'rm %s\n',gkernelfile);
fprintf(fid,'$xdir/frechet_gv <<! >> %s\n',logfile);
fprintf(fid,'%s\n',kernelfile);
fprintf(fid,'0\n');
fprintf(fid,'%s\n',gkernelfile);
fprintf(fid,'!\n');
%
fprintf(fid,'#\n');
end
    

%% CV kernels =======================================================================
if ph_gr(1) % only if ph_gr instructs
    fprintf(fid,'echo "=================================================" >> %s\n',logfile);
    fprintf(fid,'echo "Writing phV kernel files for each period">> %s\n',logfile);
    for ip = 1:length(swperiods)
    ickernelfile = sprintf('%s_cvfrechet_%.0fs',ikprefix,round(swperiods(ip)));
    %
    fprintf(fid,'#\n');
    %
    fprintf(fid,'$xdir/draw_frechet_gv <<!\n');
    fprintf(fid,'%s\n',ckernelfile);
    fprintf(fid,'%s\n',ickernelfile);
    fprintf(fid,'%.0f\n',round(swperiods(ip)));
    fprintf(fid,'!\n');
    %
    ikernelfiles{ip,1} = ickernelfile;
    end % loop on periods
    fprintf(fid,'#\n');
end % only if ph_gr instructs

%% GV kernels =======================================================================
if ph_gr(2) % only if ph_gr instructs
    fprintf(fid,'echo "=================================================" >> %s\n',logfile);
    fprintf(fid,'echo "Writing grV kernel files for each period">> %s\n',logfile);
    for ip = 1:length(swperiods)
    igkernelfile = sprintf('%s_gvfrechet_%.0fs',ikprefix,round(swperiods(ip)));
    %
    fprintf(fid,'#\n');
    %
    fprintf(fid,'$xdir/draw_frechet_gv <<!\n');
    fprintf(fid,'%s\n',gkernelfile);
    fprintf(fid,'%s\n',igkernelfile);
    fprintf(fid,'%.0f\n',round(swperiods(ip)));
    fprintf(fid,'!\n');
    %
    ikernelfiles{ip,2} = igkernelfile;
    end % loop on periods
    fprintf(fid,'#\n');
end % only if ph_gr instructs
%% =======================================================================
fprintf(fid,'echo "Done velocity calculation, cleaning up..." >> %s\n',logfile);
%
% fprintf(fid,'rm synth.out3*\n');
% fprintf(fid,'rm %s\n',logfile);

fclose(fid);

end




