function [is_inside, dist_from_ray1] = rx_intersect(Rx, ray1, ray2, ...
    cw1, cw2, angle, varargin)

ip = inputParser;
ip.addOptional('plot', 0);
ip.parse(varargin{:})
args = ip.Results;

pts = [ray1(1) + cw1*cosd(angle - 90), ray1(2) + cw1*sind(angle - 90); ...
       ray1(1) + cw1*cosd(angle + 90), ray1(2) + cw1*sind(angle + 90); ...
       ray2(1) + cw2*cosd(angle + 90), ray2(2) + cw2*sind(angle + 90); ...
       ray2(1) + cw2*cosd(angle - 90), ray2(2) + cw2*sind(angle - 90)];
       
walls = [pts(1:end, 1), pts([2:end,1], 1), pts(1:end, 2), pts([2:end,1], 2)];

cnt = 0;
for wall_idx=1:size(walls, 1)
    [does_cross, ~, ~, ~] = segment_intersect(Rx, [100, 0], walls(wall_idx, :));
    cnt = cnt + does_cross;
end

is_inside = mod(cnt, 2);

% If inside, need to compute the phase
dist_from_ray1 = -1;
if is_inside
    a = ray2 - ray1;
    b = Rx - ray1;
    dist_from_ray1 = dot(a, b) / sqrt(sum(a.^2));
end

if args.plot
    figure()
    hold on
    plot(pts([1:end,1], 1), pts([1:end,1], 2));
    plot(ray1(1) + a(1)*dist_from_ray1/sqrt(sum(a.^2)), ray1(2) + ...
        a(2)*dist_from_ray1/sqrt(sum(a.^2)));
    plot(Rx(1), Rx(2), 'x');
end
    
end
