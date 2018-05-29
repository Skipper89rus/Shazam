function [powerPeaksIds] = GetRectPeaks(power, kHzFreq, time, settings, visualize)
%   GetRectPeaks ѕолучить пики дл€ выбранной области спектрограммы
%       freqBound - границы частот (размер 2)
%       timeBound - границы времени (размер 2)
%       return powerPeaksIds - индексы пиков в power

logPower = 10 * log10(power);

% ¬ыдел€ем окно по частоте
boundedFreqIds = 1:length(kHzFreq);
if ~isempty(settings.freqBound)
    boundedFreqIds = find( kHzFreq >= settings.freqBound(1) & kHzFreq <= settings.freqBound(2) );
end
boundedFreq = kHzFreq(boundedFreqIds);

boundedTimeIds = 1:length(time);
if ~isempty(settings.timeBound)
    boundedTimeIds = find( time >= settings.timeBound(1) & time <= settings.timeBound(2) );
end

% ѕолучаем плоскостность по переданному окну
boundedPower = power(boundedFreqIds, boundedTimeIds);

peaksMask = true( size(boundedPower, 1), size(boundedPower, 2) );

% ќкно по времени выбираем в зависимости от смены flatness
timeStep = time(end) * settings.timeStepPercent;
minTime = 0;
loBound = minTime;
maxTime = max(loBound + timeStep, time(end));
hiBound = min(loBound + timeStep, time(end));
if ~isempty(settings.timeBound) && length(settings.timeBound) == 2
    loBound = settings.timeBound(1);
    hiBound = min(loBound + timeStep, settings.timeBound(2));
end

if loBound == minTime
    curBoundedTimeIds = find( time >= loBound & time <= hiBound );
    curPowerWnd = power(boundedFreqIds, curBoundedTimeIds);
    prevFlatness = geomean(curPowerWnd) / mean(curPowerWnd);
    hiBound = hiBound + timeStep * (1 - settings.timeOverlapPercent);
end

while hiBound < maxTime
    curBoundedTimeIds = find( time >= loBound & time <= hiBound );
    curPowerWnd = power(boundedFreqIds, curBoundedTimeIds);

    fprintf('loBound = %.2f; hiBound = %.2f; ', loBound, hiBound);
    fprintf('prevFlatness = %.6f; ', prevFlatness);
    curFlatness = geomean(curPowerWnd) / mean(curPowerWnd);
    fprintf('curFlatness = %.6f; ', curFlatness);
    flatnessRate = abs(1 - max(prevFlatness, curFlatness) / min(prevFlatness, curFlatness));
    fprintf('flatnessRate = %.6f; ', flatnessRate);

    if flatnessRate > 0.2
        fprintf('flatness changed');
        curPeaksMask = GetRectPeaksInternal(logPower(boundedFreqIds, curBoundedTimeIds), boundedFreq);
        % ѕересекаем имеющиес€ пики и полученные
        peaksMask(boundedFreqIds, curBoundedTimeIds) = peaksMask(boundedFreqIds, curBoundedTimeIds) & curPeaksMask;
        if visualize
            ShowPeaks(logPower, kHzFreq, time, curPeaksMask, boundedFreqIds(1), curBoundedTimeIds(1), '.r');
        end
        loBound = hiBound - timeStep * settings.timeOverlapPercent;
        prevFlatness = curFlatness;
    end
    fprintf('\n');
    hiBound = hiBound + timeStep * (1 - settings.timeOverlapPercent);
end

curBoundedTimeIds = find( time >= loBound & time <= hiBound );
curPowerWnd = power(boundedFreqIds, curBoundedTimeIds);
curPeaksMask = GetRectPeaksInternal(curPowerWnd, boundedFreq);
peaksMask(boundedFreqIds, curBoundedTimeIds) = peaksMask(boundedFreqIds, curBoundedTimeIds) & curPeaksMask;
if visualize
    ShowPeaks(logPower, kHzFreq, time, curPeaksMask, boundedFreqIds(1), curBoundedTimeIds(1), '.r');
end
[freqIds, timeIds] = find(peaksMask);
[freqIds, timeIds] = OffsetIndexes( freqIds, timeIds, boundedFreqIds(1), boundedTimeIds(1) );
powerPeaksIds = sub2ind(size(power), freqIds, timeIds);
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
% freqRanges = [20 40 60 80 100 150 200 400 600 800 1000 2000 4000 6000 8000 10000 12000 14000 16000 18000 19000 20000];
freqRanges = [80 200 500 2500 5000 10000 16000 20000];

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