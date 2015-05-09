%Launch GUI and set up communications, etc.

clc;

%Settings
workoffline    = false; %use dummy communications instead of bluetooth
suppresscomout = true; %suppress output of 'EPOCommunications' mex-function
comport        = 7;
updateperiod   = 250; %milliseconds > 1

%Handle unclean exit from last run or when gui still open
if exist('gui', 'var') && ~isempty(gui.fig)
    delete(gui.fig);
end

clearvars gui com kitt updater;

%Set global variables
global gui com kitt updater;

%Initialise
gui  = gui_class();
com  = com_class((~workoffline)*comport - (workoffline), suppresscomout);
kitt = kitt_class();

%Create timer
updater = timer(...
    'ExecutionMode', 'fixedRate', ...     %Run repeatedly
    'Period', ceil(updateperiod)/1e3, ... %Period in seconds > 1ms
    'TimerFcn', @callback_updater);       %Specify callback
