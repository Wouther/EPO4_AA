%Linearly interpolate between curves.
%A curve is set for one variable (here x) but varies for another (here y).
%The interpolated function value on point (x0, y0) is returned.
%
%Curves are input as structures with fields x (single scalar), y (vector)
% and f (vector), with y and f equally long. It is assumed the curves are
% sorted by ascending x and data is sorted by ascending y (done when 
% generating curve). Point is input as [x y].
function value = interpolate_curves(curves, curves_lookup, point)

    x0 = point(1);
    y0 = point(2);

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
        ci   = [ci1 (ci1+1)];
        x(1) = curves(ci(1)).x;
        x(2) = curves(ci(2)).x;
        f(1) = getvalueoncurve(ci(1), y0);
        f(2) = getvalueoncurve(ci(2), y0);
        value = f(1) + ((f(2)-f(1)) / (x(2)-x(1))) * (x0-x(1));
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
            di = [di1 (di1+1)];
            y = curves(ci).y(di);
            f = curves(ci).f(di);
            value = f(1) + ((f(2)-f(1)) / (y(2)-y(1))) * (y0-y(1));
        end
    end

end