function maxCollisions = AddToTable(tuples, songIdx)

global GHashTable;

hashTableSize = size(GHashTable, 1);

% Count the max number of collisions for a given hash (FYI)
maxCollisions = 0;
        
for tupleIdx = 1 : size(tuples, 1);
    hash = GetHash(tuples(tupleIdx, 3), tuples(tupleIdx, 4), tuples(tupleIdx, 2) - tuples(tupleIdx, 1), hashTableSize);
    %  first instance of this hash
    if isempty(GHashTable{hash, 1})
        GHashTable{hash, 1} = songIdx; % # id of the song
        GHashTable{hash, 2} = tuples(tupleIdx, 1); 
    % duplicate instance of this hash
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

