function [frame, state] = plc_concealment(state)
    SUBFRAME_LEN = 160;
    ORDER = 16;
    frame = zeros(480, 1);
    
    % 1. Классификация сигнала на основе параметров стабильности
    if isfield(state, 'prev_stab') && ~isempty(state.prev_stab)
        phon_class = bi2de(state.prev_stab.phon_class, 'left-msb');
    else
        phon_class = 0; % По умолчанию - гласный
    end
    
    % 2. Экстраполяция параметров (формулы 2.7-2.9)
    if isfield(state, 'prev_params') && ~isempty(state.prev_params)
        % Экстраполяция F0 (2.7)
        alpha = 0.65;
        if isfield(state, 'prev_f0_hist')
            f0 = alpha * state.prev_params.acb(1).lag + (1-alpha) * state.prev_f0_hist;
        else
            f0 = state.prev_params.acb(1).lag;
        end
        
        % Экстраполяция LSP (2.8)
        beta = 0.7;
        if isfield(state, 'prev_lsp_hist')
            lsp = beta * state.prev_lsp + (1-beta) * state.prev_lsp_hist;
        else
            lsp = state.prev_lsp;
        end
        
        % Экстраполяция энергии (2.9)
        gamma = 0.92;
        if isfield(state, 'prev_energy_hist')
            energy = gamma * state.prev_energy + (1-gamma) * state.prev_energy_hist;
        else
            energy = state.prev_energy;
        end
    else
        % Значения по умолчанию при отсутствии истории
        f0 = 80;
        lsp = lsp_unquantize(randi([0 2^54-1], 54), state);
        energy = -40;
    end
    
    % 3. Плавное затухание энергии (4.1-4.3)
    att_factor = 0.95^state.loss_count;
    energy = energy * att_factor;
    gain_p = min(1.2, 0.85^state.loss_count);
    gain_c = min(1.0, 0.92^state.loss_count);
    
    % 4. Стратегии восстановления (Таблица 4.1)
    for i = 1:3
        switch phon_class
            case 0 % Стабильные гласные
                % Периодическое возбуждение с замороженным ACB
                exc = gain_p * state.exc_buffer(end-f0+1:end-f0+SUBFRAME_LEN);
                
            case 1 % Нестабильные согласные
                % Шумовое возбуждение
                exc = randn(SUBFRAME_LEN, 1) * 0.2 * gain_c;
                
            case 2 % Транзиенты
                % Комбинированное возбуждение
                periodic = gain_p * state.exc_buffer(end-f0+1:end-f0+SUBFRAME_LEN);
                noise = randn(SUBFRAME_LEN, 1) * 0.1 * gain_c;
                exc = periodic + noise;
                
            case 3 % Паузы
                % Нулевое возбуждение
                exc = zeros(SUBFRAME_LEN, 1);
        end
        
        % 5. Синтез подкадра
        lpc_coeffs = lsp_to_lpc(lsp);
        subframe = speech_synthesis(exc, lpc_coeffs, state);
        
        % 6. Нормализация энергии
        current_energy = 10*log10(mean(subframe.^2) + eps);
        if current_energy > energy
            subframe = subframe * 10^((energy - current_energy)/20);
        end
        
        % 7. Сохранение в выходной кадр
        start_idx = (i-1)*SUBFRAME_LEN + 1;
        end_idx = i*SUBFRAME_LEN;
        frame(start_idx:end_idx) = subframe;
        
        % 8. Обновление буфера возбуждения
        state.exc_buffer = [state.exc_buffer(SUBFRAME_LEN+1:end); exc];
    end
    
    % 9. Обновление истории параметров
    state.prev_f0_hist = state.prev_params.acb(1).lag;
    state.prev_lsp_hist = state.prev_lsp;
    state.prev_energy_hist = state.prev_energy;
end