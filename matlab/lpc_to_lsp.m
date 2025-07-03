function lsp = lpc_to_lsp(a)
    order = length(a)-1;
    a = a(:)';
    
    P = [a, 0] + [0, fliplr(a)];
    Q = [a, 0] - [0, fliplr(a)];
    
    rP = roots(P); 
    rQ = roots(Q);
    
    anglesP = angle(rP(abs(abs(rP)-1) < 1e-5 & imag(rP) > 0));
    anglesQ = angle(rQ(abs(abs(rQ)-1) < 1e-5 & imag(rQ) > 0));
    
    lsp = sort([anglesP; anglesQ])' * (8000/pi);
end