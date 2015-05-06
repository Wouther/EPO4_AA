%Graph curve data
%
%Input point needs three coordinates. Pass empty vector to skip plotting point
function handle = graph_curves(curves, point)

    handle = figure();
    hold on;
    
    %plot data
    x = []; y = []; f = [];
    for ci = 1:length(curves)
        ii = [1:length(curves(ci).y)] + length(y);
        x(ii) = curves(ci).x;
        y(ii) = curves(ci).y;
        f(ii) = curves(ci).f;
        plot3(x(ii), y(ii), f(ii), 'Color','blue');
    end

    %plot point
    if length(point) == 3
        plot3(point(1), point(2), point(3), ...
            'Marker','o', 'MarkerEdgeColor','r');
        lines = [point; point];
        for i = 1:3
            linei = lines;
            linei(2, i) = 0;
            line(linei(:,1), linei(:,2), linei(:,3), ...
                'LineStyle','--', 'Color','r', 'Marker','none');
        end
    end
    
    %graph settings
    view(-37.5+180, 30); %view in 3d
    grid on;
    xlabel('x');
    ylabel('y');
    zlabel('f');
   
end