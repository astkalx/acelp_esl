function bitstream = pack_bitstream(lsp_bits, acb_params, fcb_params, stab_bits)
    % Формирование полного кадра 768 бит
    bitstream = zeros(768, 1, 'uint8');
    ptr = 1;
    
    % 1. Преамбула (M-последовательность 32 бита)
    mseq = [1,0,1,0,1,1,0,1,0,1,0,0,1,1,1,0,1,1,0,0,0,1,1,1,1,0,0,1,0,0,0,0]';
    bitstream(ptr:ptr+31) = mseq;
    ptr = ptr + 32;
    
    % 2. LSP параметры (54 бита)
    bitstream(ptr:ptr+53) = lsp_bits(:);
    ptr = ptr + 54;
    
    % 3. ACB параметры (3 подкадра × 25 бит)
    for i = 1:3
        % Запаздывание (9 бит)
        bitstream(ptr:ptr+8) = acb_params(i).lag_bits(:);
        ptr = ptr + 9;
        
        % Усиление (16 бит)
        bitstream(ptr:ptr+15) = acb_params(i).gain_bits(:);
        ptr = ptr + 16;
    end
    
    % 4. FCB параметры (3 подкадра × 170 бит)
    for i = 1:3
        % Индексы импульсов (158 бит)
        bitstream(ptr:ptr+157) = fcb_params(i).bits(:);
        ptr = ptr + 158;
        
        % Усиление (12 бит)
        bitstream(ptr:ptr+11) = fcb_params(i).gain_bits(:);
        ptr = ptr + 12;
    end
    
    % 5. Параметры стабильности (81 бит)
    bitstream(ptr:ptr+80) = stab_bits(:);
    ptr = ptr + 81;
    
    % 6. Резервные биты (16 бит)
    bitstream(ptr:end) = 0; % Все биты = 0
end