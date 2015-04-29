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

            %Listen to key presses
            set(self.fig, 'KeyPressFcn', @self.callback_keypress);

            %Clean exit when closing window
            set(self.fig, 'CloseRequestFcn', @self.callback_close);
        end

        function setrawtext(self, text)
            set(self.handle.text_raw, 'String', text);
        end
        
        function update(self) %TODO: rename to update_status() or something?
            %TODO: update gui with status data
        end
        
        function exit(self)
            global com updater;
            
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

                %Close window
                delete(self.fig);
            end

        end
        
        function panic(self)
            disp('PANIC'); %TODO: stop driving, etc. (!!!)
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
        
        function callback_button_panic(self)
            self.panic();
        end
    
        function callback_button_start(self)
            global com updater;

            %Open connection
            com.open();

            %Start timer
            if strcmp(get(updater, 'Running'), 'off')
                start(updater);
            end
        end
        
        %TODO: also stop driving, etc. here!!!
        function callback_button_stop(self)
            global com updater;

            %Stop timer
            if strcmp(get(updater, 'Running'), 'on')
                stop(updater);
            end

            %Close connection
            com.close();
        end
        
    end
    
end