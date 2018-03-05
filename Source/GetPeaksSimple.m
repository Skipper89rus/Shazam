function [peaksMask] = GetPeaksSimple(power)
%   �������� ��������� ��������� ��� ������� ������� � ������� findpeaks

peaksMask = false( size(power, 1), size(power, 2) );
for sampleIdx = 1 : size(power, 2)
    sample = power(:, sampleIdx);
    [peaks, peaksIds] = findpeaks(sample);
    peaksMask(peaksIds, sampleIdx) = true;
end
end