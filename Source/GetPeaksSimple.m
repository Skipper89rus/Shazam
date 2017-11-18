function [peaksMask] = GetPeaksSimple(boundedPower)
%   Получаем локальные максимумы для каждого отсчета с помощью findpeaks

peaksMask = false( size(boundedPower, 1), size(boundedPower, 2) );
for sampleIdx = 1 : size(boundedPower, 2)
    sample = boundedPower(:, sampleIdx);
    [peaks, peaksIds] = findpeaks(sample);
    peaksMask(peaksIds, sampleIdx) = true;
end
end