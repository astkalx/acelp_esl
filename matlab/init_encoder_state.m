function state = init_encoder_state()
    state = struct(...
        'exc_buffer', zeros(441,1),  % Буфер возбуждения (147*3)
        'hpf_state', [0; 0],        % Состояние ФВЧ-фильтра (70 Гц)
        'preemph_state', 0,         % Состояние предэмфаза (H(z) = 1 - 0.7z⁻¹)
        'prev_frame', [],           % Предыдущий аудиокадр
        'prev_lsp', [],             % Предыдущие LSP-коэффициенты
        'prev_energy', 0,           % Предыдущая энергия кадра
        'f0_est', 80,               % История оценки F0 (начальное значение 80)
        'lsp_cb', generate_lsp_codebooks(), % Кодовая книга LSP
        'frame_count', 0,           % Счетчик кадров
        'prev_stab', struct(...      % Параметры стабильности предыдущего кадра
            'phon_class', 0, ...    % Фонетический класс
            'energy', -40, ...      % Энергия сегмента
            'f0_stability', 0, ...  % Стабильность F0
            'lsp_diff', 0 ...       % Разность LSP
        ) ...
    );
end