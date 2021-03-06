%Handles communication with KITT
classdef com_class < handle
    
    properties
        comport;
        status; %connection status
        rawout; %fields:
        %.suppress (setting)
        %.last_output (raw text of last output)
        %.last_message (last displayed message. only available when
        %   suppress is true)
    end
    
    methods

        %Constructor
        function self = com_class(comportnr, suppresscomout)
            self.status  = 0;
            
            self.comport = comportnr;
            if comportnr < 0
                disp('Note: using dummy connection.');
            end
            
            self.rawout.suppress = suppresscomout;
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
        %Returns false when getting status failed.
        function status_kitt = get_status(self)
            self.rawout.last_output = self.send('transmit', 'S');
            
            %Return formatted status
            [formatted, status_type] = self.format_status_kitt(self.rawout.last_output);
            if strcmp(status_type, 'kitt')
                status_kitt = formatted;
            else %getting status fails when sent too soon after other (drive?) command
                status_kitt = false;
            end
        end

        %Send drive command to KITT.
        %   direction: Integer between 100 and 200, 150 is neutral.
        %   speed    : Integer between 135 and 165, 150 is neutral.
        %              Smaller than 150 means backwards, larger forwards.
        function send_drive_command(self, direction, speed)
            command = ['D' int2str(direction) ' ' int2str(speed)];
            self.send('transmit', command);
        end
        
        %Turn audio beacon on (1) or off (0)
        function set_audio_beacon(self, onoff)
            command = ['A' ~logical(onoff)]
            self.send('transmit', command);
        end
        
        %Wrap communications function to be able to test code without KITT.
        %Chooses between EPOCommunications.mex64 and EPOCommunications_dummy.m
        function output = send(self, varargin)
            %Dummy or mex-function?
            %note: odd syntax "{:}" because of Matlab quirk
            if self.comport < 0
                command = 'EPOCommunications_dummy(varargin{:})';
            else
                command = 'EPOCommunications(varargin{:})';
            end
            
            %Suppress output or not?
            if self.rawout.suppress
                [self.rawout.last_message, self.rawout.last_output] = ...
                    evalc(command); %TODO: known error when mex-function
                    % returns no output at all. Hard to solve. Only occurs
                    % when trying to send commands without KITT available?
            else
                self.rawout.last_output = eval(command);
            end
            
            output = self.rawout.last_output;
        end
        
    end
    
    methods (Static)
        
        %Format status from raw block of text into nice structure.
        %Also returns whether it's a drive status or KITT status.
        %TODO: test how fast/slow all the string handling is...
        function [formatted, status_type] = format_status_kitt(raw)
            s  = strsplit(raw, char(10));
            s1 = char(s(1));
            if strcmp(s1(1:3), 'L/R');
                %Parse drive status
                status_type = 'drive';
                for i = 1:length(s)-1
                    si  = char(s(i));
                    switch si(1)
                        case 'L' %direction
                            formatted.direction = str2num(char(si(6:end-2)));
                        case 'D' %speed
                            formatted.speed = str2num(char(si(8:end-2)));
                    end
                end
            else
                %Parse KITT status
                status_type = 'kitt';
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
    
end