function [resAudioData] = AddSampleFromFile(audioData, audioFs, samplePath, insertTime)
%   Наложить на audioData сэмпл из файла
%       insertTime - время для вставки, секунды

[sampleAudioData] = audioread(samplePath);
sampleAudioData = mean(sampleAudioData, 2); % Не делать если моно

insertFs = round(audioFs * insertTime);
if insertFs + length(sampleAudioData) > length(audioData)
    return
end

zerosBefore = zeros(insertFs, 1);
zerosAfter = zeros(length(audioData) - length(sampleAudioData) - length(zerosBefore), 1);
sampleResized = [zerosBefore', sampleAudioData', zerosAfter']';
resAudioData = audioData + sampleResized;

end

