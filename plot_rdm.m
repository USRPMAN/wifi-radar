function plot_rdm()

load('wifidata.mat');
load('wifi_filtered.mat');

rdm = getRDM(d, d_out, 250000, 1:80:20000000);
save('test_rdm.mat', 'rdm');
imagesc(20*log10(abs(rdm)))
end
