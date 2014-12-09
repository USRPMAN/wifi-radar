function do_convolution()

load('wifidata.mat');
load('sim/h_data.mat');

% every 1000 samples get new h
d_out = zeros(20000000+8, 1);
inc = 0;
for i=1:10000:20000000-1
    inc = inc + 1;
    this_h = h(inc, :);
    part = conv(d(i:(i+10000-1)), this_h);
    d_out(i:(i+10006)) = d_out(i:(i+10006)) + part;
    
end

size(d_out)
save('wifi_filtered.mat', 'd_out');

end
