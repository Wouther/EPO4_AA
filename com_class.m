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
            global gui;
            
            self.status  = 0;
            
            self.comport = comportnr;
            if comportnr < 0
                disp('Note: using dummy connection.');
            end
        end
        
        function open(self)
            global gui;
            
            if self.status
                disp('Connection can''t be opened as it is already open.');
                return;
            end

            disp('Opening connection...');

            result = self.send('open', ['\\.\COM' int2str(self.comport)]);

            %TODO: useless error? returns 0 when ok?
            if ~result
                disp('ERROR: could not open comport.');
                return;
            else
                disp('Done.');
            end

            self.status = 1;
            gui.update_status_com();
        end
        
        function close(self)
            global gui;
            
            if ~self.status
                disp('Connection can''t be closed as it is not open.');
                return;
            end

            disp('Closing connection...');

            self.send('close');
            
            disp('Done.');
            
            self.status = 0;
            gui.update_status_com();
        end
        
        %Get KITT's status (NOT connection status!)
        function status_kitt = get_status(self)
            self.status_kitt_raw = self.send('transmit', 'S');
            
            %Return formatted status
            status_kitt = self.format_status_kitt(self.status_kitt_raw);
        end

        %Send drive command to KITT.
        %   direction: Integer between 100 and 200, 150 is neutral.
        %   speed    : Integer between 135 and 165, 150 is neutral.
        %              Smaller than 150 means backwards, larger forwards.
        function send_drive_command(self, direction, speed)
            command = ['D' int2str(direction) ' ' int2str(speed)]
            self.send('transmit', command);
        end
        
        %Turn audio beacon on (1) or off (0)
        function set_audio_beacon(self, onoff)
            command = ['A' ~logical(onoff)]
            self.send('transmit', command);
        end
        
        %Wrap communications function to be able to test code without KITT.
        %Chooses between EPOCommunications.mex64 and EPOCommunications_dummy.m
        function varargout = send(self, varargin)
            %note: odd syntax because of Matlab quirk
            if self.comport < 0
                [varargout{1:nargout}] = EPOCommunications_dummy(varargin{:});
            else
                [varargout{1:nargout}] = EPOCommunications(varargin{:});
            end
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