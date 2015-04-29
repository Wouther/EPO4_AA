%Launch GUI and set up communications, etc.

clc;

%Settings
comport = 9;
updateperiod = 1000; %milliseconds > 1

%Set global variables
global gui com kitt updater;

%Initialise
gui  = gui_class();
com  = com_class(comport);
kitt = kitt_class();

%Create timer
updater = timer(...
    'ExecutionMode', 'fixedRate', ...     %Run repeatedly
    'Period', ceil(updateperiod)/1e3, ... %Period in seconds > 1ms
    'TimerFcn', @callback_updater);       %Specify callback
