function state = init_encoder_state()
    state = struct(...
        'exc_buffer', zeros(441,1),  % 147*3 samples
        'hpf_state', [0; 0],        % HPF filter state
        'preemph_state', 0,         % Preemphasis state
        'prev_frame', [],           % Previous audio frame
        'prev_lsp', [],             % Previous LSP
        'prev_energy', 0,           % Previous energy
        'f0_est', [],               % Pitch history
        'lsp_cb', generate_lsp_codebooks()...
    );
end