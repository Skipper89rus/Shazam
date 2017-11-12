function DebugGettingPeaks()

audioFilePath = '..\Data\Traffic (police siren + cars beeps).mp3';
[audioData, sampleRate] = audioread(audioFilePath);
interval = [sampleRate * 66, sampleRate * 78];
[audioData, sampleRate] = audioread(audioFilePath, interval);
meanChannels = mean(audioData, 2);

wndSize = 2048;
wnd = hamming(wndSize);
overlap = wndSize / 2;
fftSize = max(256, 2 ^ nextpow2(wndSize));
[S, kHzFreq, time, power] = GetSpectrogramOfAudioFile(meanChannels, sampleRate, wnd, overlap, fftSize);

freqBound = [0, 12];
timeBound = [2, 4.4];
peaksIds = GetRectPeaks(power, kHzFreq, time, freqBound, timeBound);

S(peaksIds) = 0;

processedAudioData = GetAudioFromSpectrogram(S, wnd, overlap, fftSize);
audiowrite('..\Data\Processed.wav', processedAudioData, sampleRate)

GetSpectrogramOfAudioFile(processedAudioData, sampleRate, wnd, overlap, fftSize)

end

function [S, kHzFreq, time, power] = GetSpectrogramOfAudioFile(audioData, sampleRate, wnd, overlap, fftSize)

[S, freq, time, power] = spectrogram(audioData, wnd, overlap, fftSize, sampleRate);

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