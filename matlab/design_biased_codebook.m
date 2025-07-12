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
        idx = randi([0.5*n n], 1, 0.2*n);
        cb(idx,:) = rand(length(idx), dim) * (pi/2) + pi/4;
    end
end