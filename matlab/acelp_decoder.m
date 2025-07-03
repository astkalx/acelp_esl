function [output_frame, state] = acelp_decoder(bitstream, loss_flag, state)
    if nargin < 3 || isempty(state)
        state = init_decoder_state();
    end
    
    SUBFRAME_LEN = 160;
    ORDER = 16;
    
    if loss_flag == 0
        % Unpack bitstream
        [params, state] = unpack_bitstream(bitstream, state);
        
        % LSP to LPC conversion
        lpc_coeffs = lsp_to_lpc(params.quant_lsp);
        
        % Synthesize speech
        synth_frame = [];
        for i = 1:3
            exc_signal = generate_excitation(params.acb(i), params.fcb(i), state);
            subframe = speech_synthesis(exc_signal, lpc_coeffs, state);
            synth_frame = [synth_frame; subframe];
            state.exc_buffer = [state.exc_buffer(SUBFRAME_LEN+1:end); exc_signal];
        end
        
        % Post-processing
        output_frame = postprocess(synth_frame, state);
        
        % Update state
        state.prev_lsp = params.quant_lsp;
        state.prev_params = params;
        state.prev_frame = output_frame;
        state.loss_count = 0;
    else
        % Packet Loss Concealment
        state.loss_count = state.loss_count + 1;
        output_frame = plc_concealment(state);
        state.prev_frame = output_frame;
    end
end