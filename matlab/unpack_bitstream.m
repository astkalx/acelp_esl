function [params, state] = unpack_bitstream(bitstream, state)
    params = struct();
    ptr = 1;
    
    % 1. Проверка преамбулы (M-последовательность)
    mseq_ref = [1,0,1,0,1,1,0,1,0,1,0,0,1,1,1,0,1,1,0,0,0,1,1,1,1,0,0,1,0,0,0,0]';
    preamble = bitstream(ptr:ptr+31);
    params.preamble_match = isequal(preamble, mseq_ref);
    ptr = ptr + 32;
    
    % 2. LSP параметры (54 бита)
    params.lsp_bits = bitstream(ptr:ptr+53);
    ptr = ptr + 54;
    
    % 3. ACB параметры (3 подкадра)
    for i = 1:3
        % Запаздывание (9 бит)
        acb.lag_bits = bitstream(ptr:ptr+8);
        acb.lag = bi2de(acb.lag_bits', 'left-msb') + 20; % Диапазон 20-147
        ptr = ptr + 9;
        
        % Усиление (16 бит)
        acb.gain_bits = bitstream(ptr:ptr+15);
        acb.gain = double(bi2de(acb.gain_bits', 'left-msb')) / 32767; % Q15 формат
        ptr = ptr + 16;
        
        params.acb(i) = acb;
    end
    
    % 4. FCB параметры (3 подкадра)
    for i = 1:3
        % Индексы импульсов (158 бит)
        fcb.bits = bitstream(ptr:ptr+157);
        ptr = ptr + 158;
        
        % Усиление (12 бит)
        fcb.gain_bits = bitstream(ptr:ptr+11);
        fcb.gain_base = bi2de(fcb.gain_bits(1:8)', 'left-msb');
        fcb.gain_corr = bi2de(fcb.gain_bits(9:12)', 'left-msb');
        fcb.gain = 10^((fcb.gain_base - 128)/20) * (1 + (fcb.gain_corr-7.5)/40); % ДБ->линейный
        ptr = ptr + 12;
        
        params.fcb(i) = fcb;
    end
    
    % 5. Параметры стабильности (81 бит)
    stab_fields = {'phon_class','energy','f0_stability','lsp_diff',...
                  'energy_grad','corr','E_lf','E_hf','trans_flags','reserved'};
    stab_sizes = [2,12,12,9,10,10,10,10,6,24]; % Бит на параметр
    
    for i = 1:length(stab_fields)
        bits = bitstream(ptr:ptr+stab_sizes(i)-1);
        params.stab.(stab_fields{i}) = bits;
        ptr = ptr + stab_sizes(i);
    end
    
    % 6. Резервные биты (16 бит)
    params.reserved = bitstream(ptr:end);
    
    % Декодирование LSP
    [params.quant_lsp, state] = lsp_unquantize(params.lsp_bits, state);
end