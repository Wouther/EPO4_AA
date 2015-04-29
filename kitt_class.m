%Holds data concerning KITT and interacts with it.
%Uses com and gui objects.
classdef kitt_class < handle

    properties
        status;
    end
    
    methods
       
        function status = get_status(self)
            global com;
            
            status_original = com.get_status();
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