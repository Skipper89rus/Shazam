%Подготовка базы данных

function maxCollisions = AddToTable(tuples, songIdx)

global GHashTable;	%Глобальная переменная, в которую будут добавляться композиции

hashTableSize = size(GHashTable, 1);

% Count the max number of collisions for a given hash (FYI)	/	Считаем максимальное число противоречий (столкновений) для заданного хеша
maxCollisions = 0;
        
for tupleIdx = 1 : size(tuples, 1);
    hash = GetHash(tuples(tupleIdx, 3), tuples(tupleIdx, 4), tuples(tupleIdx, 2) - tuples(tupleIdx, 1), hashTableSize);	%Используем функцию для полуения хеша
    %  first instance of this hash	/	первый экземпляр этой хеш-функции
    if isempty(GHashTable{hash, 1})
        GHashTable{hash, 1} = songIdx; % # id of the song
        GHashTable{hash, 2} = tuples(tupleIdx, 1); 
    % duplicate instance of this hash	/	дубликат экземпляра этой хеш-функции
    else
        GHashTable{hash, 1} = [GHashTable{hash, 1}, songIdx];
        GHashTable{hash, 2} = [GHashTable{hash, 2}, tuples(tupleIdx, 1)];

        collisions = length(GHashTable{hash, 1});
        if collisions > maxCollisions
            maxCollisions = collisions;
        end
    end
end

end

