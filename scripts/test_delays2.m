%measured duration of status request:
%
%EPOCommunications without eval:     0.012-0.014s
%EPOCommunications with eval/evalc:  0.012-0.014s
%method:                             0.0005s
%method with evalc (and varargin):   0.012s-0.014s
%
%com.get_status:                     0.12s
%com.send:                           0.12s (!)
%com.send with evalc without saving output of evalc: 0.012-0.014s (!)
%
%kitt.get_status:                    0.36s
%kitt.get_status without gui update: 0.12s
%gui.update_status_kitt:             0.21-0.22s

tt = [];
for i = 1:20
    t = tic;
    com.send('transmit', 'S');
    %evalc('EPOCommunications(''transmit'', ''S'')');
    tt(end+1) = toc(t);
end
avg = mean(tt)
