function kernel = readMINEOS_kernelfile(kernelfile,RorL,phgr)
% kernel = readMINEOS_kernelfile(kernelfile,RorL,phgr)
%  
%  Function to read MINEOS kernel file to get the perturbational
%  sensitivity kernels for dc/c as a function of dvpv/vpv, dvsv/vsv etc
% 
%  If spheroidal modes (Rayleigh), reads columns Vsv,Vpv,Vsh,Vph,eta, rho
%  If only toroidal modes (Love), reads columns  Vsv,Vsh,rho
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
                'Vsv',flipud(C{2})*fac,'Vsh',flipud(C{4})*fac,...
                'Vpv',flipud(C{3})*fac,'Vph',flipud(C{5})*fac,...
                'eta',flipud(C{6})*fac,'rho',flipud(C{7})*fac);

elseif strcmp(RorL,'L') ||  strcmp(RorL,'Lov') 

    kernel = struct('Z',6371e3-flipud(C{1}),... % flipuds so Z=0 at the top
                'Vsv',flipud(C{2})*fac,'Vsh',flipud(C{3})*fac,...
                'Vpv',oo,'Vph',oo,...
                'eta',oo,'rho',flipud(C{4})*fac);

end

end

