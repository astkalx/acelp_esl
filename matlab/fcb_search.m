function [fcb_params, state] = fcb_search(target, acb_params, state)
    subframe_len = 160;
    tracks = 5;
    pulses_per_track = 4;
    
    % 1. Инициализация FCB-структуры
    fcb_params = struct();
    positions = zeros(tracks, pulses_per_track);
    signs = zeros(tracks, pulses_per_track);
    gains = zeros(tracks, pulses_per_track);
    
    % 2. Поиск импульсов по трекам
    residual = target;  % Начинаем с оригинального целевого сигнала
    for t = 1:tracks
        for p = 1:pulses_per_track
            % Поиск лучшей позиции в треке
            best_error = inf;
            best_pos = 1;
            best_sign = 0;
            best_gain = 0;
            
            % Перебор всех позиций в треке
            for pos = 1:32
                idx = (t-1)*32 + pos;
                if idx > subframe_len, continue; end
                
                % Тестовый импульс с положительной полярностью
                test_pulse = zeros(subframe_len, 1);
                test_pulse(idx) = 1;
                
                % Расчет усиления и ошибки
                gain_pos = dot(residual, test_pulse) / (dot(test_pulse, test_pulse) + eps;
                error_pos = sum((residual - gain_pos * test_pulse).^2);
                
                % Тестовый импульс с отрицательной полярностью
                test_pulse(idx) = -1;
                gain_neg = dot(residual, test_pulse) / (dot(test_pulse, test_pulse) + eps;
                error_neg = sum((residual - gain_neg * test_pulse).^2);
                
                % Выбор лучшего варианта
                if error_pos < best_error
                    best_error = error_pos;
                    best_pos = pos;
                    best_sign = 1;
                    best_gain = gain_pos;
                end
                
                if error_neg < best_error
                    best_error = error_neg;
                    best_pos = pos;
                    best_sign = -1;
                    best_gain = gain_neg;
                end
            end
            
            % Сохранение параметров импульса
            positions(t, p) = best_pos;
            signs(t, p) = (best_sign > 0); % 1=+, 0=-
            gains(t, p) = best_gain;
            
            % Обновление остатка
            pulse_signal = zeros(subframe_len, 1);
            idx = (t-1)*32 + best_pos;
            pulse_signal(idx) = best_sign * best_gain;
            residual = residual - pulse_signal;
        end
    end
    
    % 3. Векторное квантование (180 бит → 158 бит)
    fcb_params.bits = vq_encode_fcb(positions, signs, gains);
    
    % 4. Сохранение параметров для декодирования
    fcb_params.positions = positions;
    fcb_params.signs = signs;
    fcb_params.gains = gains;
end

function bits = vq_encode_fcb(positions, signs, gains)
    % Простая реализация упаковки параметров FCB
    bits = [];
    
    for t = 1:5
        % Позиции: 5 бит × 4 импульса = 20 бит/трек
        for p = 1:4
            bits = [bits, de2bi(positions(t, p)-1, 5, 'left-msb')];
        end
        
        % Знаки: 1 бит × 4 импульса = 4 бит/трек
        for p = 1:4
            bits = [bits, signs(t, p)];
        end
        
        % Усиления: 3 бит × 4 импульса = 12 бит/трек (квантование до 8 уровней)
        for p = 1:4
            gain_idx = min(7, floor(gains(t, p) * 4)); % 0-7
            bits = [bits, de2bi(gain_idx, 3, 'left-msb')];
        end
    end
    
    % Всего 5 × (20+4+12) = 180 бит → сжимаем до 158 бит (пока заглушка)
    bits = bits(1:158); % Временное решение
end