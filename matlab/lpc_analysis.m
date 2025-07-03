function [a, R] = lpc_analysis(s, order)
    win = hamming(length(s));
    s_windowed = s .* win;
    
    R = zeros(order+1, 1);
    for k = 0:order
        R(k+1) = dot(s_windowed(1:end-k), s_windowed(1+k:end));
    end
    
    a = levinson(R, order);
end

function a = levinson(R, p)
    a = zeros(1, p);
    E = R(1);
    
    for i = 1:p
        k = R(i+1);
        for j = 1:i-1
            k = k - a(j) * R(i-j+1);
        end
        k = k / E;
        
        a(i) = k;
        for j = 1:floor((i-1)/2)
            aj = a(j);
            a(j) = aj - k * a(i-j);
            a(i-j) = a(i-j) - k * aj;
        end
        
        if mod(i, 2) == 0
            a(i/2) = a(i/2) * (1 - k);
        end
        
        E = (1 - k^2) * E;
    end
    a = [1, -a];
end