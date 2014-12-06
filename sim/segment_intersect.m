function [does_cross, cross_points, new_angles, remaining_dist] = ...
    segment_intersect(pt, delta_pt, wall, varargin)
% Determine if point moving a small increment intersercts a fixed wall
% If there is an intersection, find the intersection point, the reflection
% direction, and the amount of distance left to move such that
% abs(delta_pt) meters are still traveled
%
% Inputs:
%   pt: [num_rays, 2] matrix of <x,y> coordinates
%   delta_pt: [num_rays, 2] matrix of <delta_x, delta_y> vectors
%   wall: <x_start, x_end, y_start, y_end> representation of wall
%  
%  Optional Inputs:
%   plot: Set to 1 to plot simulation. Defaults to 0
%
% Outputs:
%   does_cross: [num_rays, 1] matrix of whether ray intersected
%   cross_points: [num_crosses, 2] matrix of points where rays intersected
%   new_angles: [num_crosses, 1] matrix of ray angles after reflection
%   remaining_dist: [num_crosses, 1] matrix of distances left after
%     reflection in the direction of new_angles
%

ip = inputParser;
ip.addOptional('plot', 0);
ip.parse(varargin{:})
args = ip.Results;

% Always have the wall vector pointing in +x direction
wall_vec = [wall(2) - wall(1), wall(4) - wall(3)];
if wall_vec(1) < 0
    wall_vec = wall_vec*-1;
end

% Find cross product of wall vector and ray movement vector
xprod = delta_pt(:, 1) .* wall_vec(:, 2) - delta_pt(:, 2) .* wall_vec(:, 1);

qmp = repmat([wall(1), wall(3)], [size(pt, 1), 1]) - pt;
t = (qmp(:, 1) .* wall_vec(:, 2) - qmp(:, 2) .* wall_vec(:, 1)) ./ xprod;
u = (qmp(:, 1) .* delta_pt(:, 2) - qmp(:, 2) .* delta_pt(:, 1)) ./ xprod;

% The previous two lines will be garbage when the denominator is 0
% We don't care about those since they are not intersections anyway
t(xprod == 0) = -1;
u(xprod == 0) = -1;

% if 0 <= t <= 1 and 0 <= u <= 1, the vectors intersect
does_cross = t<=1 & t>= 0 & u<=1 & u>=0;

% Exit early if no rays intersected
if sum(does_cross) == 0
    cross_points = [];
    new_angles = [];
    remaining_dist = [];
    return
end

% Cross point is pt + delta_pt*t
cross_points = pt(does_cross, :) + delta_pt(does_cross, :) .* ...
    repmat(t(does_cross, :), [1, 2]);

remaining_dist = (1.0-t(does_cross)) ...
    .* sqrt(sum(delta_pt(does_cross, :) .* delta_pt(does_cross, :), 2));

% Compute new angles
wall_angles = atan2d(wall_vec(:, 2), wall_vec(:, 1));
old_angles = atan2d(delta_pt(does_cross, 2), delta_pt(does_cross, 1));
new_angles = mod(2*wall_angles - old_angles, 360);

% Advance each cross point slightly in the direction of reflection
% This is just so that at the next time step, we don't think that it needs
% to be reflected again
unit_vectors = [cosd(new_angles), sind(new_angles)];
cross_points = cross_points + 10^-9 * unit_vectors;

if args.plot
    figure()
    hold on
    line([wall(1), wall(3)], [wall(2),wall(4)])
    a_cross = pt(does_cross, :);
    ref_pos = cross_points + unit_vectors .* ...
        repmat(remaining_dist, [1, 2]);
    if sum(~does_cross) > 0
        line([pt(~does_cross, 1), ...
            pt(~does_cross, 1) + delta_pt(~does_cross, 1)]', ...
            [pt(~does_cross, 2), ...
            pt(~does_cross, 2) + delta_pt(~does_cross, 2)]');
    end
    if sum(does_cross) > 0
        line([a_cross(:, 1), cross_points(:, 1)]', ...
            [a_cross(:, 2), cross_points(:, 2)]');
        line([cross_points(:, 1), ref_pos(:, 1)]', ...
            [cross_points(:, 2), ref_pos(:, 2)]');
    end
    axis([-8, 8, -8, 8])
end

end
