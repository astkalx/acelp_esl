% Инициализация состояний
enc_state = init_encoder_state();
dec_state = init_decoder_state();

% Чтение аудиофайла (16 кГц, 16-bit PCM)
[audio, fs] = audioread('speech.wav');
if fs ~= 16000
    audio = resample(audio, 16000, fs);
end
audio = int16(audio * 32767);

% Обработка по кадрам
output = [];
frame_len = 480;
for i = 1:floor(length(audio)/frame_len)
    frame = audio((i-1)*frame_len+1 : i*frame_len);
    
    % Кодирование
    [bitstream, enc_state] = acelp_encoder(frame, enc_state);
    
    % Декодирование (с 10% вероятностью потери)
    loss_flag = rand < 0.1;
    [dec_frame, dec_state] = acelp_decoder(bitstream, loss_flag, dec_state);
    
    output = [output; dec_frame];
end

% Сохранение результата
audiowrite('decoded.wav', double(output)/32768, 16000);