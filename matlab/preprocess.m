function [y, state] = preprocess(x, state)
    % High-pass filter (70 Hz Butterworth)
    [b, a] = butter(2, 70/(16000/2), 'high');
    
    % Initialize filter state if not exists
    if ~isfield(state, 'hpf_state')
        state.hpf_state = zeros(2,2);
    end
    
    [y, state.hpf_state] = filter(b, a, double(x), state.hpf_state);
    
    % Pre-emphasis H(z) = 1 - 0.7z⁻¹ (единый коэффициент)
    if ~isfield(state, 'preemph_state')
        state.preemph_state = 0;
    end
    
    % Slavic-optimized pre-emphasis
    for n = 1:length(y)
        s = y(n);
        y(n) = s - 0.7 * state.preemph_state;
        state.preemph_state = s;
    end
end