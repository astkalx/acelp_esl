function [quant_lsp, bits] = lsp_quantize(lsp, state, phon_class)
    % Базовые веса
    weights = ones(1,16);
    
    % Усиленное квантование для палатализованных согласных (2-4 кГц)
    if phon_class == 1 % Согласные
        weights(5:10) = 2.5; % Усиление для LSP5-LSP10 (2-4 кГц)
        weights(3:4) = 1.8;  % Дополнительное усиление для переходной области
    end
    
    % Кодовая книга LSP
    CB1 = state.lsp_cb.stage1;
    CB2 = state.lsp_cb.stage2;
    CB3 = state.lsp_cb.stage3;
    
    % Этап 1: Первые 4 LSP (взвешенное квантование)
    [idx1, quant1] = fast_weighted_vq(lsp(1:4)', CB1, weights(1:4));
    bits1 = de2bi(idx1-1, 18, 'left-msb');
    
    % Этап 2: Следующие 4 LSP
    [idx2, quant2] = fast_weighted_vq(lsp(5:8)', CB2, weights(5:8));
    bits2 = de2bi(idx2-1, 18, 'left-msb');
    
    % Этап 3: Последние 8 LSP
    [idx3, quant3] = fast_weighted_vq(lsp(9:16)', CB3, weights(9:16));
    bits3 = de2bi(idx3-1, 18, 'left-msb');
    
    quant_lsp = [quant1; quant2; quant3];
    bits = [bits1, bits2, bits3];
end

function [idx, quant] = fast_weighted_vq(vec, codebook, weights)
    % Предварительное вычисление квадратов весов
    weights = weights(:)';
    weighted_weights = weights .* weights;
    
    % Оптимизированный векторный расчет
    dist = sum(weighted_weights .* (codebook.^2), 2) - ...
           2 * (codebook * (vec .* weights)') + ...
           sum(weights .* (vec.^2));
    
    [~, idx] = min(dist);
    quant = codebook(idx, :)';
end