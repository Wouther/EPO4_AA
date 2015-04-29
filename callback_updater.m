%Executes every period of the updater.
%Requests current status from KITT, processes it, and sends new commands.
%To do this, it uses the kitt object. Should not (or minimally) use gui or
% com objects.
function callback_updater(~, event, ~)
    global gui com kitt updater;

    event_type = event.Type;
    event_time = datestr(event.Data.time);

    %Check if called correctly
    if ~strcmp(event_type, 'TimerFcn')
        disp(['Warning: unexpected call to function callback_updater ' ...
            'by event of type ' event_type '. Call ignored.']);
        return;
    end

    disp('...');

    %Get KITT's status
    kitt.get_status()
    gui.setrawtext(com.status_kitt_raw);
    
    
    %TODO: call/execute controller
    
    %TODO: send commands to KITT
    
end
