%Создание кортежей

function tuples = GetFingerprint(audioData, sampleRate, needVisualise)		

meanChannels = mean(audioData, 2);		%Получаем среднее значение по стереоканалам
%newSampleRate = 8000;
%resampledData = resample(meanChannels, sampleRate, newSampleRate);

data = meanChannels;
dataLength = length(data);
wndSize = 2048; %floor(dataLength / 4.5);
wnd = hamming(wndSize);		%Возвращает n-точечное симметричное окно Хэмминга в виде вектора-столбца wnd
overlap = wndSize / 2;
fftSize = max(256, 2 ^ nextpow2(wndSize));		%Создаеи матрицу, возвращающую наибольшие значения между 2мя значениями 

[S, freq, time, power] = spectrogram(data, wnd, overlap, fftSize, sampleRate);		%Получаем спектограмму,
%	где S – спектрограмма в виде матрицы,	freq – вектор частот в герцах для оси ординат, 
%	time – вектор временных отсчетов для оси абсцисс,
%	power – матрица спектральной плотности мощности (PSD).

logPower = 10 * log10(power);	%преобразуем спектральную мощность в децибелы 
kHzFreq = freq / 1000;		%выводим частоту в килогерцах

if (needVisualise)		%выводим спектограмму на экран
    surf(time, kHzFreq, logPower, 'edgecolor', 'none');
    axis tight;
    xlabel('Time (seconds)');
    ylabel('Frequences (kHz)');
    view(0, 90);
end

shiftRectHalfSize = 4;
[peaks, freqIds, timeIds] = GetPeaks(power, shiftRectHalfSize);		%Используем функцию для нахождения пиков композиции

P = power(sub2ind(size(power), freqIds, timeIds));
T = time(timeIds);
F = kHzFreq(freqIds);

if (needVisualise)		%Выводим пики
    hold on
    scatter3(T, F, P, '*r');
    hold off
end

deltaTime = 35; % bound on time difference (in pixels)	/	Связь с разницей во времени (в пикселях)
deltaFreq = 30; % bound on frequency difference (in pixels)	/	Связь с разницей в частоте (в пикселях)
fanout = 3; % Maximum number of pairs per peak.	/	Максимальное число пар на один пик
tuples = GetTuples(power .* peaks, fanout, deltaTime, deltaFreq);		%Используем функцию для полуения кортежа

if (needVisualise)		%Выводим кортеж
    hold on
    for i = 1:size(tuples,1)
        line([time(tuples(i,1)), time(tuples(i,2))], [kHzFreq(tuples(i,3)), kHzFreq(tuples(i,4))])
    end
    hold off
end

end

