function tuples = GetFingerprint(audioData, sampleRate, needVisualise)

meanChannels = mean(audioData, 2);
%newSampleRate = 8000;
%resampledData = resample(meanChannels, sampleRate, newSampleRate);

data = meanChannels;
dataLength = length(data);
wndSize = 2048; %floor(dataLength / 4.5);
wnd = hamming(wndSize);
overlap = wndSize / 2;
fftSize = max(256, 2 ^ nextpow2(wndSize));

[S, freq, time, power] = spectrogram(data, wnd, overlap, fftSize, sampleRate);

logPower = 10 * log10(power);
kHzFreq = freq / 1000;

if (needVisualise)
    surf(time, kHzFreq, logPower, 'edgecolor', 'none');
    axis tight;
    xlabel('Time (seconds)');
    ylabel('Frequences (kHz)');
    view(0, 90);
end

shiftRectHalfSize = 4;
[peaks, freqIds, timeIds] = GetPeaks(power, shiftRectHalfSize);

P = power(sub2ind(size(power), freqIds, timeIds));
T = time(timeIds);
F = kHzFreq(freqIds);

if (needVisualise)
    hold on
    scatter3(T, F, P, '*r');
    hold off
end

deltaTime = 35; % bound on time difference (in pixels)
deltaFreq = 30; % bound on frequency difference (in pixels)
fanout = 3; % Maximum number of pairs per peak.
tuples = GetTuples(power .* peaks, fanout, deltaTime, deltaFreq);

if (needVisualise)
    hold on
    for i = 1:size(tuples,1)
        line([time(tuples(i,1)), time(tuples(i,2))], [kHzFreq(tuples(i,3)), kHzFreq(tuples(i,4))])
    end
    hold off
end

end

