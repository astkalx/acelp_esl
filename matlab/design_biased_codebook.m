function cb = design_biased_codebook(dim, fmin, fmax)
    n = 2^18; % 262144 entries
    cb = zeros(n, dim);
    freq_range = fmax - fmin;
    
    % Усиленная плотность в целевом диапазоне
    for i = 1:n
        % 70% точек в целевом диапазоне
        if i < 0.7*n
            f = rand(1,dim) * freq_range + fmin;
        % 30% точек в полном диапазоне
        else
            f = rand(1,dim) * 4000;
        end
        
        % Сортировка и преобразование в угловые частоты
        cb(i,:) = sort(f * (pi/4000));
    end
    
    % Дополнительная оптимизация для палатализованных звуков
    if fmin > 1000 && fmax > 2500
        % Увеличение плотности для LSP5-LSP10
        start_idx = floor(0.5*n);  % Округление до целого
        num_points = floor(0.2*n); % Округление до целого
        idx = randi([start_idx n], 1, num_points);
        cb(idx,:) = rand(length(idx), dim) * (pi/2) + pi/4;
    end
end