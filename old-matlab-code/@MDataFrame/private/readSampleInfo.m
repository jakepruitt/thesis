function [sampleInfo,dataInfo,upperBound] = readSampleInfo(initData)
%usage: [sampleInfo,dataInfo,upperBound] = readSampleDataInfo(<initial data(cell array)>)
%
%Private function 'readSampleInfo' for MDataFrame.
%Written - 04/26/2012
%

%Initialize upperBound to zero; update if sample and/or dataset information are available.
upperBound = 0; sampleInfo = []; dataInfo = [];
%Read sample information, if it is present.
if strcmp(initData{1,1},'Begin Sample Info')
  %Find row bounds for sample information.
  silb = 2;             %silb = sample information lower bound.
  siub = silb;          %siub = sample information upper bound.
  while ~strcmp(initData{siub+1,1},'End Sample Info')
    siub = siub + 1;
  end%while
  %Build fields of sampleInfo structure.
  sampleInfo = struct;
  for i = silb:siub
    sampleInfo.(initData{i,1}) = initData{i,2};
  end%for
  %Update upperBound.
  upperBound = upperBound + siub + 1;
else
  siub = -1; %Initialize for assignment to dilb (see below).
end%if
%Read dataset information, if it is present.
if strcmp(initData{siub+2},'Begin Data Info')
  %Find row bounds for dataset information.
    dilb = siub + 3;    %dilb = dataset information lower bound.
    diub = dilb;        %diub = dataset information upper bound.
  while ~strcmp(initData{diub+1,1},'End Data Info')
    diub = diub + 1;
  end%while
  %Build fields of dataInfo structure.
  dataInfo = struct;
  for j = dilb:diub
    dataInfo.(initData{j,1}) = initData{j,2};
  end%for
  %Update upperBound.
  if siub == -1
    upperBound = upperBound + diub + 1;
  else
    upperBound = upperBound + diub - siub;
  end%if
end%if
end%readSampleInfo function