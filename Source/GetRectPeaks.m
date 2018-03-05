function [powerPeaksIds] = GetRectPeaks(logPower, kHzFreq, time, freqBound, timeBound)
%   GetRectPeaks �������� ���� ��� ��������� ������� �������������
%       freqBound - ������� ������ (������ 2)
%       timeBound - ������� ������� (������ 2)
%       return powerPeaksIds - ������� ����� � power

% �������� �������
boundedFreqIds = 1:length(kHzFreq);
if ~isempty(freqBound)
    boundedFreqIds = find( kHzFreq >= freqBound(1) & kHzFreq <= freqBound(2) );
end

boundedTimeIds = 1:length(time);
if ~isempty(timeBound)
    boundedTimeIds = find( time >= timeBound(1) & time <= timeBound(2) );
end

boundedPower = logPower(boundedFreqIds, boundedTimeIds);
boundedFreq = kHzFreq(boundedFreqIds);
boundedTime = time(boundedTimeIds);

% ����� �����
shiftMaxStepF = 2;
shiftMaxStepT = 0;
[peaksMask] = GetPeaksByShifting(boundedPower, shiftMaxStepF, shiftMaxStepT);
%[peaksMask] = GetPeaksSimple(boundedPower);
%ShowPeaks(logPower, kHzFreq, time, peaksMask, boundedFreqIds(1), boundedTimeIds(1), '.g');

% ��������� ��������� ��� ����������
freqRanges = [20 40 60 80 100 150 200 400 600 800 1000 2000 4000 6000 8000 10000 12000 14000 16000 18000 19000 20000];
% ��� ������� ��������� ��������� ��������
[freqRangesThresholds] = CalcThresholdsForFreqRanges(boundedPower, boundedFreq, freqRanges);
[peaksMask] = FilterPeaksByThresholds(boundedPower, boundedFreq, peaksMask, freqRanges, freqRangesThresholds);
ShowPeaks(logPower, kHzFreq, time, peaksMask, boundedFreqIds(1), boundedTimeIds(1), '.r');

%[peaksMask] = FindPointsScattering(boundedPower, boundedFreq, peaksMask, freqRanges, freqRangesThresholds);
%ShowPeaks(logPower, kHzFreq, time, peaksMask, boundedFreqIds(1), boundedTimeIds(1), '.r');

[freqIds, timeIds] = find(peaksMask);
[freqIds, timeIds] = OffsetIndexes( freqIds, timeIds, boundedFreqIds(1), boundedTimeIds(1) );
powerPeaksIds = sub2ind(size(logPower), freqIds, timeIds);
end

function [freqRangesThresholds] = CalcThresholdsForFreqRanges(boundedPower, boundedFreq, freqRanges)
%   �������� ��� ���������� �������� ��� ������� ��������� ������
%   ����� ��������� ��������� �������: freqRangesThresholdsWeights(i) = meanRange / meanCommon, meanRange - ������� �������� �� ���������,
%                                                                                               meanCommon - ������� �������� �� ����� �������
%       freqRanges - ��������� ������

freqRangesThresholds = zeros(1, length(freqRanges) - 1);
for freqRangeIdx = 1 : length(freqRanges) - 1
    a = freqRanges(freqRangeIdx) / 1000;
    b = freqRanges(freqRangeIdx + 1) / 1000;
    freqWnd = boundedPower(sub2ind(size(boundedFreq), find(boundedFreq >= a & boundedFreq < b)), :);
    if isempty(freqWnd)
        continue
    end

    meanRange = mean2(freqWnd);
    freqRangesThresholds(freqRangeIdx) = meanRange;
end
end

function [peaksMask] = FilterPeaksByThresholds(boundedPower, boundedFreq, peaksMask, freqRanges, freqRangesThresholds)
%	��������� ���� ������� ��������� ������ �� ���������������� ���������� ��������

timeWndSize = size(boundedPower, 2);

for freqRangeIdx = 1 : length(freqRanges) - 1    
    a = freqRanges(freqRangeIdx) / 1000;
    b = freqRanges(freqRangeIdx + 1) / 1000;
    freqRangeIds = find(boundedFreq >= a & boundedFreq < b);
    if isempty(freqRangeIds)
        continue
    end
    
    threshold = freqRangesThresholds(freqRangeIdx);
    
    for freqIdx = 1 : length(freqRangeIds)
        for timeIdx = 1 : timeWndSize
            fprintf('freqIdx = %d; timeIdx = %d; power = %.10f; threshold = %.10f\n', freqRangeIds(freqIdx), timeIdx, boundedPower(freqRangeIds(freqIdx), timeIdx), threshold);
            if boundedPower(freqRangeIds(freqIdx), timeIdx) < threshold
                peaksMask(freqRangeIds(freqIdx), timeIdx) = false;
            end
        end
    end
end
end

function [peaksMask] = FindPointsScattering(boundedPower, boundedFreq, peaksMask, freqRanges, freqRangesThresholds)
%   �� ����� ���� ������ ������� ����������

timeWndSize = size(boundedPower, 2);
for freqRangeIdx = 1 : length(freqRanges) - 1    
    a = freqRanges(freqRangeIdx) / 1000;
    b = freqRanges(freqRangeIdx + 1) / 1000;
    freqRangeIds = find(boundedFreq >= a & boundedFreq < b);
    if isempty(freqRangeIds)
        continue
    end

    %TODO: ���������� ��� ������ ������ ������ �������� ���� diffRatio
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

P = power( sub2ind(size(power), freqIds, timeIds) );
F = kHzFreq(freqIds);
T = time(timeIds);

hold on
scatter3(T, F, P, peakFormat);
hold off

end

function [freqOffsetedIds, timeOffsetedIds] = OffsetIndexes(freqIds, timeIds, freqIdxOffset, timeIdxOffset)
freqOffsetedIds = freqIds + freqIdxOffset - 1;
timeOffsetedIds = timeIds + timeIdxOffset - 1;
end