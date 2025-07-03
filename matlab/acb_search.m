function [acb_params, state] = acb_search(target, state)
    if isfield(state, 'phon_class') && state.phon_class == 1
        min_lag = 40; max_lag = 120; % For sonorants
    else
        min_lag = 20; max_lag = 147;
    end
    
    best_error = inf;
    best_lag = min_lag;
    best_gain = 0;
    
    for lag = min_lag:max_lag
        candidate = state.exc_buffer(end-lag+1:end-lag+length(target));
        gain = dot(target, candidate) / (dot(candidate, candidate) + eps);
        gain = max(0, min(gain, 2.0));
        
        error = sum((target - gain * candidate).^2);
        
        if error < best_error
            best_error = error;
            best_lag = lag;
            best_gain = gain;
        end
    end
    
    acb_params.lag = best_lag;
    acb_params.gain = best_gain;
    acb_params.lag_bits = de2bi(best_lag - 20, 9, 'left-msb');
    acb_params.gain_bits = de2bi(round(best_gain*32767), 16, 'left-msb');
    
    % Update excitation buffer
    exc_signal = best_gain * state.exc_buffer(end-best_lag+1:end-best_lag+length(target));
    state.exc_buffer = [state.exc_buffer(length(target)+1:end); exc_signal];
end