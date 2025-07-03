function stab_bits = stability_params(frame, lsp, state)
    stab = struct();
    
    % 1. Phonetic class (2 bits)
    stab.phon_class = classify_signal(frame, state);
    
    % 2. Segment energy (12 bits)
    energy = 10*log10(mean(frame.^2) + eps);
    stab.energy = min(2^12-1, round((energy + 96) * 10));
    
    % 3. F0 stability (12 bits)
    if isfield(state, 'f0_est')
        stab.f0_stability = std(state.f0_est);
    else
        stab.f0_stability = 0;
    end
    
    % 4. LSP difference (9 bits)
    if isfield(state, 'prev_lsp') && ~isempty(state.prev_lsp)
        stab.lsp_diff = sum(abs(lsp - state.prev_lsp));
    else
        stab.lsp_diff = 0;
    end
    
    % 5. Energy gradient (10 bits)
    if isfield(state, 'prev_energy')
        stab.energy_grad = abs(energy - state.prev_energy);
    else
        stab.energy_grad = 0;
    end
    
    % 6. Correlation (10 bits)
    r = xcorr(frame, 'coeff');
    stab.corr = r(floor(length(r)/2) + 20);
    
    % 7-8. LF/HF energy (10+10 bits)
    [E_lf, E_hf] = energy_bands(frame);
    stab.E_lf = E_lf;
    stab.E_hf = E_hf;
    
    % 9. Transition flags (6 bits)
    stab.trans_flags = detect_transitions(frame, state);
    
    % 10. Reserved (24 bits)
    stab.reserved = 0;
    
    % Pack to bitstream
    stab_bits = [
        de2bi(stab.phon_class, 2, 'left-msb')
        de2bi(stab.energy, 12, 'left-msb')
        de2bi(round(stab.f0_stability*100), 12, 'left-msb')
        de2bi(round(stab.lsp_diff*1000), 9, 'left-msb')
        de2bi(round(stab.energy_grad*10), 10, 'left-msb')
        de2bi(round(stab.corr*1023), 10, 'left-msb')
        de2bi(round(stab.E_lf), 10, 'left-msb')
        de2bi(round(stab.E_hf), 10, 'left-msb')
        de2bi(stab.trans_flags, 6, 'left-msb')
        zeros(1,24) % reserved
    ];
end