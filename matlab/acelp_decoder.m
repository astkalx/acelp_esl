function [output_frame, state] = acelp_decoder(bitstream, loss_flag, state)
    if nargin < 3 || isempty(state)
        state = init_decoder_state();
    end
    
    SUBFRAME_LEN = 160;
    ORDER = 16;
    
    if loss_flag == 0
        % Распаковка битового потока
        [params, state] = unpack_bitstream(bitstream, state);
        
        % Проверка преамбулы (M-последовательность)
        mseq_ref = [1,0,1,0,1,1,0,1,0,1,0,0,1,1,1,0,1,1,0,0,0,1,1,1,1,0,0,1,0,0,0,0]';
        if ~isequal(params.preamble, mseq_ref)
            loss_flag = 1;
        end
    end
    
    if loss_flag == 0
        % Преобразование LSP в LPC
        lpc_coeffs = lsp_to_lpc(params.quant_lsp);
        
        % Синтез речи
        synth_frame = [];
        for i = 1:3
            exc_signal = generate_excitation(params.acb(i), params.fcb(i), state);
            subframe = speech_synthesis(exc_signal, lpc_coeffs, state);
            synth_frame = [synth_frame; subframe];
            state.exc_buffer = [state.exc_buffer(SUBFRAME_LEN+1:end); exc_signal];
        end
        
        % Постобработка
        output_frame = postprocess(synth_frame, state);
        
        % Обновление состояния
        state.prev_lsp = params.quant_lsp;
        state.prev_params = params;
        state.prev_stab = params.stab;  % Сохранение параметров стабильности
        state.prev_frame = output_frame;
        state.loss_count = 0;
        
        % Адаптивный постфильтр для согласных
        phon_class = bi2de(params.stab.phon_class, 'left-msb');
        if phon_class == 1  % Согласные
            [output_frame, state.postfilt_state] = filter(...
                [1 -0.65], 1, output_frame, state.postfilt_state);
        end
    else
        % Сокрытие потерь пакетов
        state.loss_count = state.loss_count + 1;
        [output_frame, state] = plc_concealment(state);
        state.prev_frame = output_frame;
    end
end