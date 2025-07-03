function flags = detect_transitions(frame, state)
    energy = 10*log10(mean(frame.^2) + eps);
    flags = 0;
    
    if isfield(state, 'prev_energy')
        if energy > state.prev_energy + 10
            flags = bitor(flags, 1); % Onset flag
        elseif energy < state.prev_energy - 15
            flags = bitor(flags, 2); % Offset flag
        end
        
        % Slavic-specific: detect palatalization
        [~, E_hf] = energy_bands(frame);
        if E_hf > 30 % High-frequency energy threshold
            flags = bitor(flags, 4);
        end
    end
end