%Найти файлы с расширением из списка extensionsToFind в папке dirPath

function files = GetFilesWithExtensions(dirPath, extToFind)

if isempty(dirPath)    			%Проверка на тот случай, если папка пуста
    disp 'Directory path is empty';
    return
end

if ~iscellstr(extToFind)		%Проверяем, является ли это массивом ячеек для строк
    disp 'Extensions to find must be a cell strings';
    return
end

listing = dir(dirPath);			%Выводим содержимое в указанной папке
filesNum = size(listing, 1);	%Получаем длину размерности содержимого папки, dim =1
filesNames = cell([filesNum, 1]);	%Создаем массив ячеек
for i = 1 : filesNum
    filesNames{i} = listing(i).name;	%Помещаем в созданный массив наименование файлов
end

files = cell([filesNum, 1]);	%Создаем еще один массив ячеек
counter = 1;
for fileIdx = 1 : filesNum		
    if isAudioFile(filesNames{fileIdx}, extToFind)	%Ищем аудиофайлы 
       files{counter} = fullfile(dirPath, filesNames{fileIdx}); 	%В ново-созданный массив ячеек загружаем полное имя файла
       counter = counter + 1;
    end
end

if counter == 1	
    disp 'Files not found'; 	%Аудиофайлы не найдены
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