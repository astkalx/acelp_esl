function [bitstream, state] = acelp_encoder(input_frame, state)
    % ACELP Encoder - 24 kbps
    if nargin < 2 || isempty(state)
        state = init_encoder_state();
    end
    
    FRAME_LEN = 480;
    SUBFRAME_LEN = 160;
    ORDER = 16;
    
    % Preprocessing
    [proc_frame, state] = preprocess(input_frame, state);
    
    % LPC Analysis
    [a, ~] = lpc_analysis(proc_frame, ORDER);
    
    % Convert to LSP and quantize
    lsp = lpc_to_lsp(a);
    [quant_lsp, lsp_bits] = lsp_quantize(lsp, state);
    
    % ACB and FCB search
    acb_params = [];
    fcb_params = [];
    for i = 1:3
        subframe = proc_frame((i-1)*SUBFRAME_LEN+1:i*SUBFRAME_LEN);
        [acb_params(i), state] = acb_search(subframe, state);
        [fcb_params(i), state] = fcb_search(subframe, acb_params(i), state);
    end
    
    % Stability parameters
    stab_bits = stability_params(proc_frame, quant_lsp, state);
    
    % Form bitstream
    bitstream = pack_bitstream(lsp_bits, acb_params, fcb_params, stab_bits);
    
    % Update state
    state.prev_frame = proc_frame;
    state.prev_lsp = quant_lsp;
    state.prev_energy = 10*log10(mean(proc_frame.^2) + eps);
    state.f0_est = [acb_params.lag];
end