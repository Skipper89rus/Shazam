function [peaksMask] = GetPeaksByShifting(power, shiftMaxStepF, shiftMaxStepT)
%   ѕолучаем пиковые значени€ путем сдвига мощностей в разные стороны
%       shiftMaxStepT - максимальный сдвиг по оси времени
%       shiftMaxStepF - максимальный сдвиг по оси частот

% power   = [0 0 0 0 0 0 0 0 0;
%            0 0 0 0 0 0 0 0 7;
%            0 1 8 2 3 1 0 0 0;
%            0 5 4 7 0 2 0 0 0;
%            0 6 7 7 9 3 0 0 0; 
%            0 5 2 6 7 5 0 0 0;
%            0 0 0 0 0 0 9 0 0;
%            0 0 0 0 0 0 0 0 0];
% 
% subplot (3, 1, 1);
% ViewMatrix(power);

peaksMask = true(size(power, 1), size(power, 2));
for shiftF = -shiftMaxStepF : shiftMaxStepF
    for shiftT = -shiftMaxStepT : shiftMaxStepT
        if (shiftF == 0 && shiftT == 0)
            continue
        end
        shifted = circshift(power, [shiftF, shiftT]);
        peaksMask = (peaksMask & (power - shifted) > 0);
    end
end
end

function ViewMatrix(matrix)
%   ‘ункци€ дебажной отрисовки матрицы в виде €чеек

imagesc(matrix);
matrixXSz = size(matrix, 2);
matrixYSz = size(matrix, 1);
colormap( flipud(gray) );

textStrings = num2str(matrix(:), '%0.2f');
textStrings = strtrim( cellstr(textStrings) );

[x, y] = meshgrid(1:matrixXSz, 1:matrixYSz);
hStrings = text(x(:), y(:), textStrings(:), 'HorizontalAlignment', 'center');
midValue = mean( get(gca,'CLim') );
textColors = repmat(matrix(:) > midValue, 1, 3);
set( hStrings,{'Color'},num2cell(textColors,2) );
end