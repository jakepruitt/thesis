function data = ingest_ascii(filename,nHeaderLines,nDataLines)
  %Usage: ingest_ascii(filename, nHeaderLines <optional>, nDataLines <optional>)
  %
  %Script to import numeric data from an ascii file utilizing rascii.m to extract the desired lines
  %before using dlmread on the temporary output file. Returns a numeric array of data.
  %
  %Input variables:
  % - filename: path to ascii file to ingest.
  % - nHeaderLines (optional): number of header lines in ascii file to skip. If not specified, will
  % use default value (23, for reading ascii files from interferometer).
  % - nDataLines (optional): number of data lines in ascii file to read. If not specified, will use
  % default value (960, for reading ascii files from interferometer).
  %
  %Created: 04/18/2013
  %
  
  %Initialize parameters based on number of inputs.
  if nargin == 3
    nhl = nHeaderLines; ndl = nDataLines;
  elseif nargin == 1
    nhl = 23; ndl = 960;
  end%if
  %Call rascii.m to create temporary file.
  tempFile = rascii(filename,nhl,ndl);
  %Use dlmread to import data.
  data = dlmread(tempFile);
  %Delete the temporary file.
  delete(tempFile);
end%ingest_ascii