function ray_trace(Tx, Rx, walls, fc, sample_freq, target_position)
% Tx: [x, y]
% Rx: [x, y]
% walls: [size, 4] (x_start, x_end, y_start, y_end)
% fc: frequency
% sample_freq: frequency
%
% At the moment doesn't deal with a moving target, or really
% a target at all.

num_rays = 800;
ray_angles = 0:360/num_rays:360-1e-9;

target_walls = generate_target_walls(target_position);
walls(end+1:end+size(target_walls, 1), :) = target_walls;

% rays: [x, y, ray_angle, tx_coef]
% tx_coef: starts at 1, lower if going through walls
rays = zeros(num_rays, 4);
rays(:, 1) = Tx(1);
rays(:, 2) = Tx(2);
rays(:, 3) = ray_angles;
rays(:, 4) = 1.0;

num_iterations = 1000;
time_step = 1 / sample_freq;
figure()
for iteration=1:num_iterations % later could change to while loop
    t = iteration / sample_freq;
    r = 3e8 * t;
    num_rays = size(rays, 1);
    
    if numel(rays) == 0
        break
    end

    pos_update = [cosd(rays(:, 3)), sind(rays(:, 3))] * 3e8 * time_step;
    all_does_cross = zeros(num_rays, 1);
    best_cross_points = zeros(num_rays, 2);
    best_remaining_dist = zeros(num_rays, 1);
    best_new_angles = zeros(num_rays, 1);
    
    % Check for intersection with each wall
    % Keep track of which intersected wall was closest, in the event that the 
    % distance step of the ray intersects 2 walls
    for wall_idx=1:size(walls, 1)
        ref1 = walls(wall_idx, [1, 3]);
        ref2 = walls(wall_idx, [2, 4]);
        [does_cross, cross_points, new_angles, remaining_dist] = ...
            segment_intersect(rays(:, 1:2), rays(:, 1:2) + pos_update, ...
            ref1, ref2);
        
        if sum(does_cross) > 0
            temp_remaining_dist = zeros(num_rays, 1);
            temp_remaining_dist(does_cross) = remaining_dist;
            temp_cross_points = zeros(num_rays, 2);
            temp_cross_points(does_cross, :) = cross_points;
            temp_new_angles = zeros(num_rays, 1);
            temp_new_angles(does_cross) = new_angles;
            temp_does_cross = zeros(num_rays, 1);
            temp_does_cross(does_cross) = 1;

            to_update = temp_remaining_dist > best_remaining_dist;
            best_remaining_dist(to_update) = temp_remaining_dist(to_update);
            best_cross_points(to_update, :) = temp_cross_points(to_update, :);
            best_new_angles(to_update) = temp_new_angles(to_update);
            
            all_does_cross = all_does_cross | temp_does_cross;
        end
    end

    % Move rays forward
    rays(:, 1:2) = rays(:, 1:2) + pos_update(:, 1:2);
    
    if sum(all_does_cross) > 0
        % Add new paths
        rays(end+1:end+sum(all_does_cross), :) =  ...
            [best_cross_points(all_does_cross, 1), ...
             best_cross_points(all_does_cross, 2), ...
             best_new_angles(all_does_cross), ...
             rays(all_does_cross, 4) * 0.631]; % TODO
                  
        % Attenuate path that hit wall
        rays(all_does_cross, 4) = rays(all_does_cross, 4) * 0.631; % TODO
    end
    
    % Prune rays that have below certain strength
    sig_strength = rays(:, 4) / r;
    above_cutoff = sig_strength > 0.001; % TODO
    rays = rays(above_cutoff, :);
    
    clf;
    hold on
    
    for wall_idx=1:size(walls, 1)
        w = walls(wall_idx, :);
        line([w(1), w(2)], [w(3), w(4)]);
    end
    
    scatter(rays(:, 1), rays(:, 2));
    axis([-20, 20, -20, 20]);
    hold off
    drawnow;
    
    

end


end
