%% printLookupTableC.m
% *Summary:* Exports look-up table parametrized by the number of X points,
% the spacing between this points, and the corresponding Y points into a C
% header file and array.
%
% lookupTable2arrayFile(nX, deltaX, Y)
%
% *Input arguments:*
%   -sampleT: lookup table sample time
%   -nX: number of X axis data points in the look-up table
%   -deltaX: spacing between the X axis data points
%   -Y: Y axis data points
%
% The output files can be called in the controller main function in the
% following manner:
%   #include "lookupTable.h"
%   int lookupTableSize; returnLookUpTableSize(&lookupTableSize);
%   float lookupTableDX; int lookupTableY[lookupTableSize];
%   returnLookUpTableData(&lookupTableDX, lookupTableY);
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%
function printLookupTableC(sampleT, nX, deltaX, Y)
    % Make Y look-up table integers
    Y = round(Y);
    
    % Create header file
    headerID = fopen('lookupTable.h', 'w');
    fprintf(headerID, '#ifndef LOOKUPTABLE_\n');
    fprintf(headerID, '#define LOOKUPTABLE_\n\n');
    fprintf(headerID, '#define tableSize %d\n\n', nX);
    fprintf(headerID, 'void returnPolSampleT(float *sampleT);\n');
    fprintf(headerID, 'void returnLookUpTableData(float *dx, int yarray[]);\n');
    fprintf(headerID, '\n#endif\n');
	fclose(headerID);
    disp 'lookupTable.h created'
    
    % Create .c file
    cID = fopen('lookupTable.c', 'w');
    fprintf(cID, '#include "lookupTable.h"\n\n');
    fprintf(headerID, 'void returnPolSampleT(float *sampleT){\n');
    fprintf(headerID, '\t(*sampleT) = %f;\n}\n\n', sampleT);
    fprintf(cID, 'void returnLookUpTableData(float *dx, int yarray[]){\n');
    fprintf(cID, '\t*dx = %f;\n', deltaX);
    for i = 1:nX
    	fprintf(cID, '\t*(yarray + %d) = %d;\n', i-1, Y(i));
    end
    fprintf(cID, '}\n');
    fclose(cID);
    disp 'lookupTable.c created'
end