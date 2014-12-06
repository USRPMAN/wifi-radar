function rdm = getRDM(ref_sig, obs, numPulses, pulseStartIdx)

% This function generates the 2D (time delay / Doppler freq) cross
% correlation function between the reference signal and observed signal at
% the receiver over a single CPI.
%
% Inputs:
%   ref:                reference signal transmitted from access point
%   obs:                observed signal from receiver antenna
%   numPulses:          number of wifi pulses transmitted in signal ref
%   pulseStartIdx:      vector of length numPulses with time indices of
%                       start of each pulse
%
% Output:
%   rdm:                Coherently integrated RDM over this CPI
%
% Other info:
%   CPI length is equal to Nint*Ts, where Nint is length of observation
%   vector and Ts is sample time, 1/fs. Output of this function is a map in
%   range bins and Doppler bins, which are converted to real space as
%   follows. Here l is bin number in time delay direction and p is Doppler
%   bin.
%
%   t(l) = l*Ts    -->    deltaR(l) = c*t(l)
%   f_d(p) = p / (Nint*Ts)   -->   deltaV(p) = lambda*f_d(p)

% Total number of integrated samples
Nint = length(obs);
numDopplerBins = 128; %Doppler resolution = c/(fc * Nint * Ts), 
                      % i.e. c / (2.4GHz * length of input data)
p = -numDopplerBins/2:numDopplerBins/2-1;

% Use a cell array to store each initial time cross correlation in case
% they are different lengths. Not the fastest but that's ok
chi_m = cell(1, numPulses);
lags = cell(1, numPulses);

% Calculate the cross correlation for each pulse and store it.
[chi_m{1}, lags{1}] = xcorr(obs(1:pulseStartIdx(2)-1), ref_sig(1:pulseStartIdx(2)-1));
for m = 2:numPulses-1
    [chi_m{m}, lags{m}] = xcorr( ...
        obs(pulseStartIdx(m):pulseStartIdx(m+1)-1), ...
        ref_sig(pulseStartIdx(m):pulseStartIdx(m+1)-1));
end
[chi_m{numPulses}, lags{numPulses}] = xcorr( ...
    obs(pulseStartIdx(numPulses):end), ...
    ref_sig(pulseStartIdx(numPulses):end));

% Find the zero lag indices (corresponding to differential bistatic range
% of 0 meters) and trim the cross correlations to start at that index, and
% create a zero-padded matrix of each cross correlation
zeroLagIdx = cellfun(@(x) find(x == 0), lags);

chi_m_trimmed = cell(1, numPulses);
for m = 1:numPulses
    chi_m_trimmed{m} = chi_m{m}(zeroLagIdx(m):end);
end

chi_m_lengths = cellfun(@length, chi_m_trimmed);
maxLength = max(chi_m_lengths);

chi_m_vec = 1j*zeros(maxLength, numPulses);
for m = 1:numPulses
    chi_m_vec(1:chi_m_lengths(m), m) = chi_m_trimmed{m};
end

% Form RDMs ... I think we can just take the fft and get it to do the same
% thing but just implementing the formula as is for now
rdm = 1j*zeros(maxLength, numDopplerBins);
for l = 1:maxLength
%     for m = 1:numPulses
%         rdm(l, :) = rdm(l, :) + ...
%             exp(-1j*2*pi*p*pulseStartIdx(m)/Nint) * chi_m_vec(l, m);
%     end
    rdm(l, :) = sum(exp(-1j*2*pi*p'*pulseStartIdx/Nint) .* repmat(chi_m_vec(l, :), [length(p), 1]), 2);
end

return;
                     

    
    
    
    
    
    
    
    
    
    
    
    