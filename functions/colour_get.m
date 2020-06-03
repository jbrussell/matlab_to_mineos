function [rgbs] = colour_get(v,vmax,vmin,colourmap)
%  [rgbs] = colour_get(v,vmax,vmin,colourscheme)
% 
% This function takes a vector of numerical values and returns the
% corresponding [r g b] values so they can be plotted by colour
%
% INPUT	  v 	Nx1 vector of numerical values
% 		  vmax	maximum on scale (optional, will use 1 as default)
% 		  vmin	minimum on scale (optional, will use 0 as default)
%		  colourscheme 	defines name of colormap from built-in options (optional) 
% 
% If vmax < vmin, will swap the order of the colours
% 
% N.B. values of v outside the defined scale will be returned as the colours of the extremes
%
% OUTPUT  rgbs	Nx3 matrix specifying colours corresponding to numerical values in v
% N.B. uses colormap to get vectors and then linear interpolates to values
% 
% Written by Zach Eilon, 2014
if vmax == vmin
    rgbs = ones(length(v),1)*[0 0 0];
    return
end

if nargin < 2
vmax = max(v);
vmin = min(v);
end

if nargin < 4
cmap = colormap;
else
cmap = colourmap;
end

if vmax < vmin
    disp('vmax smaller - flipping cmap')
    junk = vmin; vmin = vmax; vmax = junk;
    cmap = flipud(cmap);
end

v(v>vmax) = vmax;
v(v<vmin) = vmin;

L = length(cmap);
[M,N] = size(v);
Dv = vmax-vmin; 
% if Dv <= 0, error('vmax must be larger than vmin'); end

rgbs = zeros(M,N,3);
cvalues = vmin:Dv/(L-1):vmax;
for ic = 1:3 % loop over RGB
rgb = interp1(cvalues,cmap(:,ic),v(:));
rgbs(:,:,ic) = reshape(rgb,M,N);
end 

rgbs = squeeze(rgbs);

end

