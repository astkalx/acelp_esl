function phon_class = classify_signal(frame, state)
    energy = 10*log10(mean(frame.^2) + eps);
    [E_lf, E_hf] = energy_bands(frame);
    
    if energy < 20 % Silence threshold
        phon_class = 3; % Pause
    elseif E_hf > E_lf + 5 % Slavic consonants
        phon_class = 1; % Consonant
    elseif isfield(state, 'f0_est') && std(state.f0_est) < 5
        phon_class = 0; % Vowel
    else
        phon_class = 2; % Transition
    end
end