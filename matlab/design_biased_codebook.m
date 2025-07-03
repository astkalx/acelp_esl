function cb = design_biased_codebook(dim, fmin, fmax)
    n = 2^18; % 262144 entries
    cb = zeros(n, dim);
    freq_range = fmax - fmin;
    
    for i = 1:n
        % 60% points in target range
        if i < 0.6*n
            f = rand(1,dim) * freq_range + fmin;
        % 40% points in full range
        else
            f = rand(1,dim) * 4000;
        end
        
        % Convert to angular frequencies [0, π]
        cb(i,:) = sort(f * (pi/4000));
    end
end