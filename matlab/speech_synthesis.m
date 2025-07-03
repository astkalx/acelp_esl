function synth_frame = speech_synthesis(exc, lpc_coeffs, state)
    synth_frame = filter(1, lpc_coeffs, exc);
    
    % Apply postfilter
    if isfield(state, 'postfilt_state')
        [synth_frame, state.postfilt_state] = ...
            filter(1, [1, -0.7], synth_frame, state.postfilt_state);
    else
        [synth_frame, state.postfilt_state] = ...
            filter(1, [1, -0.7], synth_frame);
    end
end