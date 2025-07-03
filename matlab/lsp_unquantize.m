function [quant_lsp, state] = lsp_unquantize(bits, state)
    stage1_bits = bits(1:18);
    stage2_bits = bits(19:36);
    stage3_bits = bits(37:54);
    
    idx1 = bi2de(stage1_bits, 'left-msb') + 1;
    idx2 = bi2de(stage2_bits, 'left-msb') + 1;
    idx3 = bi2de(stage3_bits, 'left-msb') + 1;
    
    quant1 = state.lsp_cb.stage1(idx1, :);
    quant2 = state.lsp_cb.stage2(idx2, :);
    quant3 = state.lsp_cb.stage3(idx3, :);
    
    quant_lsp = [quant1, quant2, quant3]';
end