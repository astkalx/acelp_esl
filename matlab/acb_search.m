function [bitstream, state] = acelp_encoder(input_frame, state)
    % ACELP Encoder - 25.6 kbps (оптимизирован для восточнославянских языков)
    if nargin < 2 || isempty(state)
        state = init_encoder_state();
    end
    
    FRAME_LEN = 480;
    SUBFRAME_LEN = 160;
    ORDER = 16;
    MAX_LAG = 147;  % Максимальное значение pitch lag
    
    % Предобработка с единым коэффициентом 0.7
    [proc_frame, state] = preprocess(input_frame, state);
    
    % LPC анализ
    [a, ~] = lpc_analysis(proc_frame, ORDER);
    
    % Защита от некорректных коэффициентов
    if any(isnan(a)) || any(isinf(a))
        a = [1, zeros(1, ORDER)];  % Импульсный отклик
    end
    
    % Преобразование в LSP и квантование
    lsp = lpc_to_lsp(a);
    
    % Классификация сигнала для адаптивного квантования
    phon_class = classify_signal(proc_frame, state);
    
    % Адаптивное квантование LSP
    [quant_lsp, lsp_bits] = lsp_quantize(lsp, state, phon_class);
    
    % Поиск параметров ACB и FCB
    acb_params = struct('lag', {}, 'gain', {}, 'lag_bits', {}, 'gain_bits', {}); % Инициализация структуры
    fcb_params = struct('bits', {}, 'positions', {}, 'signs', {}, 'gains', {}, 'gain_bits', {});
    
    for i = 1:3
        subframe = proc_frame((i-1)*SUBFRAME_LEN+1:i*SUBFRAME_LEN);
        
        % Гарантия достаточного размера буфера
        min_required = MAX_LAG + length(subframe);
        if length(state.exc_buffer) < min_required
            padding = zeros(min_required - length(state.exc_buffer), 1);
            state.exc_buffer = [padding; state.exc_buffer];
        end

        [acb_params(i), state] = acb_search(subframe, state);
        [fcb_params(i), state] = fcb_search(subframe, acb_params(i), state);
        
        % Генерация полного возбуждения (ACB + FCB)
        exc = generate_excitation(acb_params(i), fcb_params(i), state);
        
        % Обновление буфера (после FCB!)
        state.exc_buffer = [state.exc_buffer(SUBFRAME_LEN+1:end); exc];
        
        % Квантование усиления FCB (12 бит на подкадр)
        energy = norm(subframe);
        gain_db = 20*log10(energy + eps);
        
        % Базовое усиление: 8 бит (-12..+24 дБ)
        base_gain = min(24, max(-12, gain_db));
        base_idx = floor((base_gain + 12) * (255/36)); % 256 уровней
        base_idx = min(max(base_idx, 0), 255);
        
        % Коррекция усиления: 4 бита (±0.5 дБ)
        residual = gain_db - (-12 + base_idx*(36/255));
        corr_idx = floor((residual + 0.5) * 8); % 16 уровней
        corr_idx = min(max(corr_idx, 0), 15);
        
        fcb_params(i).gain_bits = [...
            de2bi(base_idx, 8, 'left-msb'), ...
            de2bi(corr_idx, 4, 'left-msb')];
    end
    
    % Параметры стабильности
    stab_bits = stability_params(proc_frame, quant_lsp, state);
    
    % Формирование битового потока
    bitstream = pack_bitstream(lsp_bits, acb_params, fcb_params, stab_bits);
    
    % Обновление состояния
    state.prev_frame = proc_frame;
    state.prev_lsp = quant_lsp;
    state.prev_energy = 10*log10(mean(proc_frame.^2) + eps);
    state.f0_est = [acb_params.lag];
    
    % Специфическая оптимизация: обновление кодовой книги LSP
    if mod(state.frame_count, 50) == 0
        state.lsp_cb = generate_lsp_codebooks();
    end
    state.frame_count = state.frame_count + 1;
    
    % Сохранение класса для PLC
    state.prev_phon_class = phon_class;
end