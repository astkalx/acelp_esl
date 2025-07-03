% Тест пустого кадра
zero_frame = int16(zeros(480,1));
[bitstream, enc_state] = acelp_encoder(zero_frame, enc_state);
output = acelp_decoder(bitstream, 0, dec_state);

% Тест тонального сигнала
t = 0:1/16000:0.03-1/16000;
sine_wave = int16(32767 * sin(2*pi*1000*t));
[bitstream, enc_state] = acelp_encoder(sine_wave', enc_state);
output = acelp_decoder(bitstream, 0, dec_state);