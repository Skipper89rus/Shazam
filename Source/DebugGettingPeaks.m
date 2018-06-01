function DebugGettingPeaks()

fftSettings.wndSize = 2048;
fftSettings.wnd = hamming(fftSettings.wndSize);
fftSettings.overlap = fftSettings.wndSize / 2;
fftSettings.fftSize = max(256, 2 ^ nextpow2(fftSettings.wndSize));

peaksSettings.freqBound = [0, 16000];
peaksSettings.timeBound = [];
peaksSettings.timeStepPercent = 0.08;
peaksSettings.timeOverlapPercent = 0.5;
peaksSettings.flatnessChangeRate = 0.09;

%[kHzFreq, srcTime, srcPower, peaksMask] = GetPeaksFromFile('..\Data\Car beep.wav', fftSettings, peaksSettings, false);
%FindInFile('..\Data\Traffic (police siren + car beep).wav', fftSettings, srcTime, peaksMask, false);

% [freqIds, timeIds] = find(peaksMask);
% [freqIds, timeIds] = OffsetIndexes( freqIds, timeIds, boundedFreqIds(1), boundedTimeIds(1) );
% powerPeaksIds = sub2ind(size(power), freqIds, timeIds);

%peaksSettings.timeStepPercent = 0.05;
[kHzFreq, time, power, peaksIds] = GetPeaksFromFile('..\Data\Traffic (police siren + car beep).wav', fftSettings, peaksSettings, true);

% [audioData] = AddSampleFromFile(audioData, sampleRate, '..\Data\Car beep.mp3', 1);
% audiowrite('..\Data\Car beep.wav', audioData, sampleRate);

% CompareSpectrogramFilters(power, kHzFreq, time, @GaussFilter, @TestFilter);

% [audioData] = AddSampleFromFile(audioData, sampleRate, '..\Data\Car beep.mp3', 1);
% audiowrite('..\Data\Car beep.wav', audioData, sampleRate);

% S(peaksIds) = 0;
% processedAudioData = GetAudioFromSpectrogram(S, wnd, overlap, fftSize);
% audiowrite('..\Data\Processed.wav', processedAudioData, sampleRate);
% GetSpectrogramOfAudioData(processedAudioData, sampleRate, wnd, overlap, fftSize);

end

function [kHzFreq, time, power, peaksMask] = GetPeaksFromFile(audioFile, fftSettings, peaksSettings, visualize)

if visualize
	figure
end

[audioData, sampleRate] = audioread(audioFile);
[S, kHzFreq, time, power] = GetSpectrogramOfAudioData(audioData, sampleRate, fftSettings, visualize);
peaksMask = GetRectPeaks(power, kHzFreq, time, peaksSettings, visualize);

end

function [S, kHzFreq, time, power] = GetSpectrogramOfAudioData(audioData, sampleRate, fftSettings, visualize)

[S, kHzFreq, time, power] = spectrogram(audioData, fftSettings.wnd, fftSettings.overlap, fftSettings.fftSize, sampleRate);
power = TestFilter(power);

if visualize
    ShowSpectrogram(power, kHzFreq, time);
end

end

function FindInFile(audioFile, fftSettings, sampleTime, samplePeaksMask, visualize)

[audioData, sampleRate] = audioread(audioFile);
t = 1.46 + sampleTime(end) - sampleTime(1);
samples = [floor(1.41 * sampleRate), floor(t * sampleRate)];
clear audioData sampleRate
[audioData, sampleRate] = audioread(audioFile, samples);
audioData = mean(audioData, 2);

[S, kHzFreq, time, power] = GetSpectrogramOfAudioData(audioData, sampleRate, fftSettings, true);

sampleTimeSz = length(sampleTime);

peaksSettings.freqBound = [0, 16000];
peaksSettings.timeBound = [];
peaksSettings.timeStepPercent = 0.2;
peaksSettings.timeOverlapPercent = 0.5;

boundedFreqIds = find( kHzFreq >= 0 & kHzFreq <= 16000 );

samplePeaksCount = length( find(samplePeaksMask > 0) );

maxRatio = 1;
maxTimeIdx = 1;
bestPeaksMask = [];
for timeIdx = 1 : length(time)
    if timeIdx + sampleTimeSz - 1 > length(time)
        break;
    end
    
    timeBound.beg = time(timeIdx);
    timeBound.end = time(timeIdx + sampleTimeSz - 1);
    
    boundedTimeIds = find(time >= timeBound.beg & time <= timeBound.end);
    
    peaksMask = GetRectPeaks(power(boundedFreqIds, boundedTimeIds), kHzFreq, time(boundedTimeIds), peaksSettings, visualize);
    
    ratio = length( find((peaksMask & samplePeaksMask) > 0) );
    if ratio > maxRatio
        maxRatio = ratio;
        maxTimeIdx = timeIdx;
        bestPeaksMask = peaksMask & samplePeaksMask;
        fprintf('Match percent = %.2f\n', ratio / samplePeaksCount);
    end
end

bestMatchTime = find( time >= time(maxTimeIdx) & time <= time(maxTimeIdx + sampleTimeSz - 1) );

logPower = 10 * log10(power);
ShowPeaks(logPower, kHzFreq, time, bestPeaksMask, boundedFreqIds(1), bestMatchTime(1), '.g');

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