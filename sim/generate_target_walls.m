function [walls] = generate_target_walls(target)

num_sides=16;
radius=0.5;
angles=0:360.0/num_sides:360-1e-9;
corners=[cosd(angles')*radius, sind(angles')*radius] + repmat(target, [num_sides, 1]);
walls=[corners(:, 1), corners([2:end,1], 1), ...
    corners(:, 2), corners([2:end,1], 2)];

%figure()
%hold on
%for wall_idx=1:size(walls, 1)
%    w = walls(wall_idx, :);
%    line([w(1), w(2)], [w(3), w(4)]);
%end

end
