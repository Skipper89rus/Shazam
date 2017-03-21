%Проверка на совпадение двух образцов

function [bestMatchId, confidence] = MatchAudioSample(sample, sampleRate)

global GHashTable
global GSongsNum

hashTableSize = size(GHashTable, 1);

needVisualise = 0;
sampleTuples = GetFingerprint(sample, sampleRate, needVisualise);

% Construct the cell of matches
matches = cell(GSongsNum, 1);
for tupleIdx = 1 : size(sampleTuples, 1)
    peaksDeltaTime = sampleTuples(tupleIdx, 2) - sampleTuples(tupleIdx, 1);
    sampleHash = GetHash(sampleTuples(tupleIdx, 3), sampleTuples(tupleIdx, 4), peaksDeltaTime, hashTableSize);
    
    % If an entry exists with this hash, find the song(s) with matching peak pairs
    if ~isempty(GHashTable{sampleHash, 1})
        matchIds = GHashTable{sampleHash, 1}; % row vector of collisions
        matchTime = GHashTable{sampleHash, 2}; % row vector of collisions
        
        % Calculate the time difference between clip pair and song pair
        sampleTimeOffset = matchTime - sampleTuples(tupleIdx, 1);
        
        % Add matches to the lists for each individual song
        for songIdx = 1 : GSongsNum
            songMatchIds = find(matchIds == songIdx);
            matches{songIdx} = [matches{songIdx}, sampleTimeOffset(songMatchIds)];
        end
    end
end

% Find the counts of the mode of the time offset array for each song

bestMatchId = 0;
maxMatch = 0;
for songIdx = 1 : GSongsNum
    l = length(matches{songIdx});
    if l > maxMatch
        maxMatch = l;
        bestMatchId = songIdx;
    end
end

% Song decision and confidence
% INSERT CODE HERE

optional_plot = 1; % turn plot on or off

if optional_plot
    figure(3)
    clf
    y = zeros(length(matches),1);
    for k = 1:length(matches)
        subplot(length(matches),1,k)
        hist(matches{k},1000)
        y(k) = max(hist(matches{k},1000));
    end
    
    for k = 1:length(matches)
        subplot(length(matches),1,k)
        axis([-inf, inf, 0, max(y)])
    end

    subplot(length(matches),1,1)
    title('Histogram of offsets for each song')
end

end