function state = init_decoder_state()
    state = struct(...
        'exc_buffer', zeros(441,1),...  % Буфер возбуждения
        'deemph_state', 0,...          % Состояние деэмфаза
        'postfilt_state', 0,...        % Состояние постфильтра
        'prev_lsp', [],...             % Предыдущие LSP-коэффициенты
        'prev_params', [],...          % Параметры предыдущего кадра
        'prev_frame', [],...           % Предыдущий аудиокадр
        'loss_count', 0,...            % Счетчик потерь
        'lsp_cb', generate_lsp_codebooks(),... % Кодовая книга LSP
        'prev_stab', struct(...      % Параметры стабильности
            'phon_class', 0, ...    % Фонетический класс
            'energy', -40 ...       % Энергия сегмента
        ), ...
        'prev_f0_hist', 80,...         % История F0 (n-2)
        'prev_lsp_hist', [],...        % История LSP (n-2)
        'prev_energy_hist', -40 ...    % История энергии (n-2)
    );
    
    % Инициализация LSP средними значениями
    [~, state.prev_lsp] = lsp_unquantize(zeros(54,1), state);
    state.prev_lsp_hist = state.prev_lsp;
end