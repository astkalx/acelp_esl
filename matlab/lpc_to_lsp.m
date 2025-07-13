function lsp = lpc_to_lsp(a)
    % Проверка на NaN/Inf
    if any(isnan(a)) || any(isinf(a))
        % Возврат безопасных значений по умолчанию
        lsp = linspace(0.05, 0.95, 16) * 4000;  % Равномерные LSP
        return;
    end
    
    order = length(a)-1;
    a = a(:)';
    
    P = [a, 0] + [0, fliplr(a)];
    Q = [a, 0] - [0, fliplr(a)];
    
    % Дополнительная проверка полиномов
    if any(isnan(P)) || any(isinf(P)) || any(isnan(Q)) || any(isinf(Q))
        lsp = linspace(0.05, 0.95, 16) * 4000;
        return;
    end
    
    rP = roots(P); 
    rQ = roots(Q);
    
    anglesP = angle(rP(abs(abs(rP)-1) < 1e-5 & imag(rP) > 0));
    anglesQ = angle(rQ(abs(abs(rQ)-1) < 1e-5 & imag(rQ) > 0));
    
    % Проверка количества найденных корней
    if length(anglesP) + length(anglesQ) < 16
        missing = 16 - (length(anglesP) + length(anglesQ));
        default_angles = linspace(0.1, 0.9, missing) * pi;
        all_angles = [anglesP; anglesQ; default_angles(:)];
    else
        all_angles = [anglesP; anglesQ];
    end
    
    lsp = sort(all_angles)' * (8000/pi);
end