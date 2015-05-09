%Handles all GUI events, callbacks, etc.
classdef gui_class < handle

    properties
        fig;
        handle;
    end
    
    methods

        %Constructor
        function self = gui_class()
            %Start gui
            self.fig    = gui_figure; %use 'gui_figure' .fig and .m as created with GUIDE
            self.handle = guihandles(self.fig);

            %Initialise
            set(self.handle.figure1, 'Name', 'KITT GUI');
            self.update_statusbar('axes_status_direction', 0, 'bi');
            self.update_statusbar('axes_status_speed',     0, 'bi');
            self.update_statusbar('axes_status_distance1', 0);
            self.update_statusbar('axes_status_distance2', 0);
            self.update_statusbar('axes_status_battery',   0);
            self.update_statusbar('axes_status_audio',     0);
            self.update_textfield('text_status_direction', '');
            self.update_textfield('text_status_speed',     '');
            self.update_textfield('text_status_distance1', '');
            self.update_textfield('text_status_distance2', '');
            self.update_textfield('text_status_battery',   '');
            self.update_textfield('text_status_time',      'never');
            
            %Listen to key presses
            set(self.fig, 'KeyPressFcn', @self.callback_keypress);

            %Clean exit when closing window
            set(self.fig, 'CloseRequestFcn', @self.callback_close);
        end

        %Update a specific (horizontal) statusbar.
        %Optionally pass along the bar's desired colour or 'bi' to make the
        % bar bidirectional. When bidirectional, fraction can be negative.
        function update_statusbar(self, axesname, fraction, varargin)
            ax = eval(['self.handle.' axesname]);
            lim = [0 1];
            c = 'k'; %default colour
            if ~isempty(varargin) && ischar(varargin{1})
                if strcmp(varargin{1}, 'bi')
                    lim(1) = -1;
                else
                    c = varargin{1};
                end
            end
                
            barh(ax, 0, fraction, 1, c);
            
            %TODO: why does this have to be set every time?
            set(ax, 'XLim', lim);
            set(ax, 'XTick', []);
            set(ax, 'YTick', []);
            set(ax, 'XTickLabel', []);
            set(ax, 'YTickLabel', []);
        end
        
        %Update a specific text field.
        function update_textfield(self, fieldname, text)
            h = eval(['self.handle.' fieldname]);
            set(h, 'String', text);
        end
        
        function update_status_kitt(self)
            global kitt;
            
            batt_frac = kitt.status.battery/18e3;
            if batt_frac < 0.5
                batt_col = 'r';
            elseif batt_frac < 0.75
                batt_col = 'y';
            else
                batt_col = 'g';
            end
            
            self.update_statusbar('axes_status_direction', ...
                (kitt.status.direction-150)/50, 'bi');
            self.update_statusbar('axes_status_speed', ...
                (kitt.status.direction-150)/15, 'bi');
            self.update_statusbar('axes_status_distance1', kitt.status.distance(1)/299);
            self.update_statusbar('axes_status_distance2', kitt.status.distance(2)/299);
            self.update_statusbar('axes_status_battery',   batt_frac, batt_col);
            self.update_statusbar('axes_status_audio',     kitt.status.audio);

            self.update_textfield('text_status_direction', kitt.status.direction);
            self.update_textfield('text_status_speed',     kitt.status.speed);
            self.update_textfield('text_status_distance1', ...
                [int2str(kitt.status.distance(1)) 'cm']);
            self.update_textfield('text_status_distance2', ...
                [int2str(kitt.status.distance(2)) 'cm']);
            self.update_textfield('text_status_battery',   ...
                [num2str(kitt.status.battery/1e3, '%.1f') 'V']);
            self.update_textfield('text_status_time',      ...
                char(datetime('now', 'TimeZone','local', 'Format','HH:mm:ss.S')));
        end
        
        %Make connection status visible in gui
        function update_status_com(self)
            global com;
            
            if com.status
                set(self.handle.button_connect,    'FontWeight', 'bold');
                set(self.handle.button_disconnect, 'FontWeight', 'normal');
            else
                set(self.handle.button_connect,    'FontWeight', 'normal');
                set(self.handle.button_disconnect, 'FontWeight', 'bold');
            end
        end
        
        %Update gui with all available data
        function update(self)
            self.update_status_com();
            self.update_status_kitt();
        end
        
        function exit(self)
            global com updater kitt;
            
            %If still connected, offer to close it
            if com.status
                sel = questdlg('The connection is still online! Close it to exit KITT GUI?', ...
                    'Exit KITT GUI', ...                     %Title
                    'Close connection & Exit', 'Cancel', ... %Options
                    'Close connection & Exit');              %Default
                switch sel, 
                    case 'Close connection & Exit',
                        com.close();
                    case 'Cancel'
                    return 
                end
            end

            %Check again, and exit cleanly when not connected
            if ~com.status
                %Stop and destroy timer
                if strcmp(get(updater, 'Running'), 'on')
                    stop(updater);
                end
                delete(updater)
                
                %Stop driving
                kitt.drive(150, 150);
                
                %Close connection
                if com.status
                    com.close();
                end
                
                %Close window
                delete(self.fig);
            end

        end
        
        function panic(self)
            global gui kitt updater;
            
            disp('PANIC');
            
            %Stop timer
            if strcmp(get(updater, 'Running'), 'on')
                stop(updater);
                set(gui.handle.button_start_updater, 'FontWeight', 'normal');
                set(gui.handle.button_stop_updater,  'FontWeight', 'bold');
            end
            
            %Stop driving
            kitt.drive(150, 150);
        end
        
        function callback_keypress(self, ~, event)
            %Panic on Escape
            if strcmp(event.EventName, 'KeyPress') && strcmp(event.Key, 'escape')
                self.panic();
            end
        end
        
        function callback_close(self, ~, event)
            %Exit on window close
            self.exit();
        end        
        
    end
    
end