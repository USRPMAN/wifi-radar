function ray_trace(Tx, Rx, walls, fc, sample_freq)
% Tx: [x, y]
% Rx: [x, y]
% walls: [size, 4] (x_start, x_end, y_start, y_end)
% fc: frequency
% sample_freq: frequency
%
% At the moment doesn't deal with a moving target, or really
% a target at all.

num_rays = 10;
ray_angles = 0:360/num_rays:360-1e-9;

% rays: [x, y, ray_angle, tx_coef]
% tx_coef: starts at 1, lower if going through walls
rays = zeros(num_rays, 4);
rays(:, 1) = Tx(1);
rays(:, 2) = Tx(2);
rays(:, 3) = ray_angles;
rays(:, 4) = 1.0;

num_iterations = 100;
time_step = 1 / sample_freq;
t = 0;
for iteration=1:num_iterations % later could change to while loop
    if numel(rays) == 0
        break
    end

    pos_update = [cos(rays(:, 3)), sin(rays(:, 3))] * 3e8 * time_step;
    for wall_idx=1:size(walls, 1)
        ref1 = walls(wall_idx, [1, 3]);
        ref2 = walls(wall_idx, [2, 4]);
        [does_cross, new_angles, remaining_dist] = ...
            segment_intersect(rays(:, 1:2), rays(:, 1:2) + pos_update, ...
            ref1, ref2);
        
        rays(:, 1:2) = rays(:, 1:2) + pos_update;
        
        
        if sum(does_cross) > 0
            iteration
        end
    end
    
    
end


end
