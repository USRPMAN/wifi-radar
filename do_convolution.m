function do_convolution()

load('wifidata.mat');
load('sim/h_data.mat');

% every 1000 samples get new h
h_size = size(h, 2);
iterations = 80;
d_out = zeros(20000000+h_size-1, 1);
inc = 0;
for i=1:iterations:20000000-1
    inc = inc + 1;
    this_h = h(inc, :)';
    part = conv(d(i:(i+iterations-1)), this_h);
    %size(part)
    %size(d_out(i:(i+iterations+h_size-2)))
    d_out(i:(i+iterations+h_size-2)) = d_out(i:(i+iterations+h_size-2)) + part;
    
end

size(d_out)
save('wifi_filtered.mat', 'd_out');

end
