%Holds data concerning KITT and interacts with it.
%Uses com and gui objects.
classdef kitt_class < handle

    properties
        status;
    end
    
    methods
       
        %Get KITT's status.
        %Returns false when failed. Also returns number of tries needed.
        %Can optionally retry when failed. Pass time (in milliseconds) to 
        % wait between tries as first argument. Optional: maximum number of
        % tries as second argument.
        function [status, ntries] = get_status(self, varargin)
            global com;
            
            ntries = 0;
            while true
                status_original = false; %com.get_status();
                if isstruct(status_original) %succeeded to get status
                    break
                end
                ntries = ntries + 1;
                
                if nargin == 1 || ... %no retry
                    (nargin == 3 && ntries == varargin{2}) %maximum n/o tries reached
                    disp(['Error: getting status failed. Tried ' int2str(ntries) ...
                        ' time(s). ''status''-field unchanged.']);
                    status = false;
                    return;
                end
                
                pause(varargin{1}/1e3);
            end
            
            status = self.normalize_status(status_original);
            self.status = status;
        end
        
        %TODO: use normalized stuff
        function drive(self, direction, speed)
            global com;
            
            %TODO
            com.send_drive_command(direction, speed);
        end
        
    end
    
    methods (Static)
        
        function normalized = normalize_status(original)
            %TODO: normalize weird 100-200, etc. values
            %      is direction steering angle?
            normalized = original; %TODO
        end
        
    end
    
    
end