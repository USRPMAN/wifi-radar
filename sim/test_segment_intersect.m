function test_segment_intersect()

a = [-2, -2;
     -4, -2;
     -5, -2;
     -6, -2;
     -7, -2;
     5, 2];
b = [3, 3;
     3, 2;
     2, 2;
     2, 2;
     2, 2;
     -1, 0];

wall = [0, 1, 1, 0];

load('test_data/test_segment_intersect.mat');

[does_cross1, cross_points1, new_angles1, remaining_dist1] = ...
    segment_intersect(a, b-a, wall);

assert(all(does_cross == does_cross1));
assert(all(all(cross_points == cross_points1)));
assert(all(new_angles == new_angles1));
assert(all(remaining_dist == remaining_dist1));

end
