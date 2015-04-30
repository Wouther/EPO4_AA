%Handles communication with KITT
classdef com_class < handle
    
    properties
        comport;
        status; %connection status
        status_kitt_raw; %KITT's last raw status text
    end
    
    methods

        %Constructor
        function self = com_class(comportnr)
            self.status  = 0;
            self.comport = ['\\.\COM' int2str(comportnr)];
        end
        
        function open(self)
            if self.status
                disp('Connection can''t be opened as it is already open.');
                return;
            end

            disp('Opening connection...');

            result = EPOCommunications('open', self.comport);
            
            if ~result
                disp('ERROR: could not open comport.');
                return;
            end

            self.status = 1;
        end
        
        function close(self)
            if ~self.status
                disp('Connection can''t be closed as it is not open.');
                return;
            end

            disp('Closing connection...');

            EPOCommunications('close');

            self.status = 0;
        end
        
        %Get KITT's status (NOT connection status!)
        function status_kitt = get_status(self)
            self.status_kitt_raw = EPOCommunications('transmit', 'S');
            %self.status_kitt_raw = dummystatus(); %temporary
            
            %Return formatted status
            status_kitt = self.format_status_kitt(self.status_kitt_raw);
        end

        %Send drive command to KITT.
        %   direction: Integer between 100 and 200, 150 is neutral.
        %   speed    : Integer between 135 and 165, 150 is neutral.
        %              Smaller than 150 means backwards, larger forwards.
        function send_drive_command(self, direction, speed)
            command = ['D' int2str(direction) ' ' int2str(speed)]
            EPOCommunications('transmit', command);
            %self.status_kitt_raw = dummystatus(); %temporary
        end
        
        %Turn audio beacon on (1) or off (0)
        function set_audio_beacon(self, onoff)
            command = ['A' ~logical(onoff)]
            EPOCommunications('transmit', command);
            %self.status_kitt_raw = dummystatus(); %temporary
        end
        
    end
    
    methods (Static)
        
        %Format status from raw block of text into nice structure
        %TODO: test how fast/slow all the string handling is...
        function formatted = format_status_kitt(raw)
            %TODO: check validity of data here
            
            s = strsplit(raw, '\n');
            for i = 1:length(s)-1
                si = char(s(i));
                switch si(1)
                    case 'D' %drive command
                        values = str2num(char(strsplit(si(2:end))));
                        formatted.direction = values(1);
                        formatted.speed     = values(2);
                    case 'U' %distance sensor
                        formatted.distance = str2num(char(strsplit(si(2:end))))';
                    case 'A' %battery or audio
                        if strcmp(si(2), 'u') %audio
                            formatted.audio = str2num(char(si(end-1:end)));
                        else %battery
                            formatted.battery = str2num(char(si(2:end)));
                        end
                end
            end
        end
        
    end
    
end