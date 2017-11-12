% Создание кортежей
function tuples = GetFingerprint(audioData, sampleRate, needVisualise)

meanChannels = mean(audioData, 2); % Получаем среднее значение по стереоканалам
%newSampleRate = 8000;
%resampledData = resample(meanChannels, sampleRate, newSampleRate);

data = meanChannels;
dataLength = length(data);
wndSize = 2048; %floor(dataLength / 4.5);
wnd = hamming(wndSize); % Возвращает n-точечное симметричное окно Хэмминга в виде вектора-столбца wnd
overlap = wndSize / 2;
fftSize = max(256, 2 ^ nextpow2(wndSize)); % Создаеи матрицу, возвращающую наибольшие значения между 2 значениями 

[S, freq, time, power] = spectrogram(data, wnd, overlap, fftSize, sampleRate); % Получаем спектограмму, где S – спектрограмма в виде матрицы, freq – вектор частот в герцах для оси ординат,
                                                                               % time – вектор временных отсчетов для оси абсцисс,
                                                                               % power – матрица спектральной плотности мощности (PSD).

logPower = 10 * log10(power); % Преобразуем спектральную мощность в децибелы 
kHzFreq = freq / 1000; % Частота в килогерцах

% Обрезаем данные

if (needVisualise) % Выводим спектограмму на экран
    surf(time, kHzFreq, logPower, 'edgecolor', 'none');
    %colormap('gray')
    axis tight;
    xlabel('Time (seconds)');
    ylabel('Frequences (kHz)');
    view(0, 90);
end

[powerPeaksIds] = GetRectPeaks(power, kHzFreq, time, [], []);

deltaTime = 35;
deltaFreq = 30;
fanout = 3; % Максимальное число пар на один пик
tuples = GetTuples(power(powerPeaksIds), fanout, deltaTime, deltaFreq);

if (needVisualise) % Выводим кортеж
    hold on
    for i = 1:size(tuples,1)
        line([time(tuples(i,1)), time(tuples(i,2))], [kHzFreq(tuples(i,3)), kHzFreq(tuples(i,4))])
    end
    hold off
end

end

