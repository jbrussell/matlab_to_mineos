function [SW_V_kernels] = run_kernels(swperiods,par_mineos,eigfiles,ifdelete,ifplot,ifverbose,ifanis)
% [SWV_kernels] = run_kernels(swperiods,par_mineos,eigfiles,ifdelete,ifplot,ifverbose,ifanis)
%
% Function to calculate perturbational phase velocity kernels, having
% previously run MINEOS
tic1 = now;

if nargin < 2 || isempty(par_mineos)
    par_mineos = [];
end
if nargin < 3 || isempty(eigfiles)
    eigfiles = {[ID,'_0.eig']};
end
if nargin < 4 || isempty(ifdelete)
    ifdelete = true;
end
if nargin < 5 || isempty(ifplot)
    ifplot = false;
end
if nargin < 6 || isempty(ifverbose)
    ifverbose = true;
end
if nargin < 7 || isempty(ifanis)
    ifanis = false;
end

%% parameters
% default parameters
parm = struct('R_or_L','R',...
              'phV_or_grV','ph',...
              'ID','example',...
              'lmin',0,...            % minimum angular order
              'lmax',3500,...         % expected max angular order
              'fmin',0.05,...         % min frequency (mHz)
              'fmax',200.05,...       % max frequency (mHz) - gets reset by min period
              'l_increment_standard',2,... %
              'l_increment_failed',5,...
              'qmodpath','../safekeeping/qmod');
% replace default values with user values, where appropriate.
fns = fieldnames(par_mineos);
for ii = 1:length(fns)
    parm.(fns{ii}) = par_mineos.(fns{ii});
end


% phase or group or both ([1 0] or [0 1] or [1 1] respectively)
ph_gr = [0 0];
if ~isempty(regexp(parm.phV_or_grV,'ph','once')) ||...
    ~isempty(regexp(parm.phV_or_grV,'phase','once')) ||...
    ~isempty(regexp(parm.phV_or_grV,'c','once'))
   ph_gr(1)= true;
end
if ~isempty(regexp(parm.phV_or_grV,'gr','once')) ||...
    ~isempty(regexp(parm.phV_or_grV,'group','once')) ||...
    ~isempty(regexp(parm.phV_or_grV,'U','once'))
   ph_gr(2)= true;
end

%% filenames
if ~ischar(parm.ID), parm.ID = num2str(parm.ID);end
ID = [parm.ID,parm.R_or_L(1)];
logfile = [ID,'.log'];
execfile_k = [ID,'.run_kernels'];
stripfile = [ID,'.strip'];
tabfile = [ID,'.table'];
qfile = [ID,'.q'];
kernelfile = [ID,'.frechet'];

% standard inputs, don't get re-written
% qmod= '/Users/zeilon/Documents/MATLAB/matlab_to_mineos/safekeeping/qmod';
qmod= parm.qmodpath;

%% =======================================================================
wd = pwd;
% cd('/Users/zeilon/Documents/MATLAB/matlab_to_mineos');

%% CALCULATE AND READ IN PERTURBATION KERNELS
%(frechet derivatves of parm perturbation)

%% write kernel calc executable
ikernelfiles = writeKERNELCALCexecfile(swperiods,parm.R_or_L(1),ph_gr,execfile_k,stripfile,eigfiles,qmod,tabfile,qfile,kernelfile,ID,logfile);
system(['chmod u+x ' execfile_k]);

%% do the kernel calculating
if ifverbose
    fprintf('    > Calculting kernels from MINEOS output \n    > Will take some time...')
end
%tic
% [status,cmdout] = system(['/opt/local/bin/gtimeout 100 ./',execfile_k]);
[status,cmdout] = system(['gtimeout 100 ./',execfile_k]);
%fprintf('Kernel computation itself %s%s took %.5f s\n',ID,parm.R_or_L(1),toc)
if ifverbose
    fprintf(' success!\n');
end
%% read
vees = find(ph_gr);
phgropt = {'ph','gr'};
for iv = 1:length(vees)
for ip = 1:length(ikernelfiles)
    SW_V_kernels{ip,iv} = readMINEOS_kernelfile(ikernelfiles{ip,vees(iv)},parm.R_or_L,phgropt(vees(iv)));
    SW_V_kernels{ip,iv}.period = swperiods(ip);
end
end

%% plot
if ifplot
    %% read modes output
    [phV,grV] = readMINEOS_qfile(qfile,swperiods);
    phV = phV(:);
    grV = grV(:);

    figure(88), clf; set(gcf,'pos',[331 385 1348 713]);
    ax1 = subplot(3,3,[1,4]); cla, hold on;
    ax2 = subplot(3,3,[2,5,8]); cla, hold on;
    ax3 = subplot(3,3,[3,6,9]); cla, hold on;
    % kernels
    plot_KERNELS( SW_V_kernels,ifanis,ax2,ax3 )

    % dispersion curves
    hd(1)=plot(ax1,swperiods,phV,'o-','linewidth',2);
    hd(2)=plot(ax1,swperiods,grV,'o-','linewidth',2);
    hl = legend(ax1,hd,{'Phase (c)','Group (U)'},'location','southeast');
    set(hl,'fontsize',16,'fontweight','bold')
    set(ax1,'fontsize',16)
    xlabel(ax1,'Period (s)','interpreter','latex','fontsize',22)
    ylabel(ax1,'Velocity (km/s)','interpreter','latex','fontsize',22)
end

%% delete files
if ifdelete
	delete([parm.ID,'*.model'])
	delete([ID,'_*.asc'])
    delete([ID,'.q'])
    delete([ID,'_*.eig'])
    delete([ID,'_*.eig_fix'])
    if exist([ID,'.log'],'file')==2, delete([ID,'.log']); end
	delete(execfile_k,stripfile,tabfile,[tabfile,'_hdr'],[tabfile,'_hdr.branch']);
    if exist(kernelfile,'file')==2,delete(regexprep(kernelfile,'cv','gv'));end
    if exist(regexprep(kernelfile,'.fre','.cvfre'),'file')==2,delete(regexprep(kernelfile,'.fre','.cvfre'));end
    if exist(regexprep(kernelfile,'.fre','.gvfre'),'file')==2,delete(regexprep(kernelfile,'.fre','.gvfre'));end
	for ip = 1:size(ikernelfiles,2)*size(ikernelfiles,1), delete(ikernelfiles{ip}); end
    if exist(logfile,'file')==2, delete(logfile); end
end
cd(wd);



if ifverbose
	fprintf('Kernels %s took %.5f s\n',ID,(now-tic1)*86400)
end
