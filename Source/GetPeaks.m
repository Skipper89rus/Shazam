% Функция для нахождения пиков композиции
function [peaks, freqIds, timeIds] = GetPeaks(power, shiftMaxStepT, shiftMaxStepF)
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
    for j = -shiftMaxStepF : shiftMaxStepF
        if (i == 0 && j == 0)
            continue
        end
        
        shifted = circshift(power, [i, j]);
        peaks = (peaks & (power - shifted) > 0);
    end
end

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
