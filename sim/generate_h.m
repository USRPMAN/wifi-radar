function generate_h()

Tx = [0, 0];
Rx = [-4.05, 0];
walls = [];
target_position = [20, 0];
target_velocity = [4, 0]; % 4 m/s to the right

num_symbols = 20000000;
time_increments = 1./num_symbols;

num_taps = 5; 
dec_rate = 1;

jumps=1:80:num_symbols;
h = zeros(numel(jumps), num_taps / dec_rate);
inc = 0;
for i=jumps
    inc = inc + 1;
    target = target_position + target_velocity * (i-1) * time_increments;
    h_orig = ray_trace(Tx, Rx, walls, 20e6, target, ...
        'num_iterations', num_taps, ...
        'num_rays', 2, ... % Everything along x axis...this makes it faster
        'wall_pass_gain', 0.5, ...
        'wall_refl_gain', 0.7);    
    h(inc, :) = h_orig; %resample(h_orig, 1, dec_rate);
    if mod(i, 8000) == 1
        i
    end
end

save('h_data.mat', 'h');


end
