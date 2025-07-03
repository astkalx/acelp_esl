function [y, state] = preprocess(x, state)
    % High-pass filter (70 Hz Butterworth)
    [b, a] = butter(2, 70/(16000/2), 'high');
    [y, state.hpf_state] = filter(b, a, double(x), state.hpf_state);
    
    % Pre-emphasis H(z) = 1 - 0.68z⁻¹
    [y, state.preemph_state] = filter([1 -0.68], 1, y, state.preemph_state);
end