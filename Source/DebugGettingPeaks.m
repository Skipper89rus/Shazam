function DebugGettingPeaks()

wndSize = 2048;
wnd = hamming(wndSize);
overlap = wndSize / 2;
fftSize = max(256, 2 ^ nextpow2(wndSize));

[audioData, sampleRate] = audioread('..\Data\Traffic (police siren + car beep).wav');
GetSpectrogramOfAudioData(audioData, sampleRate, wnd, overlap, fftSize);

% [audioData] = AddSampleFromFile(audioData, sampleRate, '..\Data\Car beep.mp3', 1);
% audiowrite('..\Data\Traffic (police siren + car beep).wav', audioData, sampleRate);

[S, kHzFreq, time, power] = GetSpectrogramOfAudioData(audioData, sampleRate, wnd, overlap, fftSize);

freqBound = [0, 16000];
timeBound = [0, 3.8];
timeStep = 0.5;
timeOverlap = 0.5;
peaksIds = GetRectPeaks(power, kHzFreq, time, freqBound, timeBound, timeStep, timeOverlap);

S(peaksIds) = 0;

processedAudioData = GetAudioFromSpectrogram(S, wnd, overlap, fftSize);
audiowrite('..\Data\Processed.wav', processedAudioData, sampleRate);

GetSpectrogramOfAudioData(processedAudioData, sampleRate, wnd, overlap, fftSize);

end

function [S, kHzFreq, time, power] = GetSpectrogramOfAudioData(audioData, sampleRate, wnd, overlap, fftSize)

[S, kHzFreq, time, power] = spectrogram(audioData, wnd, overlap, fftSize, sampleRate);
% Сглаживаем фильтром Гаусса
power = imgaussfilt(power, 1);
ShowSpectrogram(power, kHzFreq, time);

end

function ShowSpectrogram(power, kHzFreq, time)

freq = kHzFreq / 1000;
logPower = 10 * log10(power);

surf(time, freq, logPower, 'edgecolor', 'none');
axis tight;
xlabel('Time (seconds)');
ylabel('Frequences (kHz)');
view(0, 90);

end