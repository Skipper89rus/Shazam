% Предназначение функции - подавление точек из окрестности
% данной точки, имеющих большую разницу в значении спектральной
% мощности, по сравнению с данной точкой.
% 
% Параметры
% row, col - координаты точки, вокруг которой рекурсивно
% подавляем соседей
% power - матрица, в которой подавляем точки
% diff - насколько должны различаться значения между точками при подавлении
% zeroValue - значение, присваемоваемое подавляемой точке
% recursionDepth - глубина рекурсии
%
% P.s. хочу в будущем добавить еще один параметр-функтор, 
% который будет играть роль критерия подавления точки. Сейчас критерий
% подавления может быть только один - это условие в if, например
% abs(power(row,col)-power(row,col+1)) > diff. 

function resultPower = SuppressPointsAroundCurrentPointWithBigDiff( row, col, power, diff, zeroValue, recursionDepth )
power(row,col) = zeroValue;
if(row > 1 && row < size(power,1)-1 && col > 1 && col < size(power,2)-1 && recursionDepth ~= 0)
    if (power(row,col+1) ~= zeroValue && abs(power(row,col)-power(row,col+1)) > diff)
        power = SuppressPointsAroundCurrentPointWithBigDiff(row,col+1,power,diff,zeroValue, recursionDepth - 1);
    end
    if (power(row,col-1) ~= zeroValue && abs(power(row,col)-power(row,col-1)) > diff)
        power = SuppressPointsAroundCurrentPointWithBigDiff(row,col-1,power,diff,zeroValue,recursionDepth - 1);
    end
    if (power(row-1,col) ~= zeroValue && abs(power(row,col)-power(row-1,col)) > diff)
        power = SuppressPointsAroundCurrentPointWithBigDiff(row-1,col,power,diff,zeroValue,recursionDepth - 1);
    end
    if (power(row+1,col) ~= zeroValue && abs(power(row,col)-power(row+1,col)) > diff)
        power = SuppressPointsAroundCurrentPointWithBigDiff(row+1,col,power,diff,zeroValue,recursionDepth - 1);
    end
end
resultPower = power;
end
