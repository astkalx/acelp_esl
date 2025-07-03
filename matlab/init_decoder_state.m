function state = init_decoder_state()
    state = struct(...
        'exc_buffer', zeros(441,1),  % Excitation buffer
        'deemph_state', 0,          % Deemphasis state
        'postfilt_state', [],       % Postfilter state
        'prev_lsp', [],             % Previous LSP
        'prev_params', [],          % Previous parameters
        'prev_frame', [],           % Previous audio frame
        'loss_count', 0,            % Consecutive loss counter
        'lsp_cb', generate_lsp_codebooks()...
    );
end