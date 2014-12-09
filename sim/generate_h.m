function test_rdm()

Tx = [0, 0];
Rx = [-4.05, 0];
walls = [];
target_position = [20, 0];
target_velocity = [4, 0]; % 4 m/s to the right

num_symbols = 20000000;
time_increments = 1/20e6;
jumps = 80;

num_iterations = 5;
dec_rate = 1;
h = zeros(num_symbols / jumps, num_iterations / dec_rate);

inc = 0;
for i=1:jumps:num_symbols
    inc = inc + 1;
    target = target_position + target_velocity * (i-1) * time_increments;
    h_orig = ray_trace(Tx, Rx, walls, 20e6, target, 'num_iterations', num_iterations);    
    h(inc, :) = h_orig; %resample(h_orig, 1, dec_rate);
    if mod(i, 800) == 1
        i
    end
end

save('h_data.mat', 'h');


end
