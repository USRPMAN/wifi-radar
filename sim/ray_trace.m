function [impulse_response] = ray_trace(Tx, Rx, walls, sample_freq, ...
    target_position, varargin)
% Tx: [x, y]
% Rx: [x, y]
% walls: [size, 4] (x_start, x_end, y_start, y_end)
% sample_freq: frequency
%

ip = inputParser;
ip.addOptional('num_iterations', 800);
ip.addOptional('num_rays', 1000);
ip.addOptional('wall_pass_gain', 0.5);
ip.addOptional('wall_refl_gain', 0.7);
ip.addOptional('gain_prune_cutoff', 0.001);
ip.addOptional('num_target_sides', 4);
ip.addOptional('fc', 2.4e9);
ip.addOptional('plot', 0);
ip.parse(varargin{:})
args = ip.Results;

ray_angles = 0:360/args.num_rays:360-1e-9;

target_walls = generate_target_walls(target_position, ...
    'num_sides', args.num_target_sides);
walls(end+1:end+size(target_walls, 1), :) = target_walls;

% rays: [x, y, ray_angle, tx_coef, num_reflections]
% tx_coef: starts at 1, lower if going through walls
rays = zeros(args.num_rays, 5);
rays(:, 1) = Tx(1);
rays(:, 2) = Tx(2);
rays(:, 3) = ray_angles;
rays(:, 4) = 1.0;

time_step = 1 / sample_freq;

if args.plot
    figure()
    
    filename = 'simulation.gif';
end

impulse_response = zeros(args.num_iterations, 1);
for iteration=1:args.num_iterations % later could change to while loop
    t = (iteration-1) / sample_freq;
    r = 3e8 * t;
    delta_r = 3e8 / sample_freq;
    args.num_rays = size(rays, 1);
    
    if numel(rays) == 0
        break
    end

    pos_update = [cosd(rays(:, 3)), sind(rays(:, 3))] * 3e8 * time_step;
    
    % look for intersection of rays with Rx
    % Consider the trapezoid that this ray will cover in this iteration and
    % whether the receiver point is inside that
    % This check is expensive so first make a bounding circle around the
    % trapezoid, and only do the full point in polygon calculation if
    % inside the circle
    current_vec_to_rx = rays(:, 1:2) - repmat(Rx, [size(rays, 1), 1]);
    current_dist_to_rx = sqrt(sum(abs(current_vec_to_rx).^2, 2));
    
    cwidth = sqrt(2*r^2 * (1-cosd(360 / args.num_rays))) / 2;
    cwidth_next = sqrt(2*(r+delta_r)^2 * (1-cosd(360 / args.num_rays))) / 2;
    circ_size = sqrt(delta_r^2 + cwidth_next^2);
    circ_intersect = current_dist_to_rx < circ_size;
        
    % For rays whose circles intersected the Rx, do the full calculation
    if sum(circ_intersect) > 0
        for idx=find(circ_intersect')
            [inside, dist_to_rx] = rx_intersect(Rx, rays(idx,1:2), ...
                rays(idx,1:2) + pos_update(idx,:), ...
                cwidth, cwidth_next, rays(idx, 3), 'plot', 0);
            if inside
                exact_t = t + dist_to_rx / 3e8;
                exact_r = 2e8 * exact_t;
                magnitude = rays(idx, 4) / exact_r;
                phase = 2*pi*args.fc*exact_t + pi * rays(idx, 5);
                impulse_response(iteration) = impulse_response(iteration) + ...
                magnitude * exp(-1i * phase);
            end
        end
    end
    
    % Check for intersecting with walls
    all_does_cross = zeros(args.num_rays, 1);
    best_cross_points = zeros(args.num_rays, 2);
    best_remaining_dist = zeros(args.num_rays, 1);
    best_new_angles = zeros(args.num_rays, 1);
    
    % Check for intersection with each wall
    % Keep track of which intersected wall was closest, in the event that the 
    % distance step of the ray intersects 2 walls
    for wall_idx=1:size(walls, 1)
        [does_cross, cross_points, new_angles, remaining_dist] = ...
            segment_intersect(rays(:, 1:2), pos_update, ...
            walls(wall_idx, :));
        
        if sum(does_cross) > 0
            temp_remaining_dist = zeros(args.num_rays, 1);
            temp_remaining_dist(does_cross) = remaining_dist;
            temp_cross_points = zeros(args.num_rays, 2);
            temp_cross_points(does_cross, :) = cross_points;
            temp_new_angles = zeros(args.num_rays, 1);
            temp_new_angles(does_cross) = new_angles;
            temp_does_cross = zeros(args.num_rays, 1);
            temp_does_cross(does_cross) = 1;

            to_update = temp_remaining_dist > best_remaining_dist;
            best_remaining_dist(to_update) = temp_remaining_dist(to_update);
            best_cross_points(to_update, :) = temp_cross_points(to_update, :);
            best_new_angles(to_update) = temp_new_angles(to_update);
            
            all_does_cross = all_does_cross | temp_does_cross;
        end
    end
    
    if sum(all_does_cross) > 0
        % Add new paths
        rays(end+1:end+sum(all_does_cross), :) =  ...
            [best_cross_points(all_does_cross, 1), ...
             best_cross_points(all_does_cross, 2), ...
             best_new_angles(all_does_cross), ...
             rays(all_does_cross, 4) * args.wall_refl_gain, ...
             rays(all_does_cross, 5) + 1];
                  
        % Attenuate path that hit wall
        rays(all_does_cross, 4) = rays(all_does_cross, 4) * args.wall_pass_gain;
    end
    
    % Move rays forward
    rays(1:size(pos_update, 1), 1:2) = rays(1:size(pos_update, 1), 1:2) ...
        + pos_update;
    
    % Prune rays that have below certain strength
    sig_strength = rays(:, 4) / r;
    above_cutoff = sig_strength > args.gain_prune_cutoff;
    rays = rays(above_cutoff, :);
    
    if args.plot
        clf;
        subplot(1,1,1)

        hold on
        plot(Rx(1), Rx(2), 'x');
        plot(Tx(1), Tx(2), '*');
        for wall_idx=1:size(walls, 1)
            w = walls(wall_idx, :);
            line([w(1), w(2)], [w(3), w(4)]);
        end

        scatter(rays(:, 1), rays(:, 2));
        axis([-10, 10, -10, 10]);
        hold off
        
        

        %subplot(1,2,2)
        %plot(1:args.num_iterations, abs(impulse_response));
        drawnow;
        frame = getframe(1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if iteration == 1
            imwrite(imind, cm ,filename, 'gif', 'Loopcount', inf);
        else
            imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append');
        end
    end
end

end
