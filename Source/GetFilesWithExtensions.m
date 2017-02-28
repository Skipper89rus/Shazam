% Найти файлы с расширением из списка extensionsToFind в папке dirPath
function files = GetFilesWithExtensions(dirPath, extToFind)

if isempty(dirPath)
    disp 'Directory path is empty';
    return
end

if ~iscellstr(extToFind)
    disp 'Extensions to find must be a cell strings';
    return
end

listing = dir(dirPath);
filesNum = size(listing, 1);
filesNames = cell([filesNum, 1]);
for i = 1 : filesNum
    filesNames{i} = listing(i).name;
end

files = cell([filesNum, 1]);
counter = 1;
for fileIdx = 1 : filesNum
    if isAudioFile(filesNames{fileIdx}, extToFind)
       files{counter} = fullfile(dirPath, filesNames{fileIdx});
       counter = counter + 1;
    end
end

if counter == 1
    disp 'Files not found'; 
end

% Reduce list to correct length
files = files(1 : counter - 1);
end

function result = isAudioFile(fileName, extToFind)

result = 0;
for extIdx = 1 : size(extToFind)
    if ~isempty( strfind(fileName, extToFind{extIdx}) )
        result = 1;
        break
    end
end

end