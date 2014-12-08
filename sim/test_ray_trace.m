function test_ray_trace()

Tx = [0, 0];
Rx = [9.05, 0];
walls = [8, 8, -5, 5;
         2, 2, -5, 5;
         2, 8, -5, -5;
         2, 8, 5, 5;
         -4, -4, -5, 5;
         -4, 2, -5, -5;
         -4, 2, 5, 5];
target_position = [4, 0];
target_velocity = [1, 0]; % 1 m/s to the right
time_increments = 10e-3; % 1ms
num_symbols = 4;

load('test_data/test_ray_trace.mat');
expected_h = h;

num_iterations = 1200;
h = zeros(num_symbols, num_iterations);
figure()
for i=1:num_symbols
    target = target_position + target_velocity * (i-1) * time_increments;
    h(i, :) = ray_trace(Tx, Rx, walls, 9e9, target, 'num_iterations', num_iterations);    
    subplot(num_symbols, 1, i);
    plot(1:num_iterations, abs(h(i, :)));
end

%save('test_data/test_ray_trace.mat', 'h');

assert(all(all(h == expected_h)));
    
end
