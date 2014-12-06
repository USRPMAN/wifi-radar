function [walls] = generate_target_walls(target, varargin)
% Generate a matrix of walls to represent a target
% Represent targets as a bunch of small walls forming nearly a circle
%
% Inputs:
%   target: [x,y] coordinate of target center
%   
%   As optional args: 
%   num_sides: (optional) number of sides to represent target as. Defaults
%     to 128
%   radius: (optional) radius of target. Defaults to 0.5 meters
%   plot: (optional) Set to 1 to plot the target. Defaults to 0
%
% Example: generate_target_walls([3,2], 'plot', 1);
%  
% Outputs:
%   walls: [num_sides, 4] matrix 

ip = inputParser;
ip.addOptional('num_sides', 128);
ip.addOptional('radius', 0.5);
ip.addOptional('plot', 0);
ip.parse(varargin{:})
args = ip.Results;

angles=0:360.0/args.num_sides:360-1e-9;
corners=[cosd(angles')*args.radius, sind(angles')*args.radius] + ...
    repmat(target, [args.num_sides, 1]);
walls=[corners(:, 1), corners([2:end,1], 1), ...
    corners(:, 2), corners([2:end,1], 2)];

if args.plot
    figure()
    hold on
    for wall_idx=1:size(walls, 1)
        w = walls(wall_idx, :);
        line([w(1), w(2)], [w(3), w(4)]);
    end
end

end
