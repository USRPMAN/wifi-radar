% Idea: Ray at point a is moving to point b
% Does it cross the line segment formed by points ref1 and ref2?
% return vector does_cross with same length as a, b set to 1 or 0
% for the ones where it does cross
% also return angle of line b-a after reflection and the length of (b-a)
%    minus the length it took it get from a to line segment ref1_ref2
%
% TODO: instead return new positions after reflection rather than remaining
% distance
function [does_cross, cross_points, new_angles, remaining_dist] = segment_intersect(a, b, ref1, ref2)
% a, b: [size, 2]
% ref1, ref2: x,y

r = b - a;
s = ref2 - ref1;

if s(1) < 0
    s = s*-1;
end

rcs = r(:, 1) .* s(:, 2) - r(:, 2) .* s(:, 1);

qmp = repmat(ref1, [size(a, 1), 1]) - a;

t = (qmp(:, 1) .* s(:, 2) - qmp(:, 2) .* s(:, 1)) ./ rcs;
u = (qmp(:, 1) .* r(:, 2) - qmp(:, 2) .* r(:, 1)) ./ rcs;

t(rcs == 0) = -1;
u(rcs == 0) = -1;

does_cross = t<=1 & t>= 0 & u<=1 & u>=0;

if sum(does_cross) == 0
    cross_points = [];
    new_angles = [];
    remaining_dist = [];
    return
end

%cross_points = ref1(does_cross, :) + s(does_cross, :) .* u(does_cross, :);
cross_points = a(does_cross, :) + r(does_cross, :) .* repmat(t(does_cross, :), [1, 2]);

move_to_cross = r(does_cross, :) .* repmat(t(does_cross, :), [1, 2]);
part1_dist = sqrt(sum(move_to_cross .* move_to_cross, 2));
total_dist = sqrt(sum(r(does_cross, :) .* r(does_cross, :), 2));
remaining_dist = total_dist - part1_dist;

wall_angles = atan2d(s(:, 2), s(:, 1));

% Compute new angles
old_angles = atan2d(r(does_cross, 2), r(does_cross, 1));
new_angles = mod(2*wall_angles - old_angles, 360);

% Advance each cross point slightly in the direction of reflection
% This is just so that at the next time step, we don't think that it needs
% to be reflected again
unit_vectors = [cosd(new_angles), sind(new_angles)];
cross_points = cross_points + 10^-9 * unit_vectors;

%reflected_positions = cross_points + unit_vectors .* repmat(remaining_dist, [1, 2]);

%figure()
%hold on
%line(ref1, ref2)
%a_cross = a(does_cross, :);
%line([a_cross(:, 1), cross_points(:, 1)]', [a_cross(:, 2), cross_points(:, 2)]');
%line([cross_points(:, 1), reflected_positions(:, 1)]', [cross_points(:, 2), reflected_positions(:, 2)]');
%axis([-8, 8, -8, 8])


end
