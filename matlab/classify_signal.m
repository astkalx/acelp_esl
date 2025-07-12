function phon_class = classify_signal(frame, state)
    energy = 10*log10(mean(frame.^2) + eps);

    % Детектирование палатализации
    [E_lf, E_hf] = energy_bands(frame);
    hf_ratio = E_hf - E_lf;
    
    % Расчет стабильности F0
    if isfield(state, 'f0_est') && numel(state.f0_est) >= 3
        f0_stability = std(state.f0_est);
    else
        f0_stability = 10; % Значение по умолчанию
    end
    
    % Расширенная классификация для славянских языков
    if energy < 20
        phon_class = 3; % Пауза
    elseif hf_ratio > 10 % Сильный ВЧ-компонент
        phon_class = 1; % Палатализованный согласный
    elseif hf_ratio > 5
        phon_class = 1; % Обычный согласный
    elseif f0_stability < 5
        phon_class = 0; % Гласный
    else
        phon_class = 2; % Транзиент
    end
end