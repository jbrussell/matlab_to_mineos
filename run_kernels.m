function [SW_V_kernels] = run_kernels(swperiods,R_or_L,ph_or_gr,ID,eigfiles,ifdelete,ifplot,ifverbose,ifanis)
% [SWV_kernels] = run_kernels(swperiods,R_or_L,ph_or_gr,ID,eigfiles,ifdelete,ifplot,ifverbose,ifanis)
% 
% Function to calculate perturbational phase velocity kernels, having
% previously run MINEOS
tic1 = now;

if nargin < 2 || isempty(R_or_L)
    R_or_L = 'R';
end
if nargin < 3 || isempty(ph_or_gr)
    ph_or_gr = 'ph';
end
if nargin < 4 || isempty(ID)
    ID = 'eg';
end
if nargin < 5 || isempty(eigfiles)
    eigfiles = {[ID,'_0.eig']};
end
if nargin < 6 || isempty(ifdelete)
    ifdelete = true;
end
if nargin < 7 || isempty(ifplot)
    ifplot = false;
end
if nargin < 8 || isempty(ifverbose)
    ifverbose = true;
end
if nargin < 9 || isempty(ifanis)
    ifanis = false;
end

% phase or group or both ([1 0] or [0 1] or [1 1] respectively)
ph_gr = [0 0];
if ~isempty(regexp(ph_or_gr,'ph','once')) ||...
    ~isempty(regexp(ph_or_gr,'phase','once')) ||...
    ~isempty(regexp(ph_or_gr,'c','once'))
   ph_gr(1)= true; 
end
if ~isempty(regexp(ph_or_gr,'gr','once')) ||...
    ~isempty(regexp(ph_or_gr,'group','once')) ||...
    ~isempty(regexp(ph_or_gr,'U','once'))
   ph_gr(2)= true; 
end

%% filenames
if ~ischar(ID), ID = num2str(ID);end
ID = [ID,R_or_L(1)];
execfile = [ID,'.run_mineos'];
logfile = [ID,'.log'];
execfile_k = [ID,'.run_kernels'];
stripfile = [ID,'.strip'];
tabfile = [ID,'.table'];
qfile = [ID,'.q'];
kernelfile = [ID,'.frechet'];


% standard inputs, don't get re-written
qmod= '/Users/zeilon/Documents/MATLAB/matlab_to_mineos/safekeeping/qmod';

%% =======================================================================
wd = pwd;
% cd('/Users/zeilon/Documents/MATLAB/matlab_to_mineos');

%% CALCULATE AND READ IN PERTURBATION KERNELS 
%(frechet derivatves of parm perturbation)
    
%% write kernel calc executable
ikernelfiles = writeKERNELCALCexecfile(swperiods,R_or_L(1),ph_gr,execfile_k,stripfile,eigfiles,qmod,tabfile,qfile,kernelfile,ID,logfile);
system(['chmod u+x ' execfile_k]);

%% do the kernel calculating
if ifverbose
    fprintf('    > Calculting kernels from MINEOS output \n    > Will take some time...')
end
%tic
[status,cmdout] = system(['/opt/local/bin/gtimeout 100 ./',execfile_k]);
%fprintf('Kernel computation itself %s%s took %.5f s\n',ID,R_or_L(1),toc)
if ifverbose
    fprintf(' success!\n');
end
%% read 
vees = find(ph_gr);
phgropt = {'ph','gr'};
for iv = 1:length(vees)
for ip = 1:length(ikernelfiles)
    SW_V_kernels{ip,iv} = readMINEOS_kernelfile(ikernelfiles{ip,vees(iv)},R_or_L,phgropt(vees(iv)));
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
	delete([ID,'_*.model'])
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
	fprintf('Kernels %s%s took %.5f s\n',ID,R_or_L(1),(now-tic1)*86400)
end
 