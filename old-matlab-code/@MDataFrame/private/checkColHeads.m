%checkColHeads subfunction; Check for column headers
%Evenutally may return location of empties for auto-generated col IDs
function importHeads = checkColHeads(initData)
  numColHeadChar = 0; numColHeadNumeric = 0;
  for i = 1:size(initData,2)
    if i == 1 %Make sure this is not a string of spaces. If it is, treat is as numeric.
      if strcmp(strcat(initData{1,i},'test'),'test') == 1
        numColHeadNumeric = numColHeadNumeric + 1;
      else
        numColHeadChar = numColHeadChar + 1;
      end%if
    else
      if ischar(initData{1,i}) == 1 && isempty(initData{1,i}) == 0
        numColHeadChar = numColHeadChar + 1;
      elseif isnumeric(initData{1,i}) == 1
        numColHeadNumeric = numColHeadNumeric + 1;
      end%if
    end%if
  end%for
  if numColHeadNumeric ~= size(initData,2) && numColHeadChar > 1
    if numColHeadChar == size(initData,2)
      importHeads = -1; %Import all column headers.
    else
      importHeads = 1;  %Import column headers, skip first (possibly blank) column.
    end%if
  else
    if numColHeadChar == 1 && ischar(initData{1,1})
      importHeads = -2; %Generate new column headers, skip first column (row IDs present).
    else 
      importHeads = 2;  %Generate new column headers for all columns.
    end%if
  end%if
end%checkColHeads subfunction