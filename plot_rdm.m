function plot_rdm()

load('wifidata.mat');
load('wifi_filtered.mat');

%d_out = d_out(1:20000000);

%rdm = getRDM(d, d_out, 250000, 1:80:20000000);
%save('test_rdm.mat', 'rdm');

rdm_new = getRDM(d(1601:end), d_out(1601:20000000), length(1601:80:20000000), (1601:80:20000000)-1600);
save('test_rdm_new2.mat', 'rdm_new');

imagesc(20*log10(abs(rdm_new)))
end
