function [y, state] = postprocess(x, state)
    % Deemphasis: H_inv(z) = 1 / (1 - 0.7*z^-1)
    if ~isfield(state, 'deemph_state')
        state.deemph_state = 0;
    end
    
    y = zeros(size(x));
    for n = 1:length(x)
        y(n) = x(n) + 0.7 * state.deemph_state;
        state.deemph_state = y(n);
    end
    
    % Slavic-specific energy normalization
    max_val = max(abs(y));
    if max_val > 0
        y = y / max_val * 0.98;  % Prevent clipping
    end
end