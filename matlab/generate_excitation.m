function exc = generate_excitation(acb_params, fcb_params, state)
    subframe_len = 160;
    tracks = 5;
    pulses_per_track = 4;
    
    % 1. ACB-возбуждение (периодическая составляющая)
    lag = acb_params.lag;
    gain_p = acb_params.gain;
    
    % Проверка границ буфера
    start_idx = length(state.exc_buffer) - lag - subframe_len + 1;
    if start_idx < 1
        start_idx = 1;
    end
    acb_exc = gain_p * state.exc_buffer(start_idx:start_idx+subframe_len-1);
    
    % 2. FCB-возбуждение (шумовая составляющая)
    fcb_exc = zeros(subframe_len, 1);
    
    % Для славянских языков: усиление высоких частот шипящих согласных
    apply_hf_boost = false;
    if isfield(state, 'prev_stab') && ~isempty(state.prev_stab)
        phon_class = bi2de(state.prev_stab.phon_class, 'left-msb');
        apply_hf_boost = (phon_class == 1); % Только для согласных
    end
    
    % Генерация импульсов
    for t = 1:tracks
        for p = 1:pulses_per_track
            pos_base = (t-1)*32;
            idx = pos_base + fcb_params.positions(t, p);
            sign_val = 2*fcb_params.signs(t,p) - 1; % [0,1] -> [-1,1]
            pulse_val = sign_val * fcb_params.gains(t,p);
            
            % Применение импульса
            if idx <= subframe_len
                fcb_exc(idx) = fcb_exc(idx) + pulse_val;
            end
        end
    end
    
    % 3. Применение общего усиления FCB
    fcb_exc = fcb_exc * fcb_params.gain;
    
    % 4. Усиление ВЧ для шипящих согласных (оптимизация для славянских языков)
    if apply_hf_boost
        fcb_exc = filter([1 -0.3], 1, fcb_exc);
    end
    
    % 5. Комбинированное возбуждение
    exc = acb_exc + fcb_exc;
    
    % 6. Стабилизация энергии (предотвращение NaN)
    if all(exc == 0)
        exc = randn(subframe_len, 1) * 1e-6;
    end
end