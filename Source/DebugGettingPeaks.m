function DebugGettingPeaks()

fftSettings.wndSize = 2048;
fftSettings.wnd = hamming(fftSettings.wndSize);
fftSettings.overlap = fftSettings.wndSize / 2;
fftSettings.fftSize = max(256, 2 ^ nextpow2(fftSettings.wndSize));

peaksSettings.freqBound = [0, 16000];
peaksSettings.timeBound = [];
peaksSettings.timeStepPercent = 0.2;
peaksSettings.timeOverlapPercent = 0.5;

srcPeaksIds = GetPeaksFromFile('..\Data\Car beep.wav', fftSettings, peaksSettings, true);
peaksIds = GetPeaksFromFile('..\Data\Traffic (police siren + car beep).wav', fftSettings, peaksSettings, true);

% samples = [floor(0.4 * sampleRate), floor(1.3 * sampleRate)];
% clear audioData sampleRate
% [audioData, sampleRate] = audioread(audioFile, samples);
% audioData = mean(audioData, 2);

% [audioData] = AddSampleFromFile(audioData, sampleRate, '..\Data\Car beep.mp3', 1);
% audiowrite('..\Data\Car beep.wav', audioData, sampleRate);

%CompareSpectrogramFilters(power, kHzFreq, time, @GaussFilter, @TestFilter);

% [audioData] = AddSampleFromFile(audioData, sampleRate, '..\Data\Car beep.mp3', 1);
% audiowrite('..\Data\Car beep.wav', audioData, sampleRate);

% S(peaksIds) = 0;
% processedAudioData = GetAudioFromSpectrogram(S, wnd, overlap, fftSize);
% audiowrite('..\Data\Processed.wav', processedAudioData, sampleRate);
% GetSpectrogramOfAudioData(processedAudioData, sampleRate, wnd, overlap, fftSize);

end

function [peaksIds] = GetPeaksFromFile(audioFile, fftSettings, peaksSettings, visualize)

if visualize
	figure
end
[audioData, sampleRate] = audioread(audioFile);
[S, kHzFreq, time, power] = GetSpectrogramOfAudioData(audioData, sampleRate, fftSettings, visualize);
peaksIds = GetRectPeaks(power, kHzFreq, time, peaksSettings, visualize);

end

function [S, kHzFreq, time, power] = GetSpectrogramOfAudioData(audioData, sampleRate, fftSettings, visualize)

[S, kHzFreq, time, power] = spectrogram(audioData, fftSettings.wnd, fftSettings.overlap, fftSettings.fftSize, sampleRate);
power = GaussFilter(power);
if visualize
    ShowSpectrogram(power, kHzFreq, time);
end

end

function CompareSpectrogramFilters(power, kHzFreq, time, filter1, filter2)

subplot(1, 2, 1);
ShowSpectrogram(filter1(power), kHzFreq, time);
title('Filter 1');

subplot(1, 2, 2);
ShowSpectrogram(filter2(power), kHzFreq, time);
title('Filter 2');

end

function [filtered] = GaussFilter(power)
filtered = imgaussfilt(power, 1);
end

function [filtered] = TestFilter(power)
filtered = power;
% PSF=fspecial('gaussian', 2, 2);
% filtered=imfilter(filtered, PSF, 'symmetric', 'conv');
% filtered(230:500, :) = ordfilt2(filtered(230:500, :), 4, ones(4, 4));
% %%%%%%%%%%%%%%%%%%%% Винер на высоких, линечный на всех
filtered(200:500, :) = wiener2(filtered(200:500, :), [3 3]);
b=fir1(4, 0.00001);
%freqz(b, 4, 1024);
h=ftrans2(b);
filtered=filter2(h, filtered);
filtered=imadjust(filtered, [0 75]/255, [ ], 10);

end

function ShowSpectrogram(power, kHzFreq, time)

freq = kHzFreq / 1000;
logPower = 10 * log10(power);

surf(time, freq, logPower, 'edgecolor', 'none');
axis tight;
xlabel('Time (seconds)');
ylabel('Frequences (kHz)');
view(0, 90);
ylim([0, 16]);

end