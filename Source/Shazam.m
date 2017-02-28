recordingOn = 0; %1 for recording from microphone, 0 for random segment
selectRandom = 0;
saveRecorded = 0;
recordedFilePath = 'D:\Projects\Matlab\Shazam\recorded.wav';
duration = 10; % Seconds

global GHashTable

% Check if we have a database in the workspace
if ~exist('GSongsNum')
    % Load database if one exists
    if exist('SongsNum.mat')
        global GSongsNum
        load('SongsNum.mat');
        load('HashTable.mat');
    else  
        msgbox('No song database');
        return;
    end
end

if recordingOn
    % Settings used for recording.
    sampleRate = 44100; % Sample frequency
    bits = 16;  % Bits used per sample

    % Record audio for <duration> seconds.
    recorder = audiorecorder(sampleRate, bits, 2);
    hMsgBox = msgbox('Recording');
    recordblocking(recorder, duration);
    delete(hMsgBox);

    % Store data in Double-precision array.
    sample = getaudiodata(recorder);
end
if selectRandom% Select a random segment
    
    add_noise = 0; % Optionally add noise by making this 1.
    SNRdB = 5; % Signal-to-noise Ratio in dB, if noise is added.  Can be negative.
    
    dir = 'songs'; % This is the folder that the MP3 files are in.
    songs = getMp3List(dir);
    
    % Select random song
    thisSongIndex = ceil(length(songs)*rand);
    filename = strcat(dir, filesep, songs{thisSongIndex});
    [sample, sampleRate] = audioread(filename);
    sample = mean(sample,2);
    sample = sample - mean(sample);
    
    % Select random segment
    if length(sample) > ceil(duration * sampleRate)
        shiftRange = length(sample) - ceil(duration * sampleRate) + 1;
        shift = ceil(shiftRange * rand);
        sample = sample(shift : shift + ceil(duration * sampleRate) - 1);
    end
    
    % Add noise
    if add_noise
        soundPower = mean(sample .^ 2);
        noise = randn(size(sample))*sqrt(soundPower/10^(SNRdB/10));
        sample = sample + noise;
    end
end

% player = audioplayer(sample, sampleRate);
% play(player)
if (saveRecorded)
    audiowrite(recordedFilePath, sample, sampleRate);
end
[sample, sampleRate] = audioread(recordedFilePath);

[bestMatchId, confidence] = MatchAudioSample(sample, sampleRate);