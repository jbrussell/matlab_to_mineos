function delete_mineos_files( ID,R_or_L )
%delete_mineos_files( ID )
%   Function to delete all files associted with mineos running

%% filenames
if ~ischar(ID), ID = num2str(ID);end
cardfile = [ID,'.model'];       %if exist(cardfile,'file')~=2, cardfile = ''; end
ID = [ID,R_or_L];
execfile = [ID,'.run_mineos'];  %if exist(execfile,'file')~=2, execfile = ''; end
eigfile = [ID,'*.eig'];          %if exist(eigfile,'file')~=2, eigfile = ''; end
eigfile_fix = [ID,'*.eig_fix'];          %if exist(eigfile,'file')~=2, eigfile = ''; end
qfile = [ID,'.q'];
logfile = [ID,'.log'];          %if exist(logfile,'file')~=2, logfile = ''; end
execfile_k = [ID,'.run_kernels'];%if exist(execfile_k,'file')~=2, execfile_k = ''; end
stripfile = [ID,'.strip'];      %if exist(stripfile,'file')~=2, stripfile = ''; end
tabfile = [ID,'.table'];        %if exist(tabfile,'file')~=2, tabfile = ''; end
tabfile_hdr = [tabfile,'_hdr'];
branchfile = [tabfile,'_hdr.branch'];
kernelfile = [ID,'.cvfrechet']; %if exist(kernelfile,'file')~=2, kernelfile = ''; end

% preamble
wd = pwd;
global MINEOSDIR
if isempty(MINEOSDIR)
    MINEOSDIR =  extractBefore(mfilename('fullpath'),mfilename);
end
% cd(MINEOSDIR);
%% do the deleting

delete([ID,'_*.asc'])
delete([ID,'_*.eig'])
delete([ID,'_*.eig_fix'])

if exist(execfile,'file')==2, delete(execfile); end
if exist(cardfile,'file')==2, delete(cardfile); end
if exist(eigfile,'file')==2, delete(eigfile); end
if exist(eigfile_fix,'file')==2, delete(eigfile); end
if exist(qfile,'file')==2, delete(qfile); end
if exist(stripfile,'file')==2, delete(stripfile); end
if exist(tabfile,'file')==2, delete(tabfile); end
if exist(kernelfile,'file')==2, delete(kernelfile); end
if exist(tabfile,'file')==2, delete(tabfile); end
if exist(tabfile_hdr,'file')==2, delete(tabfile_hdr); end
if exist(branchfile,'file')==2, delete(branchfile); end

if exist(execfile_k,'file')==2
%     try
% %     delete(execfile_k,stripfile,tabfile,kernelfile,[tabfile,'_hdr'],[tabfile,'_hdr.branch']);
%     catch
%         fprintf('Tried to delete MINEOS files but some error');
%     end
    for ip = 1:length(swperiods)
        delete(ikernelfiles{ip});
    end
end
if exist(execfile_k,'file')==2, delete(execfile_k); end
if exist(logfile,'file')==2, delete(logfile); end

% postamble
cd(wd);

end
