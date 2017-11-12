% �������� ���� ������

dirPath = '..\Data'; % ���� � ���.�����������
supportedAudioExt = {'.mp3'; '.wav'}; % ��������� ������ �������
audioFiles = GetFilesWithExtensions(dirPath, supportedAudioExt); % ������� ��������� �����

hashTableSize = 100000;
global GHashTable % ���������� ����������, � ������� ����� ����������� ����������

if ~exist('GSongsNum')
    % ��������� ����, ���� ��� ����
    if exist('SongsNum.mat')
        load('SongsNum.mat');
        load('HashTable.mat');
    else  
        % ������� ����
        songsNum = cell(0);
        GHashTable = cell(hashTableSize, 2); % 
    end
end

for songIdx = 1 : size(audioFiles) % ��������� ���.���������� � ���� ������
    fprintf('Adding file \''%s\'' to the database...', audioFiles{songIdx});

    [audioData, sampleRate] = audioread(audioFiles{songIdx});

    needVisualise = 1;
    tuples = GetFingerprint(audioData, sampleRate, needVisualise); % �������� ������
    maxCollisions = AddToTable(tuples, songIdx); % ������� ������������ ����� ������������ (������������) ��� ��������� ����
    
    fprintf(' done.\n');
end

global GSongsNum % ������� ���������� ���������� ��� ������ �����
GSongsNum = songIdx; % ���������� ����� ����� � ��������� ����������
save('SongsNum.mat', 'GSongsNum'); % ��������� �����������
save('HashTable.mat', 'GHashTable');

%player = audioplayer(fileData, sampleRate);
%play(player)
%stop(player)
%pause(player)