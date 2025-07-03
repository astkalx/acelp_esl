function y = postprocess(x, state)
    % Deemphasis: H_inv(z) = 1 / (1 - 0.68*z^-1)
    if isfield(state, 'deemph_state')
        [y, state.deemph_state] = ...
            filter(1, [1, -0.68], x, state.deemph_state);
    else
        [y, state.deemph_state] = ...
            filter(1, [1, -0.68], x);
    end
    
    % Clipping to int16 range
    y = int16(max(min(y, 32767), -32768));
end