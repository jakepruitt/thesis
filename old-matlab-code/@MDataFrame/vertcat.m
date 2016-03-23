function mdf = vertcat(mdf,mdfObj)
  %Usage: mdf = vertCat(mdf,mdfObj)
  %
  %MDataFrame function to vertically concatenate two MDataFrame objects. NOTE: vertcat will only
  %concatenate colnames, rownames, data, and notes between the two objects; metadata WILL NOT BE
  %PRESERVED. To preserve metadata, use the mdf.merge function.
  %
  %Written 09/02/2012
  %
  
  %Make sure that size(*.colnames,2) and size(*.data,2) in mdf and mdfObj are equal, then vertcat.
  if size(mdf.colnames,2) == size(mdfObj.colnames,2) && size(mdf.data,2) == size(mdfObj.data,2)
    %Generate initData cell arrays.
    [mdfInitData,mdfObjInitData] = genInitData(mdf,mdfObj);
    %Vertcat mdf above mdfObj.
    mdfInitData = [mdfInitData;mdfObjInitData(2:end,:)];
    %Construct new MDataFrame object and assign to mdf. Clear mdfObj.
    mdf = MDataFrame(mdfInitData); clear mdfObj;
  else
    %Throw error and return.
    fprintf('\nError: The horizontal dimensions of the MDataFrame objects do not match.\n');
    return;
  end%if
end%vertcat function

%Subfunctions
%genInitData subfunction.
function [initMdf,initMdfObj] = genInitData(mdf,mdfObj)
  %Collect colnames, rownames, data, and notes (if needed) into cell array (initData) for both mdf
  %and mdfObj for use in concatenating MDataFrame objects.
  if size(mdf.notes,2) > 0
    initMdf = [[blanks(2),mdf.colnames];[mdf.rownames,num2cell(mdf.data),mdf.notes]];
  else
    initMdf = [[blanks(2),mdf.colnames];[mdf.rownames,num2cell(mdf.data)]];
  end%if
  if size(mdfObj.notes,2) > 0
    initMdfObj = [[blanks(2),mdfObj.colnames];[mdfObj.rownames,num2cell(mdfObj.data),mdfObj.notes]];
  else
    initMdfObj = [[blanks(2),mdfObj.colnames];[mdfObj.rownames,num2cell(mdfObj.data)]];
  end%if
end%genInitData subfunction