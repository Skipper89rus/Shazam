function [powerPeaksIds] = GetRectPeaks(power, kHzFreq, time, freqBound, timeBound, timeStep, timeOverlap)
%   GetRectPeaks ѕолучить пики дл€ выбранной области спектрограммы
%       freqBound - границы частот (размер 2)
%       timeBound - границы времени (размер 2)
%       return powerPeaksIds - индексы пиков в power

logPower = 10 * log10(power);

% ¬ыдел€ем окно по частоте
boundedFreqIds = 1:length(kHzFreq);
if ~isempty(freqBound)
    boundedFreqIds = find( kHzFreq >= freqBound(1) & kHzFreq <= freqBound(2) );
end
boundedFreq = kHzFreq(boundedFreqIds);

boundedTimeIds = 1:length(time);
if ~isempty(timeBound)
    boundedTimeIds = find( time >= timeBound(1) & time <= timeBound(2) );
end

% ѕолучаем плоскостность по переданному окну
boundedPower = power(boundedFreqIds, boundedTimeIds);
flatness = geomean(boundedPower) / mean(boundedPower);
fprintf('flatness = %.6f\n', flatness);

peaksMask = true( size(boundedPower, 1), size(boundedPower, 2) );

% ќкно по времени выбираем в зависимости от смены flatness
loBound = 0;
maxTime = min(loBound + timeStep, time(end));
hiBound = maxTime;
if ~isempty(timeBound) && length(timeBound) == 2
    loBound = timeBound(1);
    hiBound = min(loBound + timeStep, timeBound(2));
end

while hiBound < maxTime
    boundedTimeIds = find( time >= loBound & time <= hiBound );
    
    fprintf('loBound = %.2f; hiBound = %.2f', loBound, hiBound);
    if IsFlatnessChanged( flatness, power(boundedFreqIds, boundedTimeIds) )
        curPeaksMask = GetRectPeaksInternal(logPower(boundedFreqIds, boundedTimeIds), boundedFreq);
        % ѕересекаем имеющиес€ пики и полученные
        peaksMask(boundedFreqIds, boundedTimeIds) = peaksMask(boundedFreqIds, boundedTimeIds) & curPeaksMask;
        ShowPeaks(logPower, kHzFreq, time, curPeaksMask, boundedFreqIds(1), boundedTimeIds(1), '.r');
        
        loBound = hiBound - timeStep * timeOverlap;
    end
    hiBound = hiBound + timeStep * (1 - timeOverlap);
end

curPeaksMask = GetRectPeaksInternal(logPower(boundedFreqIds, boundedTimeIds), boundedFreq);
peaksMask(boundedFreqIds, boundedTimeIds) = peaksMask(boundedFreqIds, boundedTimeIds) & curPeaksMask;
ShowPeaks(logPower, kHzFreq, time, curPeaksMask, boundedFreqIds(1), boundedTimeIds(1), '.r');

[freqIds, timeIds] = find(peaksMask);
[freqIds, timeIds] = OffsetIndexes( freqIds, timeIds, boundedFreqIds(1), boundedTimeIds(1) );
powerPeaksIds = sub2ind(size(power), freqIds, timeIds);
end

function result = IsFlatnessChanged(f, power)    
    flatness = geomean(power) / mean(power);
    fprintf('; flatness = %.6f\n', flatness);
    result = flatness > f;
end

function [peaksMask] = GetRectPeaksInternal(power, kHzFreq)
%   GetRectPeaks ѕолучить пики дл€ выбранной области спектрограммы
%       freqBound - границы частот (размер 2)
%       timeBound - границы времени (размер 2)
%       return powerPeaksIds - индексы пиков в power

%shiftMaxStepF = 2;
%shiftMaxStepT = 0;
%[peaksMask] = GetPeaksByShifting(boundedPower, shiftMaxStepF, shiftMaxStepT);
[peaksMask] = GetPeaksSimple(power);

% „астотные диапазоны дл€ фильтрации
freqRanges = [20 40 60 80 100 150 200 400 600 800 1000 2000 4000 6000 8000 10000 12000 14000 16000 18000 19000 20000];
% ƒл€ каждого диапазона пороговое значение
[freqRangesThresholds] = CalcThresholdsForFreqRanges(power, kHzFreq, freqRanges);
[peaksMask] = FilterPeaksByThresholds(power, kHzFreq, peaksMask, freqRanges, freqRangesThresholds);
%[peaksMask] = FindPointsScattering(boundedPower, boundedFreq, peaksMask, freqRanges, freqRangesThresholds);
end

function [freqRangesThresholds] = CalcThresholdsForFreqRanges(boundedPower, boundedFreq, freqRanges)
%   ѕолучаем вес порогового значени€ дл€ каждого диапазона частот
%   ѕорог считаетс€ следующим образом: freqRangesThresholdsWeights(i) = meanRange / meanCommon, meanRange - средн€€ мощность по диапазону,
%                                                                                               meanCommon - средн€€ мощность по всему спектру
%       freqRanges - диапазоны частот

freqRangesThresholds = zeros(1, length(freqRanges) - 1);
for freqRangeIdx = 1 : length(freqRanges) - 1
    a = freqRanges(freqRangeIdx);
    b = freqRanges(freqRangeIdx + 1);
    freqWnd = boundedPower(sub2ind(size(boundedFreq), find(boundedFreq >= a & boundedFreq < b)), :);
    if isempty(freqWnd)
        continue
    end

    meanRange = mean2(freqWnd);
    freqRangesThresholds(freqRangeIdx) = meanRange;
end
end

function [peaksMask] = FilterPeaksByThresholds(boundedPower, boundedFreq, peaksMask, freqRanges, freqRangesThresholds)
%	‘ильтруем пики каждого диапазона частот по соответствующему пороговому значению

timeWndSize = size(boundedPower, 2);

for freqRangeIdx = 1 : length(freqRanges) - 1    
    a = freqRanges(freqRangeIdx);
    b = freqRanges(freqRangeIdx + 1);
    freqRangeIds = find(boundedFreq >= a & boundedFreq < b);
    if isempty(freqRangeIds)
        continue
    end
    
    threshold = freqRangesThresholds(freqRangeIdx);
    
    for freqIdx = 1 : length(freqRangeIds)
        for timeIdx = 1 : timeWndSize
            %fprintf('freqIdx = %d; timeIdx = %d; power = %.10f; threshold = %.10f\n', freqRangeIds(freqIdx), timeIdx, boundedPower(freqRangeIds(freqIdx), timeIdx), threshold);
            if boundedPower(freqRangeIds(freqIdx), timeIdx) < threshold
                peaksMask(freqRangeIds(freqIdx), timeIdx) = false;
            end
        end
    end
end
end

function [peaksMask] = FindPointsScattering(boundedPower, boundedFreq, peaksMask, freqRanges, freqRangesThresholds)
%   ќт пиков ищем ореолы методом градиентов

timeWndSize = size(boundedPower, 2);
for freqRangeIdx = 1 : length(freqRanges) - 1    
    a = freqRanges(freqRangeIdx);
    b = freqRanges(freqRangeIdx + 1);
    freqRangeIds = find(boundedFreq >= a & boundedFreq < b);
    if isempty(freqRangeIds)
        continue
    end

    %TODO: Ќеобходимо дл€ каждой полосы частот получать свой diffRatio
    threshold = freqRangesThresholds(freqRangeIdx);
    recursionDepth = 20;
    diffRatio = 0.96;
    
    for freqIdx = 1 : length(freqRangeIds)
        for timeIdx = 1 : timeWndSize
            if ~peaksMask(freqRangeIds(freqIdx), timeIdx)
                continue
            end
            
            peaksMask = FindPointScattering(freqRangeIds(freqIdx), timeIdx, boundedPower, peaksMask, diffRatio, recursionDepth);
        end
    end
end
end

function ShowPeaks(power, kHzFreq, time, peaksMask, freqIdxOffset, timeIdxOffset, peakFormat)

[freqIds, timeIds] = find(peaksMask);
[freqIds, timeIds] = OffsetIndexes(freqIds, timeIds, freqIdxOffset, timeIdxOffset);

freq = kHzFreq / 1000;

P = power( sub2ind(size(power), freqIds, timeIds) );
F = freq(freqIds);
T = time(timeIds);

hold on
scatter3(T, F, P, peakFormat);
hold off

end

function [freqOffsetedIds, timeOffsetedIds] = OffsetIndexes(freqIds, timeIds, freqIdxOffset, timeIdxOffset)
freqOffsetedIds = freqIds + freqIdxOffset - 1;
timeOffsetedIds = timeIds + timeIdxOffset - 1;
end