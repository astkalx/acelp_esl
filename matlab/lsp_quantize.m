function [quant_lsp, bits] = lsp_quantize(lsp, state)
    weights = ones(1,16);
    weights(5:10) = 2.0; % Enhanced quantization for 2-4 kHz
    
    CB1 = state.lsp_cb.stage1;
    CB2 = state.lsp_cb.stage2;
    CB3 = state.lsp_cb.stage3;
    
    % Stage 1: First 4 LSPs (weighted)
    [idx1, quant1] = weighted_vq(lsp(1:4)', CB1, weights(1:4));
    bits1 = de2bi(idx1-1, 18, 'left-msb');
    
    % Stage 2: Next 4 LSPs
    [idx2, quant2] = weighted_vq(lsp(5:8)', CB2, weights(5:8));
    bits2 = de2bi(idx2-1, 18, 'left-msb');
    
    % Stage 3: Last 8 LSPs
    [idx3, quant3] = weighted_vq(lsp(9:16)', CB3, weights(9:16));
    bits3 = de2bi(idx3-1, 18, 'left-msb');
    
    quant_lsp = [quant1; quant2; quant3];
    bits = [bits1, bits2, bits3];
end

function [idx, quant] = weighted_vq(vec, codebook, weights)
    dist = sum((codebook - vec) .^ 2 .* weights, 2);
    [~, idx] = min(dist);
    quant = codebook(idx, :)';
end