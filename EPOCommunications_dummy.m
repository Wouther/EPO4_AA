%Dummy EPOCommunications function to test code without KITT.
function varargout = EPOCommunications_dummy(varargin)

    %Input validation
    if length(varargin) == 0
        disp(['Error: no arguments passed to function ' ...
            'EPOCommunications_dummy. Ignoring function call.']);
        varargout{1} = 0;
        return;
    end
    
    switch varargin{1}
        case 'open'
            varargout{1} = 1;
        case 'close'
            varargout{1} = 1;
        case 'transmit'
            %TODO: check whether vargargin{2} = S, A or D (or empty) and
            % return correct status. Write other status function (local).
            varargout{1} = dummystatus();
        otherwise
            disp(['Error: invalid command ''' varargin{1} ...
                ''' passed to function EPOCommunications_dummy.']);
            varargout{1} = 0;
    end
    
    %Generate dummy status (with random values) to test without KITT
    function statustext = dummystatus()
        dir   = num2str(randi([100 200]), '%03u');
        speed = num2str(randi([135 165]), '%03u');
        dist  = num2str(randi([0 999], 2, 1), '%03u');
        batt  = num2str(randi([0 99999]), '%05u');
        audio = num2str(randi([0 1]));
        statustext = ['D' dir ' ' speed '\n' ...
            'U' dist(1) ' ' dist(2) '\n' ...
            'A' batt '\n' ...
            'Audio ' audio '\n'];
    end    
    
end