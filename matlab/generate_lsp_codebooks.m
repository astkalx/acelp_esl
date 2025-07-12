function lsp_cb = generate_lsp_codebooks()
    % Биазированные кодвые книги для славянских языков
    lsp_cb = struct();
    
    % Усиленная точность в диапазоне 2-4 кГц
    lsp_cb.stage1 = design_biased_codebook(4, 200, 1000);   % 200-1000 Гц
    lsp_cb.stage2 = design_biased_codebook(4, 1000, 4000);  % 1000-4000 Гц (акцент)
    lsp_cb.stage3 = design_biased_codebook(8, 2500, 4000);  % 2500-4000 Гц
end