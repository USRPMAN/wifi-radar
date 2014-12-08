function s_eca = eca_b(s_surv, s_ref, b, R, K, numDopplerBins)

% This function implements the cancellation filter described in
% 
% http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=5089551

% b - number of batches
% R - extra samples at the beginning of s_ref -- nominally 80 for
% wifidata.mat (80 samples per OFDM pulse or 4us), so there is 1 extra
% pulse transmitted
% K - assume clutter / multipath comes from first K range bins
% numDopplerBins - number of Doppler bins to cancel

% Hopefully this is an integer ... no error checking for now
Nb = length(s_surv) / b; % samples per batch
s_eca = 1j * zeros(Nb, b);

% Both of these matrices are way too big. Need to find a better way to do
% this

% Construct matrix "B" -- incidence matrix
% B = zeros(Nb, Nb + R - 1);
j = 1:(Nb + R - 1);
i = j - R + 1;
j = j(i > 0);
i = i(i > 0);
% idx = sub2idx([Nb, Nb + R - 1], i, j);
% B(idx) = 1;
B = sparse(i, j, ones(length(i), 1), Nb, Nb + R - 1);

% Construct matrix "D" -- delay / permutation matrix
% D = zeros(Nb + R - 1, Nb + R - 1);
j = 1:Nb + R - 1;
i = j + 1;
j = j(i <= Nb + R - 1);
i = i(i <= Nb + R - 1);
% idx = sub2idx([Nb + R - 1, Nb + R - 1], i, j);
% D(idx) = 1;
D = sparse(i, j, ones(length(i), 1), Nb + R - 1, Nb + R - 1);

% % Construct each Lambda matrix over each Doppler bin
% p = -numDopplerBins/2:numDopplerBins/2-1;
% Lambda_p = 1j*zeros([Nb + R - 1, Nb + R - 1, numDopplerBins]);
% for d = 1:length(p)
%     Lambda_p_vec = exp(1j*2*pi*p(d)*(0:Nb + R - 1));
%     Lambda_p(:, :, d) = diag(Lambda_p_vec);
% end    

p = -numDopplerBins:numDopplerBins;
S_ref = 1j*zeros(Nb + R - 1, K);

for ii = 0:(b-1)
    s_surv_i = s_surv((ii*Nb + 1):((ii+1)*Nb));
    s_ref_i = s_ref((ii*Nb + 1):((ii+1)*Nb + R - 1));
    
    % Construct matrix S_ref ..
    S_ref(:, 1) = s_ref_i;
    for kk = 2:K
        S_ref(:, kk) = D^(kk-1) * s_ref_i;
    end
    
    temp = 1j * zeros([Nb + R - 1, (numDopplerBins*2 + 1)*K]);
    % Finally make X(i) matrix
    for d = 1:length(p)
        Lambda_p_vec = exp(1j*2*pi*p(d)*(0:Nb + R - 2));
        Lambda_p = sparse(1:(Nb + R - 1), 1:(Nb + R - 1), Lambda_p_vec);
        temp(:, (d-1)*K + 1:(d*K)) = Lambda_p * S_ref;
    end
        
    X = B * temp;
    alpha = (X'*X)^-1 * X' * s_surv_i;
    
    s_eca(:, ii+1) = s_surv_i  - X*alpha;
end

s_eca = reshape(s_eca, [Nb * b, 1]);
    
return;
    
    
    
    
    
    
    
    
    
    
    
    
    