clear all
%% Some ways this might go wrong for you:
% 1. Make sure all the paths are correct. The path to the Q model is
% hard-wired into the run_mineos and run_kernels code. I have provided this
% file on github, but unless your home directory is also "zeilon" then it
% certainly won't be in the folder these scripts expect it to be in. Go
% change its path in those two scripts. 
% 
% 2. You may not be able to plot the kernels without my plot_KERNELS
% function. That is also available from my github (repository:
% "eilonzach/seis_tools"). Or just plot them yourself and comment this line
% out...
% 
% 3. You don't have clone_figure - this is available through Mathworks
% fora, so google it. Again, you can just comment this line out and save
% the figures to retain them after others plot, if you want. 
% 
% 4. Probably others I've not thought of - if/when this fails, please let
% me know why (even if it's easy for you to fix). 

addpath('../functions/')
set_binpath

%% Define the periods to compute, log-spaced between 8s and 140s
swperiods = round(logspace(log10(8),log10(140),10));


%% first run a simple model that we know will work
model = 'model1_simple'; % this is a card file sitting in this directory
ifverbose = true; % verbose output so we see what's going on
ifplot = true;    % make some helpful plots
ifdelete = false; % don't delete the files at the end - you may want to see what they are!
% need some ID for this run (useful if you intend to run in parallel - each
% run gets a unique ID so that it can be computed simultaneously
ID = 'example1';

% First do Rayleigh waves, and get phase velocity kernels
par_mineos = struct('R_or_L','R','phV_or_grV','ph','ID',ID);

[phV_R1,grV_R1,eigfiles] = run_mineos(model,swperiods,par_mineos,0,ifplot,ifverbose);
[K_R1] = run_kernels(swperiods,par_mineos,eigfiles,ifdelete,ifplot,ifverbose);
clone_figure(88,1)

% now run the same model but for Love waves, again phase velocity kernels
par_mineos.R_or_L = 'L';

[phV_L1,grV_L1,eigfiles] = run_mineos(model,swperiods,par_mineos,0,ifplot,ifverbose);
[K_L1] = run_kernels(swperiods,par_mineos,eigfiles,ifdelete,ifplot,ifverbose);
clone_figure(88,2)

%% now run a more complex model that requires re-starting mineos and stitching
model = 'model2_recovery'; % this is a card file sitting in this directory
ifverbose = true; % verbose output so we see what's going on
ifplot = true;    % make some helpful plots
ifdelete = false; % don't delete the files at the end - you may want to see what they are!
% need some ID for this run (useful if you intend to run in parallel - each
% run gets a unique ID so that it can be computed simultaneously
ID = 'example2';

% First do Rayleigh waves, and get phase velocity kernels
par_mineos = struct('R_or_L','R','phV_or_grV','ph','ID',ID);

[phV_R2,grV_R2,eigfiles] = run_mineos(model,swperiods,par_mineos,0,ifplot,ifverbose);
[K_R2] = run_kernels(swperiods,par_mineos,eigfiles,ifdelete,ifplot,ifverbose);
clone_figure(88,3)

% now run the same model but for Love waves, again phase velocity kernels
par_mineos.R_or_L = 'L';

[phV_L2,grV_L2,eigfiles] = run_mineos(model,swperiods,par_mineos,0,ifplot,ifverbose);
[K_L2] = run_kernels(swperiods,par_mineos,eigfiles,ifdelete,ifplot,ifverbose);
clone_figure(88,4)
