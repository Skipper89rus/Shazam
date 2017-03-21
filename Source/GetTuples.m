%Функция для полуения кортежа

function tuples = GetTuples(peaks, fanout, deltaTime, deltaFreq)

% Можно брать конкретные индексы, а не итерироваться по всей карте peaks
[f, t] = find(peaks);
peakCount = length(f);

tuples = zeros(fanout * peakCount, 4);

index = 1;
for i = 1 : peakCount
    links = 0;
    for f2 = min(size(peaks,1), f(i) + 1) : min(size(peaks,1), f(i) + deltaFreq)
        if peaks(f2, t(i))
            tuples(index, :) = [t(i) t(i) f(i) f2];
            links = links + 1;
            index = index + 1;
        end
        if (links >= fanout)
            break;
        end
    end
    for t2 = min(size(peaks,2), t(i) + 1) : min(size(peaks,2), t(i) + deltaTime)
        if (links >= fanout)
            break;
        end
        for f2 = max(1, f(i) - deltaFreq) : min(size(peaks,1), f(i) + deltaFreq)
            if (links >= fanout)
                break;
            end
            if peaks(f2, t2)
                tuples(index, :) = [t(i) t2 f(i) f2];
                links = links + 1;
                index = index + 1;
            end
        end
    end
end

tuples = tuples(1:(index - 1), :);
end