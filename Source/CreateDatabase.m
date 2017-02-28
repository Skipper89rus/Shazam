dirPath = 'D:\Music';
supportedAudioExt = {'.mp3'; '.wav'};
audioFiles = GetFilesWithExtensions(dirPath, supportedAudioExt);

hashTableSize = 100000;
global GHashTable

if ~exist('GSongsNum')
    % Загружаем базу, если она есть
    if exist('SongsNum.mat')
        load('SongsNum.mat');
        load('HashTable.mat');
    else  
        % Создаем базу
        songsNum = cell(0);
        GHashTable = cell(hashTableSize, 2); % 
    end
end

for songIdx = 1 : size(audioFiles)
    fprintf('Adding file \''%s\'' to the database...', audioFiles{songIdx});
    
    % fileLength = length(fileData);
    % interval = [(fileLength * 2) / sampleRate,(fileLength * 2) / sampleRate];
    % clear fileData sampleRate
    % [fileData, sampleRate] = audioread(file, interval);
    [audioData, sampleRate] = audioread(audioFiles{songIdx});

    needVisualise = 0;
    tuples = GetFingerprint(audioData, sampleRate, needVisualise);
    maxCollisions = AddToTable(tuples, songIdx);
    
    fprintf(' done.\n');
end

global GSongsNum
GSongsNum = songIdx;
save('SongsNum.mat', 'GSongsNum');
save('HashTable.mat', 'GHashTable');

%player = audioplayer(fileData, sampleRate);
%play(player)
%stop(player)
%pause(player)