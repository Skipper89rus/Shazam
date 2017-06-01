% В данном примере удаляем звук сирены.
% Сначала получаем пики, затем рекурсивно вырезаем области с большим перепадом
% в значении спектральной мощности.

[audioData, sampleRate] = audioread('..\Data\Traffic (police siren + cars beeps).mp3',[44100*66,44100*70]);
meanChannels = mean(audioData, 2);
dataLength = length(meanChannels);
wndSize = 4096;
wnd = hamming(wndSize);
overlap = wndSize / 2;
fftSize = max(256, 2 ^ nextpow2(wndSize));

[S, freq, time, power] = spectrogram(meanChannels, wnd, overlap, fftSize, sampleRate);
clearvars audioData data meanChannels mask;

kHzFreq = freq / 1000;

shiftMaxStepT = 4;
shiftMaxStepF = 2;
[peaks, freqIds, timeIds] = GetPeaks(power, kHzFreq, shiftMaxStepT, shiftMaxStepF);

for i=1:length(freqIds)
    power = SuppressPointsAroundCurrentPointWithBigDiff(freqIds(i),timeIds(i),power,2e-7,0,10);
end

power = 10 * log10(power);

surf(time, kHzFreq, power, 'edgecolor', 'none');
axis tight;
xlabel('Time (seconds)');
ylabel('Frequences (kHz)');
view(0, 90);  
