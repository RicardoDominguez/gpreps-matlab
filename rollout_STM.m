system(['UV4 -b ', UV_folder]); % Build project
system(['UV4 -f ', UV_folder]); % Flash project
system(STMstudioLogExe);