%Linearly interpolate between curves.
%A curve is set for one variable (here x) but varies for another (here y).
%The interpolated function value on point (x0, y0) is returned.
%
%Curves are input as structures with fields x (single scalar), y (vector)
% and f (vector), with y and f equally long. It is assumed the curves are
% sorted by ascending x and data is sorted by ascending y (done when 
% generating curve). Point is input as [x y].
function value = interpolate_curves(curves, curves_lookup, point)

    [x0 y0] = point;

    %find nearest curves
    ci1 = find(curves_lookup <= x0, 1, 'last'); %curve index
    if isempty(ci1) %before first curve in set, no interpolation possible
        disp('Warning: attempt to interpolate before first curve.');
        value = getvalueoncurve(1, y0); %TODO: extrapolate linearly?!
    elseif curves_lookup(ci1) == x0 %curve is in set, no interpolation needed
        value = getvalueoncurve(ci1, y0);
    elseif ci1 == length(curves_lookup) %after last curve in set, no interpolation possible
        disp('Warning: attempt to interpolate after last curve.');
        value = getvalueoncurve(ci1, y0); %TODO: extrapolate linearly?!
    else %interpolation necessary and possible
        ci2 = ci1 + 1;
        [x1, x2] = curves([ci1 ci2]).x;
        f1  = getvalueoncurve(ci1, y0);
        f2  = getvalueoncurve(ci2, y0);
        value = f1 + ((f2-f1) / (x2-x1)) * (x0-x1);
    end


    %Interpolate between points on a single curve
    function value = getvalueoncurve(ci, y0)
        %find nearest data points
        di1 = find(curves(ci).y <= y0, 1, 'last'); %data index
        if isempty(di1) %before first point in set, no interpolation possible
            disp('Warning: attempt to interpolate before first data point.');
            value = curves(ci).f(1); %TODO: extrapolate linearly?!
        elseif curves(ci).y(di1) == y0 %point is in set, no interpolation needed
            value = curves(ci).f(di1);
        elseif di1 == length(curves(ci).y) %after last point in set, no interpolation possible
            disp('Warning: attempt to interpolate after last data point.');
            value = curves(ci).f(di1); %TODO: extrapolate linearly?!
        else %interpolation necessary and possible
            di2 = di1 + 1;
            [y1, y2] = curves(ci).y([di1 di2]);
            [f1, f2] = curves(ci).f([di1 di2]);
            value = f1 + ((f2-f1) / (y2-y1)) * (y0-y1);
        end
    end

end