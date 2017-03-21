%Функция для нахождения хеша

function hash = GetHash(freq1, freq2, deltaTime, size)
hash = mod(round( size * 1000000 * (log(abs(freq1)+2) + 2 * log(abs(freq2) + 2) + 3 * log(abs(deltaTime) + 2)) ), size) + 1;
end

