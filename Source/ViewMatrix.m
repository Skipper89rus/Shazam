function ViewMatrix(matrix)

imagesc(matrix);              %# Create a colored plot of the matrix values
matrixXSz = size(matrix, 2);
matrixYSz = size(matrix, 1);
colormap(flipud(gray));  %# Change the colormap to gray (so higher values are
                         %#   black and lower values are white)

textStrings = num2str(matrix(:),'%0.2f');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding

[x,y] = meshgrid(1:matrixXSz, 1:matrixYSz);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(matrix(:) > midValue, 1, 3);    %# Choose white or black for the
                                                    %#   text color of the strings so
                                                    %#   they can be easily seen over
                                                    %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors
end

