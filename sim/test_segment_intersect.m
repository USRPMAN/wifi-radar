function test_segment_intersect()

a = [-2, -2;
     -4, -2;
     -5, -2;
     -6, -2;
     -7, -2];
b = [3, 3;
     3, 2;
     2, 2;
     2, 2;
     2, 2];
ref1 = [0, 1];
ref2 = [1, 0];
[does_cross, cross_points, new_angles, remaining_dist] = segment_intersect(a, b, ref1, ref2)


end
