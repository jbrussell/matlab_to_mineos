function kernel = readMINEOS_kernelfile_ACLNF(kernelfile,RorL,phgr)
% kernel = readMINEOS_kernelfile_ACLNF(kernelfile,RorL,phgr)
%  
%  Function to read MINEOS kernel file to get the perturbational
%  sensitivity kernels for dc/c as a function of dvpv/vpv, dvsv/vsv etc
% 
%  Reads columns of kernels for Love parameters: A,C,L,N,F,rho
% 
%  If phase velocity, kernels are good as is. If group velocity, need to
%  multiply by a factor of 1e3. 

if nargin < 2 || isempty(RorL)
    RorL = 'R';
end

if nargin < 3 || isempty(phgr)
    phgr = 'ph';
end

if strcmp(phgr,'ph') || strcmp(phgr,'phase') || strcmp(phgr,'c')
    fac=1;
end
if strcmp(phgr,'gr') || strcmp(phgr,'group') || strcmp(phgr,'U')
    fac=1e3;
end

fid = fopen(kernelfile,'r');
C = textscan(fid,'%f %f %f %f %f %f %f'); % Z,Vsv, Vpv, Vsh, Vph, eta, rho
fclose(fid);

oo = zeros(size(C{1}));


if strcmp(RorL,'R') ||  strcmp(RorL,'Ray') 

    kernel = struct('Z',6371e3-flipud(C{1}),... % flipuds so Z=0 at the top
                'A',flipud(C{2})*fac,'C',flipud(C{3})*fac,...
                'L',flipud(C{4})*fac,'N',flipud(C{5})*fac,...
                'F',flipud(C{6})*fac,'rho',flipud(C{7})*fac);

elseif strcmp(RorL,'L') ||  strcmp(RorL,'Lov') 

    error('This only works for Rayleigh wave input');

end

end

