function DebugGettingPeaks()

wndSize = 2048;
wnd = hamming(wndSize);
overlap = wndSize / 2;
fftSize = max(256, 2 ^ nextpow2(wndSize));

[audioData, sampleRate] = audioread('..\Data\Traffic + MyVoice1.wav');
GetSpectrogramOfAudioData(audioData, sampleRate, wnd, overlap, fftSize);

%[myVoiceAudioData, sampleRate] = audioread('..\Data\MyVoice1.wav');
%GetSpectrogramOfAudioData(myVoiceAudioData, sampleRate, wnd, overlap, fftSize);
[S, kHzFreq, time, power] = GetSpectrogramOfAudioData(audioData, sampleRate, wnd, overlap, fftSize);

freqBound = [0, 12];
timeBound = [0.5, 2.2];
peaksIds = GetRectPeaks(power, kHzFreq, time, freqBound, timeBound);

S(peaksIds) = 0;

processedAudioData = GetAudioFromSpectrogram(S, wnd, overlap, fftSize);
audiowrite('..\Data\Processed.wav', processedAudioData, sampleRate);

GetSpectrogramOfAudioData(processedAudioData, sampleRate, wnd, overlap, fftSize);

end

function [S, kHzFreq, time, power] = GetSpectrogramOfAudioData(audioData, sampleRate, wnd, overlap, fftSize)

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