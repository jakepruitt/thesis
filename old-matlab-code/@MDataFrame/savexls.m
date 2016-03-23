%savexls function
function savexls(mdf,fileName)
  if nargin == 2 %Use filename provided by the user.
    destFileName = fileName;
  else %Generate default filename.
    destFileName = ['mdf_',mdf.datasetName,'_',datestr(now,'mm_dd_yyyy'),'.xls'];
  end%if
  %Need to iterate the sheet
  xlswrite(destFileName,mdf.initData,mdf.datasetType);
end%savexls function