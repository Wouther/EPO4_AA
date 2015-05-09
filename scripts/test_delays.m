%Determine required delays
function [] = test_delays()
    global kitt;

    clc;
    close all;

    disp('Testing dummy...');
    data = test_delays_by_handle(@test_dummy_delay)
    h = graph_data(data);
    h.CurrentAxes.Title.String = 'Average succes rate for dummy';
    disp(['Done.' char(10)]);

    disp('Testing drive-to-status delay...');
    data = test_delays_by_handle(@test_drive_to_status_delay)
    h = graph_data(data);
    h.CurrentAxes.Title.String = 'Average succes rate for drive-status sequence';
    disp(['Done.' char(10)]);
    
    disp('Testing multiple status requests...');
    data = test_delays_by_handle(@test_status_delay)
    h = graph_data(data);
    h.CurrentAxes.Title.String = 'Average succes rate for multiple status requests';
    disp(['Done.' char(10)]);
    
    %Between multiple status requests
    function succes = test_status_delay(delay)
        kitt.get_status();
        pause(delay/1e3);
        status = kitt.get_status();
        if isstruct(status)
            succes = 1;
        else
            succes = 0;
        end
    end

    %Between drive command and status request
    function succes = test_drive_to_status_delay(delay)
        kitt.drive(150, 150);
        pause(delay/1e3);
        status = kitt.get_status();
        if isstruct(status)
            succes = 1;
        else
            succes = 0;
        end
    end

    %Dummy for testing
    function succes = test_dummy_delay(delay)
        succes = round(rand()*delay/500);
    end

end

function handle = graph_data(data)
    data_delay = data(:,1);
    data_avg   = data(:,4);

    handle = figure();
    scatter(data_delay, 100*data_avg);
    ax = handle.CurrentAxes;

    ax.Title.String = 'Average succes rate per delay';
    
    xlim = [0 max(data_delay)+1];
    ax.XLim = xlim;
    ax.XTick = xlim(1):50:xlim(2);
    ax.XTickLabel = ax.XTick;
    ax.XLabel.String = 'Delay [ms]';
    
    ax.YLim = [0 100];
    ax.YTick = 0:10:100;
    ax.YTickLabel = ax.YTick;
    ax.YLabel.String = 'Succes rate [%]';
end

%Make delay measurements for a specific function.
%Expects a function handle as it's parameter. Function should be of form
% succes = func(delay)
function [data] = test_delays_by_handle(tryonce)
    %Settings (delay values in milliseconds)
    bin.delay_min   = 100;
    bin.delay_max   = 500;
    bin.nmeas       = 3; %n/o measurements per step
    lin.startrange  = 130; %switch from binary to linear search when range this small
    lin.stepsize    = 10; %step size for linear search
    lin.nmeas       = 5; %n/o measurements per step
    pause_between   = 500; %pause between measurements
    
    %Init
    data = []; %nx3 matrix, one row per delay. columns: delay, succes, failure.

    %Binary search
    disp('Starting binary search.');
    
    range_min = 0;
    range_max = inf;
    d = bin.delay_max;
    while range_max-range_min > lin.startrange
        disp(['Trying delay = ' int2str(d) 'ms, ' int2str(range_min) ...
            ' < range < ' int2str(range_max) '...']);
        
        fails = 0;
        for i = 1:bin.nmeas
            result = tryonce(d);
            store_data(d, result);
            fails = fails + (~result);
            pause(pause_between/1e3);
        end
        
        %Set next delay to try
        lev = 1.5; %leverage factor > 1
        if fails ~= 0
            range_max = d;
            d = 0.9*d - floor(lev*(d-bin.delay_min)/2);
        else
            range_min = d;
            d = 1.1*d + ceil(lev*(bin.delay_max-d)/2);
        end
        
        %End binary search if delay out of set bounds
        if d < bin.delay_min || d > bin.delay_max
            disp(['Warning: binary search reached a bound at delay = ' ...
                int2str(d) 'ms. Perhaps change delay_min or delay_max?']);
            if d < bin.delay_min
                range_min = bin.delay_min;
            else
                range_max = bin.delay_max;
            end
            break;
        end
    end
    
    %Linear search
    dur = lin.nmeas*(pause_between*((range_max-range_min)/lin.stepsize+1) ...
        + (range_min+range_max)/2);
    disp(['Starting linear search with ' int2str(range_min) ' < range < ' ...
        int2str(range_max) ' and step size ' int2str(lin.stepsize) 'ms. ' ...
        char(10) 'Expected duration roughly ' int2str(dur/1e3) 's.']);
    
    for d = range_min:lin.stepsize:range_max
        for i = 1:lin.nmeas
            result = tryonce(d);
            store_data(d, result);
            pause(pause_between/1e3);
        end
    end
    
    %Process data
    data = sortrows(data); %sort for ascending delays
    data(:,4) = data(:,2) ./ (data(:,2)+data(:,3)); %calculate averages
    
    %Check assumption
    disp(['Pause between measurements was set to ' int2str(pause_between) ...
        'ms. Please check if acceptable and if not, run again with higher value.']);
    
    
    %Store single measurement
    function store_data(argd, argsuc)
        %find existing row with delay or create new
        if isempty(data)
            row = 1;
            data(row,:) = [argd 0 0];
        else
            row = find(data(:,1) == argd, 1);
            if isempty(row) %new row
                row = size(data, 1)+1;
                data(row,:) = [argd 0 0];
            end
        end
        
        %add measurement to correct column
        if argsuc
            data(row,2) = data(row,2) + 1;
        else
            data(row,3) = data(row,3) + 1;
        end
    end
    
end
