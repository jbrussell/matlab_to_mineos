function [modes_done,last_fundamental_l,first_fundamental_l,lowest_fundamental_period] = readMINEOS_ascfile(ascfile,ifplot,skiplines)
% [modes_done,last_fundamental_l,first_fundamental_l,lowest_fundamental_period] = readMINEOS_ascfile(ascfile,ifplot,skiplines)
%  
%  Function to read MINEOS ascii output file (ascfile) for the details of
%  the mode integration, specifically the first and last mode numbers
%  successfully computed by this calculation

if nargin<2
    ifplot = false;
end
if nargin<3
    skiplines = 0;
end

% structure to house information about completed modes
modes_done = struct('type',[],'n',[],'l',[],... 
                    'w_rad_per_s',[],'w_mHz',[],'T_sec',[],...
                    'grV_km_per_s',[],'Q',[],'raylquo',[]);

if ~iscell(ascfile) % cell array of ascfiles to read in sequentially
    ascfile = {ascfile};
end

imode = 0;

for iaf = 1:length(ascfile)
    ascf = ascfile{iaf};

    fid = fopen(ascf,'r');
%     for i = 1:skiplines
%         fgetl(fid);
%     end
    textscan(fid,'%s',0,'headerlines',skiplines);
    while 1
        line=fgetl(fid); % read line of preamble
        if isempty(line), continue; end
        A = textscan(line,'%s');
        if strcmp(A{1}{1},'MODE') % stop once we get to the mode description
            line=fgetl(fid); %#ok<NASGU> % read blank line and stop
            break
        end
    end
    while ~feof(fid)
        line=fgetl(fid); 
        B = textscan(line,'%u %s %u %f %f %f %f %f %f',1); % n,type,l,w(rad/s),w(mHz),T(s),grV,Q,raylquo
        imode = imode+1;
        modes_done.n(imode) = B{1};
        modes_done.l(imode) = B{3};
        modes_done.w_rad_per_s(imode) = B{4};
        modes_done.w_mHz(imode) = B{5};
        modes_done.T_sec(imode) = B{6};
        modes_done.grV_km_per_s(imode) = B{7};    
        modes_done.Q(imode) = B{8};    
    %     modes_done.raylquo(imode) = B{9};        
    end
    fclose(fid);

end

% if plotting branches
if ifplot
    figure(44),clf, 
    ax1 = subplot(121);hold on
    ax2 = subplot(122);hold on
    ns = unique(modes_done.n);
    for inn = 1:length(ns)
        isn = modes_done.n == ns(inn);
        hl(inn) = plot(ax1,modes_done.l(isn),modes_done.grV_km_per_s(isn),'-o','DisplayName',['Branch ',num2str(ns(inn))]);
        hl(inn) = plot(ax2,modes_done.l(isn),modes_done.w_mHz(isn),'-o','DisplayName',['Branch ',num2str(ns(inn))]);
    end     
    set(ax1,'fontsize',15); xlabel(ax1,'mode number'),ylabel(ax1,'Group velocity (km/s)');
    set(ax2,'fontsize',15); xlabel(ax2,'mode number'),ylabel(ax2,'Frequency (mHz)');
    legend(ax1);legend(ax2,'location','southeast');
end

last_fundamental_l = max(modes_done.l(modes_done.n==0));
first_fundamental_l = min(modes_done.l(modes_done.n==0));
lowest_fundamental_period = min(modes_done.T_sec(modes_done.n==0));
end

