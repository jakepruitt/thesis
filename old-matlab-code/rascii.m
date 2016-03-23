function [varargout] = rascii(filename,nHeaderLines,nDataLines)
  %Usage: rascii(filename, nHeaderLines, nDataLines)
  %
  %Reads an ascii file, skipping a user-specified number of header lines before reading a
  %user-specifed number of data lines. Returns output filename (optional).
  %
  %Created: 04/18/2013
  %
  
  %Make sure proper number of arguments are given.
  if nargin ~= 3
    help(rascii);
    return;
  end%if
  %Open input file, generate output filename and open output file.
  fin = fopen(filename);
  [path,name,~] = fileparts(filename);
  if isempty(path)
    foutName = [name,'_out.txt'];
  else
    foutName = [path,'/',name,'_out.txt'];
  end%if
  fout = fopen(foutName,'w');
  %Determine limits for range of data to read.
  dataMin = nHeaderLines + 1;
  dataMax = dataMin + nDataLines;
  %Set current-line counter.
  clc = 0;
  while(~feof(fin))
    %Iterate clc.
    clc = clc + 1;
    %Read line.
    line = fgetl(fin);
    %Write line to output file if within specified range.
    if clc >= dataMin && clc <= dataMax
      fprintf(fout,'%s\n',line);
    end%if
  end%while
  %Close input and output files.
  fclose(fin); fclose(fout);
  %Return output file name if desired.
  if nargout == 1
    varargout{1} = foutName;
  end%if
end%rascii