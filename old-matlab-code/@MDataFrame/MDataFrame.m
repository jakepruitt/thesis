% MDataFrame v0.8
%
% USAGE: object = MDataFrame(<datasource>,<delimiter (opt)>,<comment (opt)>)
%   - datasource may be a filename, filepath, numeric matrix, or cell array.
%   - delimiter is a comma ',' by default, but may be user specified.
%   - comment is a character or string that marks information to be ignored when reading a file.
%
% PROPERTIES:
%   - version - Current version of MDataFrame.
%   - dsCount - Number of datasets merged into MDataFrame object.
%   - dataSource - Stores original filepath, matrix, or cell array passed by the user when
%   constructing an MDataFrame object.
%   - datasetType - Intended for use with MATGeo et al. A description of the type of data stored in
%   the MDataFrame object.
%   - datasetName - Intended for use with MATGeo et al. User-defined label for the dataset.
%   - delim - Default delimiter for the MDataFrame object (',').
%   - comment - Character or string that marks lines to be ignored when reading a file.
%   - sampleInfo - Intended for use with MATGeo et al. Will store a structure of tag-value pairs of
%   information (metadata) defined at the top of a delimited file within "Begin Sample Info" and 
%   "End Sample Info" markers placed before data to be stored in MDataFrame object.
%   - dataInfo - Intended for use with MATGeo et al. Will store a structure of tag-value pairs of
%   information (metadata) defined at the top of a delimited file within "Begin Data Info" and 
%   "End Data Info" markers placed before data to be stored in MDataFrame object.
%   - colnames - Stores column header names for numeric data and notes in MDataFrame object.
%   - rownames - Stores row names for numeric data and notes in MDataFrame object.
%   - initData - Used during construction of MDataFrame object; cleared following construction.
%   - data - Stores numeric data in MDataFrame object.
%   - notes - Stores text information associated with rows of numeric data in MDataFrame object.
%   - noteColNames - Stores column header names of text notes only (not of numeric data).
% 
% METHODS:
%   - disp(mdf,varargin) - Prints contents of MDataFrame object (colnames, rownames, data, notes) to
%   standard output in Matlab environment.
%     - Optional Arguments: pass as tag-value pairs.
%       - ('decimals',<integer value>) - Specify number of decimals to display.
%       - ('format',<'scientific' || 'sci'>) - Display data in scientific notation.
%   - save(mdf,varargin) - Saves contents of MDataFrame object to delimited file.
%     - Optional Arguments: pass as tag-value pairs.
%       - ('filename',<string>)
%       - ('path',<string>)
%       - ('delimiter',<string>)
%       - ('permission',<string>)
%       - ('mods',<1 || 0>)
%   - mdf = merge(mdf,mdfObj) - Merges the contents of two MDataFrame objects.
%   - size(mdf) - Returns size of numeric data in object, mdf.data.
%   - vertcat(mdf,mdfObj) - Vertically concatenates two MDataFrame objects that have the same number
%   of columns. No metadata (mdf properties) are preserved. Assumes column names are identical.
%   - merge(mdf,mdfObj) - Vertically concatenates two MDataFrame objects intelligently to preserve
%   all metadata and all columns of data. Can handle mdf objects that are different in size and that
%   have different column headers.
%
% AUTHOR: Cameron M. Mercer, Graduate Student
%   School of Earth and	Space Exploration
%   Arizona State University
%   Tempe, AZ 85287
%   
% COPYRIGHT © 2012, Cameron M. Mercer
%   - MDataFrame is intended for use in education and scientific research, not for commercial use.
%   If you use the MDataFrame object in an educational or scientific setting, you may distribute 
%   and/or modify the source code to suite your purposes. I would appreciate it if you would also
%   include a reference or acknowledgment of the MDataFrame object.
% 
% PURPOSE:
%   Object designed to contain a matrix of numeric data with associated header labels, row ID
%   labels, and notes. MDataFrame is intended to be used on its own, or in conjunction with 
%   MATGeo, mgGUI, MDataHandler and MDManipulator.
%
% INSPIRATION:
%   This data object was inspired by the GNU Octave dataframe object, written by Pascal Dupuis,
%   which was itself inspired by the data.frame structure in R. This function relies upon Peder 
%   Axensten's readtext.m script (available on Matlab Central File Exchange). 
%
% VERSION DEVELOPMENT:
%   Commenced - 09/03/2012
%   Completed - 
%
% VERSION HISTORY:
%   - v0.0 - Completed 10/19/2011
%     - Allowed csv file to be imported and displayed nicely.
%   - v0.1 - Completed 10/29/2011
%     - mdf.data now numeric matrix rather than cell array.
%     - Display function now adjusts to ID label width.
%     - Built functions to report mdf size and version number.
%     - Can now import cell array of data, replacing empty or non-numeric elements of mdf.data
%     with zeros with permission of the user.
%     - New object property: datasetName.
%     - Functions added to return column and row names.
%   - v0.2 - Completed 12/09/2011
%     - Delimiters may be passed as optional argument to MDataFrame; always passed from
%     PREFS.ddel from MDataHandler.
%     - Reworked how information in mdf.initData is binned, allows for notes/mixed numeric
%     and string data to right of mdf.data. New properties: notes, noteColNames.
%     - Updated display function to deal with presence of notes.
%   - v0.3 - Completed 01/07/2012
%     - Can save MDataFrame content to text file using delimiter stored in mdf.delim. May
%     pass user-specified filename, or else saves using a default filename.
%     - Added datasetType property to store 'Data:', 'High Uncertainty', etc. modifiers
%     for displaying and saving the dataframe.
%     - Added sourceFileName property, so if dataSource is a file, the name is stored for
%     use when exporting later (always present in copy of raw data in MDataHandler).
%     - save function now accepts tag-value pairs, e.g. 'delimiter','xyz', etc.
%   - v0.4 - Completed 02/23/2012
%     - Added ability to specify tag-value pairs when displaying MDataFrame.
%     - Tweaked save function; can export values with up to 15 characters after the decimal.
%     - Can now specify display format using tag-value pairs when calling disp.
%     - Began merger into MATGeo superclass, began gui development.
%   - v0.5 - Completed 03/31/2012
%     - Moduluarized: major methods are stored as separate files, some in private folder.
%     - Functional! May still use MDataFrame in the command line.
%     - Updated constructor function; can import numerical matrix of data.
%     - Updated checkColHeads, checkRowNames, binInfo private functions; can now import
%     cell array data with or without row/column heads.
%   - v0.6 - Completed 04/26/2012
%     - New private function, 'readSampleInfo', added to gather sample and dataset information
%     from input file or cell array, if they are present.
%     - New properties, sampleInfo and dataInfo, to store information in structures. There can
%     be any number of fields as long as they come in field/value pairs in the input source.
%     - Updated importing for matrixes; they no longer have to be square to import.
%     - Version completed prior to major updates.
%   - v0.7 - Completed 09/03/2012
%     - Refined properties: added dsCount to track merged mdf objects; more efficient use of
%     dataSource property; removed sourceFileName property.
%     - Expanded text displayed when user types 'help MDataFrame'.
%     - Created vertcat function. Does not preserve metadata of concatenated mdf objects.
%     - Created merge function. Can merge two mdf objects intelligently such that datasets with
%     different numbers of columns and different column names will merge without losing data.
%     - Updated display function: prints all datasetName: datasetType contents of cell arrays.
%   - v0.8 - Completed ---
%     - Made the version number a constant property so an instance of MDataFrame does not need to be
%     created to get the version number.
%     - Updated save script to properly handle alternate delimiters (e.g. \t), and to write metadata
%     to the saved file (i.e. sampleInfo and dataInfo).
%     - 
%
% TO DO:
%   - Update savexls function to take tag-value pairs in a varargin (e.g.
%   'path','some/string','delimiter','xyz',etc.)
%   - Make function to display only notes, with row names and noteColNames.
%   - Make MDataHandler PREF field to suppress display of notes &/or source info.
%   - Make optional arguments tag-value pairs, will be more intuitive.
%   - Allow parts of the MDataFrame to be called with index specifiers (e.g. a(1:2,2:5)); make a
%   different function to allow selection of subparts of the MDataFrame (see subsasgn, subsref)
%     - Along these lines, add functionality similar to df.colname, df.rowname, which returned
%     either the column or row corresponding to colname or rowname, respectively.
%   - Allow the display function to give variable type by row/column,
%     and to adjust the field width based on max # characters in dataset.
%   - Add 'isEmpty' function
%
classdef MDataFrame
  properties (Constant)
    version = '0.8';
  end%public properties
  properties
    dsCount = 0;                %Record number of datasets merged into mdf object.
    dataSource = 'void';        %Possible classes: char, double, cell.
    datasetType = 'void';       
    datasetName = 'void';       
    delim = ',';                %Default delimiter.
    comment = '';               
    sampleInfo = [];            
    dataInfo = [];              
    colnames;                   
    rownames;                   
    initData;                   
    data;                       
    notes;                      
    noteColNames;               
  end%End properties list
  
  methods
    function mdf = MDataFrame(dataSource,delimiter,comment) %Constructor.
      if nargin < 1
        disp('Usage: MDataFrame <"dataSource","delimiter (optional)","comment (optional)">');
        return;
      end%if
      mdf.dataSource = dataSource;
      %Set custom delimiter if provided
      if nargin >= 2, mdf.delim = delimiter; end%if
      if nargin >= 3, mdf.comment = comment; end%if
      %Determine if dataSource is file, matrix, or cell array.
      switch class(mdf.dataSource)
        case 'char'
          %Make sure input string is a file.
          if exist(mdf.dataSource,'file') == 2
            %inputType = 3;
            %Make sure that the path is included with the filename in case user only passed a name.
            [path,name,ext] = fileparts(mdf.dataSource);
            if isempty(path)
              %Assume that the file is in the same directory as @MDataFrame.
              path = pwd;
            end%if
            %Save parts of filename and path.
            mdf.dataSource = [path,'/',name,ext];
            clear path name ext;
            %Read in data from file.
            mdf.initData = readtext(mdf.dataSource,mdf.delim,mdf.comment,'','empty2zero');
            %Read sample and dataset information, if they exist.
            [mdf.sampleInfo,mdf.dataInfo,upperBound] = readSampleInfo(mdf.initData);
            %Bin data from mdf.initData
            [mdf.data,mdf.colnames,mdf.rownames,mdf.notes,...
              mdf.noteColNames] = binInfo(mdf.initData(upperBound+1:end,:));
            %Iterate mdf.dsCount, and set mdf.initData to empty.
            mdf.dsCount = mdf.dsCount + 1; mdf.initData = [];
          else
            %inputType = 0;
            fprintf('\nError: ''%s'' is not a file, matrix, or cell array.\n', mdf.dataSource);
          end%if
        case 'double'
          %Make sure input is a matrix
          if ismatrix(mdf.dataSource) == 1
            %inputType = 2;
            %Auto-generate column labels and row IDs.
            mdf.rownames = cell(size(mdf.dataSource,1),1);
            mdf.colnames = cell(1,size(mdf.dataSource,2));
            for i = 1:size(mdf.dataSource,1)
              mdf.rownames{i,1} = ['r',num2str(i)];
            end%for
            for j = 1:size(mdf.dataSource,2)
              mdf.colnames{1,j} = ['c',num2str(j)];
            end%for
            %Set mdf.data.
            mdf.data = mdf.dataSource;
            %Iterate mdf.dsCount.
            mdf.dsCount = mdf.dsCount + 1;
          else
            % inputType = 0;
            fprintf('\nError: ''%s'' is not a file, matrix, or cell array.\n', mdf.dataSource);
          end%if
        case 'cell'
          %inputType = 1;
          %Read sample and dataset information, if they exist.
          [mdf.sampleInfo,mdf.dataInfo,upperBound] = readSampleInfo(mdf.dataSource);
          %Bin data from mdf.initData
          [mdf.data,mdf.colnames,mdf.rownames,mdf.notes,...
            mdf.noteColNames] = binInfo(mdf.dataSource(upperBound+1:end,:));
          %Iterate mdf.dsCount.
          mdf.dsCount = mdf.dsCount + 1;
        otherwise
          fprintf('\nError: ''%s'' is not a file, matrix, or cell array.\n', mdf.dataSource);
      end%switch
    end%mdf constructor
    
    %List of methods in separate files.
    disp(mdf,varargin);
    save(mdf,varargin);
    savexls(mdf,filename);
    mdf = merge(mdf,mdfObj);
    
    %Short utility functions.
    %Returns size of MDataFrame
    function sizeOut = size(mdf,varargin)
      if nargin == 1
        sizeOut = size(mdf.data);
      elseif nargin == 2
        sizeOut = size(mdf.data,varargin{1});
      end%if
    end%size function
    
    function printVersion(mdf)
      fprintf('Thank you for using MDataFrame v%s\n\n',mdf.version);
    end%printVersion method
  end%methods
  
  methods (Access = private)
    %List of private methods in separate files.
    [data,result] = readtext(text,delimiter,comment,quotes,options);
    [sampleInfo,dataInfo,upperBound] = readSampleInfo(initData);
    [data,colnames,rownames,notes,noteColNames] = binInfo(initData);
    importHeads = checkColHeads(initData);
    importRowNames = checkRowNames(initData);
    dcub = findDCUB(initData,dclb,drlb,drub);
    choice = yes_no(question)
  end%private methods.
  
end%MDataFrame class definition