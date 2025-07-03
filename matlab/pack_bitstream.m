function bitstream = pack_bitstream(lsp_bits, acb_params, fcb_params, stab_bits)
    bitstream = zeros(1, 720, 'uint8');
    pos = 1;
    
    % LSP (54 bits)
    bitstream(pos:pos+53) = lsp_bits;
    pos = pos + 54;
    
    % ACB parameters (3 subframes × 25 bits)
    for i = 1:3
        bitstream(pos:pos+8) = acb_params(i).lag_bits; % 9 bits
        pos = pos + 9;
        bitstream(pos:pos+15) = acb_params(i).gain_bits; % 16 bits
        pos = pos + 16;
    end
    
    % FCB parameters (3 subframes × 158 bits)
    for i = 1:3
        bitstream(pos:pos+157) = fcb_params(i).bits;
        pos = pos + 158;
    end
    
    % Stability parameters (105 bits)
    bitstream(pos:pos+104) = stab_bits;
end