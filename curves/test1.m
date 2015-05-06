%Interpolation test

%% sample curve generation

curves = [];

%data generation (to be done by measurement)
cn = 7;
dn = 7;
for ci = 1:cn
    curves(ci).x = 1.25*ci; %constant for entire curve
    for di = 1:dn
        curves(ci).y(di) = di;
        curves(ci).f(di) = sin(pi*di/dn)/(sqrt(ci)/cn); %funky sine
    end
end

%some validity checking of curve data
for i = 1:length(curves)
    if length(curves(i).x) ~= 1
        disp(['Error: invalid x data for curve ' int2str(i) ...
            ': exactly one value required per curve, but number of ' ...
            'values is ' int2str(length(curves(i).x)) '.']);
    end
    if length(curves(i).y) ~= length(curves(i).f)
        disp(['Error: invalid data points for curve ' int2str(i) ...
            ': number of points not equal to number of values.']);
    end
end

%sort data and generate lookup vector (make as local function. input:
% curves. output: new curves and lookup vector)

    %get x data and sort data points for ascending y
    xdata = [];
    for i = 1:length(curves)
        xdata(i) = curves(i).x;
        
        %sort y data
        [curves(i).y pdata] = sort(curves(i).y);
        curves(i).f = curves(i).f(pdata);
    end
    
    %sort x data and structure itself
    [curves_lookup, pdata] = sort(xdata);
    curves = curves(pdata);
    

%% interpolation

curves
curves_lookup

%interpolate and graph
point = [6 1.75*pi]

close all;
fpoint = interpolate_curves(curves, curves_lookup, point)
graph_curves(curves, [point fpoint]);
