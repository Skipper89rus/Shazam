function [powerPeaksIds] = GetRectPeaks(power, kHzFreq, time, freqBound, timeBound)
%   GetRectPeaks Получить пики для выбранной области спектрограммы
%       freqBound - границы частот (размер 2)
%       timeBound - границы времени (размер 2)
%       return powerPeaksIds - индексы пиков в power

% Выделяем область
boundedFreqIds = 1:length(kHzFreq);
if ~isempty(freqBound)
    boundedFreqIds = find( kHzFreq >= freqBound(1) & kHzFreq <= freqBound(2) );
end

boundedTimeIds = 1:length(time);
if ~isempty(timeBound)
    boundedTimeIds = find( time >= timeBound(1) & time <= timeBound(2) );
end

boundedPower = power(boundedFreqIds, boundedTimeIds);
boundedFreq = kHzFreq(boundedFreqIds);
boundedTime = time(boundedTimeIds);

% Поиск пиков
shiftMaxStepF = 4;
shiftMaxStepT = 0;
[peaksMask] = GetPeaksByShifting(boundedPower, shiftMaxStepF, shiftMaxStepT);
ShowPeaks( power, kHzFreq, time, peaksMask, boundedFreqIds(1), boundedTimeIds(1) );

% Частотные диапазоны для фильтрации
freqRanges = [20 40 60 80 100 150 200 400 600 800 1000 2000 4000 6000 8000 10000 12000 14000 16000 18000 19000 20000];
% Для каждого диапазона получаем влияние(вес) порогового значения
freqRangesThresholdsWeights = CalcThresholdsWeightsForFreqRanges(power, boundedPower, boundedFreq, freqRanges);
[peaksMask] = FilterPeaksByThresholds(boundedPower, boundedFreq, peaksMask, freqRanges, freqRangesThresholdsWeights);
ShowPeaks( power, kHzFreq, time, peaksMask, boundedFreqIds(1), boundedTimeIds(1) );

%[boundedPower] = SuppressPointsAroundCurrentPoint(boundedPower, boundedFreq, freqRanges, freqIds, timeIds, freqThresholds);
% Индексы матрицы с нулевой мощностью
%[freqPeaksIds, timePeaksIds] = find(boundedPower == 0);
%[freqIds, timeIds] = OffsetIndexes( freqPeaksIds, timePeaksIds, boundedFreqIds(1), boundedTimeIds(1) );
%ShowPeaks(power, kHzFreq, time, freqOffsetedIds, timeOffsetedIds);

[freqIds, timeIds] = find(peaksMask);
[freqIds, timeIds] = OffsetIndexes( freqIds, timeIds, boundedFreqIds(1), boundedTimeIds(1) );
powerPeaksIds = sub2ind(size(power), freqIds, timeIds);
end

function [freqRangesThresholdsWeights] = CalcThresholdsWeightsForFreqRanges(power, boundedPower, boundedFreq, freqRanges)
%   Получаем вес порогового значения для каждого диапазона частот
%   Порог считается следующим образом: freqRangesThresholdsWeights(i) = meanRange / meanCommon, meanRange - средняя мощность по диапазону,
%                                                                                               meanCommon - средняя мощность по всему спектру
%       freqRanges - диапазоны частот

    meanCommon = mean2(power);

    freqRangesThresholdsWeights = zeros(1, length(freqRanges) - 1);
    for freqRangeIdx = 1 : length(freqRanges) - 1
        a = freqRanges(freqRangeIdx) / 1000;
        b = freqRanges(freqRangeIdx + 1) / 1000;
        freqWnd = boundedPower(sub2ind(size(boundedFreq), find(boundedFreq >= a & boundedFreq < b)), :);
        if isempty(freqWnd)
            continue
        end
        meanRange = mean2(freqWnd);
        freqRangesThresholdsWeights(freqRangeIdx) = meanRange / meanCommon;
    end
end

function [peaksMask] = FilterPeaksByThresholds(boundedPower, boundedFreq, peaksMask, freqRanges, freqRangesThresholdsWeights)
%	Фильтруем пики по пороговому значению с учетом веса каждого диапазона частот

for freqRangeIdx = 1 : length(freqRanges) - 1    
    a = freqRanges(freqRangeIdx) / 1000;
    b = freqRanges(freqRangeIdx + 1) / 1000;
    freqRangeIds = find(boundedFreq >= a & boundedFreq < b);
    if isempty(freqRangeIds)
        continue
    end
    rangePeaksMask = peaksMask(freqRangeIds, :);
    
    rangePeaks = boundedPower(rangePeaksMask);
    rangePeaksMean = mean2(rangePeaks);
    threshold = rangePeaksMean * freqRangesThresholdsWeights(freqRangeIdx);
    
    for idx = 1 : size(freqRangeIds, 1)
        timeRangePeaksIds = find( rangePeaksMask(idx, :) );
        if isempty(timeRangePeaksIds)
            continue
        end
        
        filteredTimeRangePeaksIdx = timeRangePeaksIds(rangePeaks(idx, :) < threshold);
        peaksMask(freqRangeIds(idx), filteredTimeRangePeaksIdx) = false;
    end
end
end

function [boundedPower] = SuppressPointsAroundCurrentPoint(boundedPower, boundedFreq, freqIds, timeIds, freqRanges, freqRangesThresholdsWeights)
%	От пиков ищем ореолы методом градиентов

    for freqRangeIdx = 1 : length(freqRanges) - 1
        a = freqRanges(freqRangeIdx) / 1000;
        b = freqRanges(freqRangeIdx + 1) / 1000;

        boundIds = find(boundedFreq >= a & boundedFreq < b);
        if isempty(boundIds)
            continue
        end

        f = freqIds(boundIds);
        for fIdx = 1 : length(f)
            t = timeIds( freqIds == f(fIdx) );
            for tIdx = 1 : length(t)
                % TODO: Не надо сразу подавлять! Просто найти индексы
                boundedPower = SuppressPointsAroundCurrentPointWithBigDiff(f(fIdx), t(tIdx), boundedPower, freqThresholds(freqRangeIdx), 0, 10);
            end
        end
    end
end

function ShowPeaks(power, kHzFreq, time, peaksMask, freqIdxOffset, timeIdxOffset)

[freqIds, timeIds] = find(peaksMask);
[freqIds, timeIds] = OffsetIndexes(freqIds, timeIds, freqIdxOffset, timeIdxOffset);

P = power( sub2ind(size(power), freqIds, timeIds) );
F = kHzFreq(freqIds);
T = time(timeIds);

hold on
scatter3(T, F, P, '.r');
hold off

end

function [freqOffsetedIds, timeOffsetedIds] = OffsetIndexes(freqIds, timeIds, freqIdxOffset, timeIdxOffset)
freqOffsetedIds = freqIds + freqIdxOffset - 1;
timeOffsetedIds = timeIds + timeIdxOffset - 1;
end