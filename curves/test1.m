%Interpolation test

%% sample curve generation

%data generation (to be done by measurement)
for i = 1:4
    j = i;
    if i == 2
        j = 3;
    end
    if i == 3
        j = 2;
    end
    curves(i).x    = 1.25*j; %constant for entire curve
    curves(i).y(1) = 9*i; %data point 1
    curves(i).f(1) = 2*i; %data point 1
    curves(i).y(2) = 3*i; %data point 2
    curves(i).f(2) = 4*i; %data point 2
    curves(i).y(3) = 7*i; %data point 3
    curves(i).f(3) = 5*i; %data point 3
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

%TODO: use interpolate_curves(...) here
