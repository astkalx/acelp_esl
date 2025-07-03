[pxx, freq] = pwelch(double(output_frame), [], [], [], 16000);
semilogy(freq, pxx);
xlim([2000 4000]); % Проверка усиления 2-4 кГц