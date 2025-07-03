% Имитация серии потерь
for i = 1:10
    if i > 5 && i < 8
        loss_flag = 1; % Потеря кадров 6-7
    else
        loss_flag = 0;
    end
    output_frame = acelp_decoder(bitstream, loss_flag, dec_state);
end