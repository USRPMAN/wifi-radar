% Script to calculate range autocorrelation function for OFDM wifi pulses.

% load('wifidata.mat');
Ts = params.chanSamplePeriod;

[r, lags] = xcorr(d, d, 80);
rdB = 20*log10(abs(r));
lengthRcf = (length(r) - 1) / 2;
scatter(lags(lengthRcf+1:end)*Ts*10^6, rdB(lengthRcf+1:end) - max(rdB), 'r'); hold on;
plot(lags(lengthRcf+1:end)*Ts*10^6, rdB(lengthRcf+1:end) - max(rdB))
xlabel('Delay (us)');
ylabel('Auto-Correlation Function (dBr)');
title('Auto-Correlation Function of 1 sec simulated OFDM wi-fi data');