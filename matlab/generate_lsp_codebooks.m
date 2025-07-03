function lsp_cb = generate_lsp_codebooks()
    lsp_cb = struct();
    lsp_cb.stage1 = design_biased_codebook(4, 200, 1000);   % 200-1000 Hz
    lsp_cb.stage2 = design_biased_codebook(4, 1000, 2500);  % 1000-2500 Hz
    lsp_cb.stage3 = design_biased_codebook(8, 2500, 4000);  % 2500-4000 Hz
end