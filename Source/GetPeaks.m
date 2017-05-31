% Функция для нахождения пиков композиции
function [peaks, freqIds, timeIds] = GetPeaks(power, kHzFreq, shiftMaxStepT, shiftMaxStepF)
% time    = [0 1 2 3 4 5 6 7 8];
% kHzFreq = [0 1 2 3 4 5 6 7];
% power   = [0 0 0 0 0 0 0 0 0;
%            0 0 0 0 0 0 0 0 7;
%            0 1 8 2 3 1 0 0 0;
%            0 5 4 7 0 2 0 0 0;
%            0 6 7 7 9 3 0 0 0; 
%            0 5 2 6 7 5 0 0 0;
%            0 0 0 0 0 0 9 0 0;
%            0 0 0 0 0 0 0 0 0];

% [rowIds, colIds] = GetPeaks(power, 1);
% P = power(sub2ind(size(power),rowIds,colIds));
% T = time(colIds);
% F = kHzFreq(rowIds);

% subplot (3, 1, 1);
% ViewMatrix(power);

peaks = true(size(power, 1), size(power, 2));
for i = -shiftMaxStepT : shiftMaxStepT
    for j = -shiftMaxStepF : shiftMaxStepF
        if (i == 0 && j == 0)
            continue
        end
        
        shifted = circshift(power, [i, j]);
        peaks = (peaks & (power - shifted) > 0);
    end
end

peaks = FilterPeaksByThresholds(power, kHzFreq, peaks);

% subplot (3, 1, 2);
% ViewMatrix(peaks);
%threshold = 0.0001;
%desiredPPS = 30; % scales the threshold
%peakMags = peaks .* matrix;
%sortedpeakMags = sort(peakMags(:),'descend'); % sort all peak values in order
%threshold = sortedpeakMags(ceil(max(0)*desiredPPS));
% Apply threshold
%if (threshold > 0)
    %peaks = (peakMags >= threshold);
%sortedpeakMags = sort(peaks(:),'descend'); % sort all peak values in order

[freqIds, timeIds] = find(peaks);
end

% Фильтруем пики для каждого момента времени
function [peaks] = FilterPeaksByThresholds(power, kHzFreq, peaks)
freqRanges = [20 40 60 80 100 150 200 400 600 800 1000 2000 4000 6000 8000 10000 12000 14000 16000 18000 19000 20000];

% Получаем среднее значение на каждой полосе частот
freqThresholds = zeros(1, length(freqRanges) - 1);
for freqRangeIdx = 1 : length(freqRanges) - 1
    a = freqRanges(freqRangeIdx) / 1000;
    b = freqRanges(freqRangeIdx + 1) / 1000;
    freqWnd = power(sub2ind(size(kHzFreq), find(kHzFreq >= a & kHzFreq < b)), :);
    if isempty(freqWnd)
        continue
    end
    threshold = mean2(freqWnd);
    freqThresholds(freqRangeIdx) = threshold;
end

% Получаем среднее значение на каждой полосе частот
for timeIdx = 1 : size(power, 2)
    timeCut = power(:, timeIdx);
    for freqIdx = 1 : length(freqRanges) - 1
        a = freqRanges(freqIdx) / 1000;
        b = freqRanges(freqIdx + 1) / 1000;
        freqWnd = sub2ind(size(kHzFreq), find(kHzFreq >= a & kHzFreq < b));
        if isempty(freqWnd)
            continue
        end
        peaksWnd = timeCut(freqWnd);
        threshold = mean(peaksWnd);
        peaksWnd = peaksWnd >= threshold & peaksWnd >= freqThresholds(freqIdx);
        peaks(freqWnd, timeIdx) = peaks(freqWnd, timeIdx) & peaksWnd;
    end
end

end