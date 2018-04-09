function DebugGettingPeaks()

wndSize = 2048;
wnd = hamming(wndSize);
overlap = wndSize / 2;
fftSize = max(256, 2 ^ nextpow2(wndSize));

[audioData, sampleRate] = audioread('..\Data\Traffic (police siren + car beep).wav');
GetSpectrogramOfAudioData(audioData, sampleRate, wnd, overlap, fftSize);

[audioData] = AddSampleFromFile(audioData, sampleRate, '..\Data\Car beep.mp3', 1);
audiowrite('..\Data\Traffic (police siren + car beep).wav', audioData, sampleRate);

[S, kHzFreq, time, logPower] = GetSpectrogramOfAudioData(audioData, sampleRate, wnd, overlap, fftSize);

freqBound = [];
timeBound = [];
peaksIds = GetRectPeaks(logPower, kHzFreq, time, freqBound, timeBound);

S(peaksIds) = 0;

processedAudioData = GetAudioFromSpectrogram(S, wnd, overlap, fftSize);
audiowrite('..\Data\Processed.wav', processedAudioData, sampleRate);

GetSpectrogramOfAudioData(processedAudioData, sampleRate, wnd, overlap, fftSize);

end

function [S, kHzFreq, time, logPower] = GetSpectrogramOfAudioData(audioData, sampleRate, wnd, overlap, fftSize)

[S, freq, time, power] = spectrogram(audioData, wnd, overlap, fftSize, sampleRate);
% Сглаживаем фильтром Гаусса
power = imgaussfilt(power);

logPower = 10 * log10(power);
kHzFreq = freq / 1000;
ShowSpectrogram(logPower, kHzFreq, time);

end

function ShowSpectrogram(logPower, kHzFreq, time)

surf(time, kHzFreq, logPower, 'edgecolor', 'none');
axis tight;
xlabel('Time (seconds)');
ylabel('Frequences (kHz)');
view(0, 90);

end