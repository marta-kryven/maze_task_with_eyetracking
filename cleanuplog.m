%-----------------------------------------------------------------------
%
% cleanup log by removing all dublicated redundant lines
%
%-----------------------------------------------------------------------

filemane = '/Users/luckyfish/Downloads/test_solving_log_full_run.txt';
cleanfile = '/Users/luckyfish/Downloads/log_full_run.txt';

fileID = fopen(filemane,'r');
fileID1 = fopen(cleanfile,'w');

l = fgetl(fileID);
oldl = '';

while length(l) > 2
   if ~strcmp(l, oldl) 
       fprintf(fileID1, '%s\n', l);
       oldl = l;
       
   end
   
   l = fgetl(fileID);
end
    

fclose(fileID);
fclose(fileID1);