function [peaksMask] = GetPeaksSimple(boundedPower)
%   �������� ��������� ��������� ��� ������� ������� � ������� findpeaks

peaksMask = false( size(boundedPower, 1), size(boundedPower, 2) );
for sampleIdx = 1 : size(boundedPower, 2)
    sample = boundedPower(:, sampleIdx);
    [peaks, peaksIds] = findpeaks(sample);
    peaksMask(peaksIds, sampleIdx) = true;
end
end