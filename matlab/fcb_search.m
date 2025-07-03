function [fcb_params, state] = fcb_search(target, acb_params, state)
    subframe_len = length(target);
    tracks = 5;
    pulses_per_track = 4;
    
    % Generate candidate excitation
    candidate = zeros(subframe_len, 1);
    positions = randi([1, 32], tracks, pulses_per_track);
    signs = randi([0, 1], tracks, pulses_per_track);
    gains = rand(tracks, pulses_per_track) * 2 - 1; % -1 to 1
    
    for t = 1:tracks
        for p = 1:pulses_per_track
            pos_base = (t-1)*32;
            idx = pos_base + positions(t, p);
            candidate(idx) = candidate(idx) + (2*signs(t,p)-1) * gains(t,p);
        end
    end
    
    % Simple VQ simulation (158 bits)
    fcb_params.bits = randi([0 1], 1, 158);
    
    % Store parameters for decoding
    fcb_params.positions = positions;
    fcb_params.signs = signs;
    fcb_params.gains = gains;
end