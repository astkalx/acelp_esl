function [E_lf, E_hf] = energy_bands(frame)
    n = length(frame);
    w = hamming(n);
    F = fft(frame .* w);
    freqs = (0:n-1)*(16000/n);
    
    % LF energy (50-500 Hz)
    idx_lf = find(freqs >= 50 & freqs <= 500);
    E_lf = sum(abs(F(idx_lf)).^2) / n;
    
    % HF energy (3000-7000 Hz)
    idx_hf = find(freqs >= 3000 & freqs <= 7000);
    E_hf = sum(abs(F(idx_hf)).^2) / n;
    
    % Convert to dB
    E_lf = 10*log10(E_lf + eps);
    E_hf = 10*log10(E_hf + eps);
end