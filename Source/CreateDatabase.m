% Создание базы данных

dirPath = '..\Data'; % Путь к муз.композициям
supportedAudioExt = {'.mp3'; '.wav'}; % Указываем нужные форматы
audioFiles = GetFilesWithExtensions(dirPath, supportedAudioExt); % Находим имеющиеся файлы

hashTableSize = 100000;
global GHashTable % Глобальная переменная, в которую будут добавляться композиции

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

for songIdx = 1 : size(audioFiles) % Добавляем муз.композицию в базу данных
    fprintf('Adding file \''%s\'' to the database...', audioFiles{songIdx});

    [audioData, sampleRate] = audioread(audioFiles{songIdx});
    % fileLength = length(fileData);
    % interval = [(fileLength * 2) / sampleRate,(fileLength * 2) / sampleRate];
    % clear fileData sampleRate
    % [fileData, sampleRate] = audioread(file, interval);

    needVisualise = 1;
    tuples = GetFingerprint(audioData, sampleRate, needVisualise); % Получаем кортеж
    maxCollisions = AddToTable(tuples, songIdx); % Считаем максимальное число противоречий (столкновений) для заданного хеша
    
    fprintf(' done.\n');
end

global GSongsNum % Создаем глобальную переменную для номера песен
GSongsNum = songIdx; % Записываем номер песни в созданную переменную
save('SongsNum.mat', 'GSongsNum'); % Сохраняем необходимое
save('HashTable.mat', 'GHashTable');

%player = audioplayer(fileData, sampleRate);
%play(player)
%stop(player)
%pause(player)