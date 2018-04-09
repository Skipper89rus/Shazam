function [resAudioData] = AddSampleFromFile(audioData, audioFs, samplePath, insertTime)
%   �������� �� audioData ����� �� �����
%       insertTime - ����� ��� �������, �������

[sampleAudioData] = audioread(samplePath);
sampleAudioData = mean(sampleAudioData, 2); % �� ������ ���� ����

insertFs = round(audioFs * insertTime);
if insertFs + length(sampleAudioData) > length(audioData)
    return
end

zerosBefore = zeros(insertFs, 1);
zerosAfter = zeros(length(audioData) - length(sampleAudioData) - length(zerosBefore), 1);
sampleResized = [zerosBefore', sampleAudioData', zerosAfter']';
resAudioData = audioData + sampleResized;

end

