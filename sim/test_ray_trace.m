function test_ray_trace()

Tx = [0, 0];
Rx = [5, 1];
walls = [8, 8, -10, 10;
         16,16,-12, 12];


ray_trace(Tx, Rx, walls, 2.4e9, 3e9);
end
