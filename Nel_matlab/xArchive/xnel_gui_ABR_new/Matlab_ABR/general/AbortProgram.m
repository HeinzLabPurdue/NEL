function AbortProgram(script)
%Confirms exit via window close function

answer = questdlg(['Normal exits must use CLOSE button. Continue?'],['Close Error'],'No');
if (strcmp(answer,'Yes'))
    eval([script]);
    disp(['Illegal exit from ' prog '.']);
    delete(gcf);
end
