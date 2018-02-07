function peaksMask = FindPointScattering(freqIdx, timeIdx, power, peaksMask, diffRatio, recursionDepth)
%   Поиск точек вокруг заданной, разность мощности которых с заданной меньше, чем diff

if (freqIdx < 1 || freqIdx > size(power, 1) || timeIdx < 1 || timeIdx > size(power, 2) || recursionDepth == 0)
    return
end

% Проверяем снизу
if ( freqIdx - 1 >= 1 && ~peaksMask(freqIdx - 1, timeIdx) && isPowersInDiffBound(power(freqIdx, timeIdx), power(freqIdx - 1, timeIdx), diffRatio) )
    peaksMask(freqIdx - 1, timeIdx) = true;
    peaksMask = FindPointScattering(freqIdx - 1, timeIdx, power, peaksMask, diffRatio, recursionDepth - 1);
end
% Проверяем сверху
if ( freqIdx + 1 <= size(power, 1) && ~peaksMask(freqIdx + 1, timeIdx) && isPowersInDiffBound(power(freqIdx, timeIdx), power(freqIdx + 1, timeIdx), diffRatio) )
    peaksMask(freqIdx + 1, timeIdx) = true;
    peaksMask = FindPointScattering(freqIdx + 1, timeIdx, power, peaksMask, diffRatio, recursionDepth - 1);
end
% Проверяем слева
if ( timeIdx - 1 >= 1 && ~peaksMask(freqIdx, timeIdx - 1) && isPowersInDiffBound(power(freqIdx, timeIdx), power(freqIdx, timeIdx - 1), diffRatio) )
    peaksMask(freqIdx, timeIdx - 1) = true;
    peaksMask = FindPointScattering(freqIdx, timeIdx - 1, power, peaksMask, diffRatio, recursionDepth - 1);
end
% Проверяем справа
if ( timeIdx + 1 <= size(power, 2) && ~peaksMask(freqIdx, timeIdx + 1) && isPowersInDiffBound(power(freqIdx, timeIdx), power(freqIdx, timeIdx + 1), diffRatio) )
    peaksMask(freqIdx, timeIdx + 1) = true;
    peaksMask = FindPointScattering(freqIdx, timeIdx + 1, power, peaksMask, diffRatio, recursionDepth - 1);
end
end

function result = isPowersInDiffBound(power1, power2, diffRatio)

d = power1 / power2;
result = 0;
fprintf('power1 = %.10f; power2 = %.10f; power1 / power2 = %f\n', power1, power2, d);
if d < 1 && d > diffRatio
    result = 1;
end

end