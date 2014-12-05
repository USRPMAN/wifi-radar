function test_ray_trace()

Tx = [0, 0];
Rx = [2, 2];
walls = [8, 8, -10, 10;
         16,16,-12, 12];
target_position = [4, 4];


impulse_response = ray_trace(Tx, Rx, walls, 3e9, target_position);
%impulse_response
end
