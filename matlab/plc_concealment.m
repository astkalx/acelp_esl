function frame = plc_concealment(state)
    SUBFRAME_LEN = 160;
    frame = zeros(480, 1);
    
    % Signal classification
    if isfield(state, 'prev_params')
        signal_type = classify_signal(state.prev_params);
    else
        signal_type = 'vowel';
    end
    
    % Generate excitation based on signal type
    for i = 1:3
        switch signal_type
            case 'vowel'
                exc = generate_vowel_excitation(state);
            case 'consonant'
                exc = generate_noise_excitation(state);
            otherwise
                exc = generate_combined_excitation(state);
        end
        
        % Apply energy attenuation
        attenuation = 1.0;
        for k = 1:state.loss_count
            attenuation = attenuation * 0.95; % Eq 4.3
        end
        exc = exc * attenuation;
        
        % Synthesize subframe
        start_idx = (i-1)*SUBFRAME_LEN + 1;
        end_idx = i*SUBFRAME_LEN;
        subframe = speech_synthesis(exc, state.prev_lpc, state);
        frame(start_idx:end_idx) = subframe;
        
        % Update excitation buffer
        state.exc_buffer = [state.exc_buffer(SUBFRAME_LEN+1:end); exc];
    end
end

function exc = generate_vowel_excitation(state)
    % Use periodic excitation from ACB
    lag = state.prev_params.acb(1).lag;
    gain_p = state.prev_params.acb(1).gain;
    exc = gain_p * state.exc_buffer(end-lag+1:end-lag+160);
end

function exc = generate_noise_excitation(state)
    % White noise excitation
    exc = randn(160, 1) * 0.1;
end

function exc = generate_combined_excitation(state)
    % Mix of periodic and noise
    lag = state.prev_params.acb(1).lag;
    gain_p = state.prev_params.acb(1).gain;
    periodic = gain_p * state.exc_buffer(end-lag+1:end-lag+160);
    noise = randn(160, 1) * 0.05;
    exc = periodic + noise;
end