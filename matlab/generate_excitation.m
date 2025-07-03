function exc = generate_excitation(acb_params, fcb_params, state)
    subframe_len = 160;
    tracks = 5;
    pulses_per_track = 4;
    
    % ACB excitation
    lag = acb_params.lag;
    gain_p = acb_params.gain;
    acb_exc = gain_p * state.exc_buffer(end-lag+1:end-lag+subframe_len);
    
    % FCB excitation
    fcb_exc = zeros(subframe_len, 1);
    positions = fcb_params.positions;
    signs = fcb_params.signs;
    gains = fcb_params.gains;
    
    for t = 1:tracks
        for p = 1:pulses_per_track
            pos_base = (t-1)*32;
            idx = pos_base + positions(t, p);
            sign_val = 2*signs(t,p) - 1;
            fcb_exc(idx) = fcb_exc(idx) + sign_val * gains(t,p);
        end
    end
    
    % Combined excitation
    exc = acb_exc + fcb_exc;
end