function changestatus(data)
    % Get input name
    x_name = inputname(1);
    
    % Start app with names
    handle=setstatus(data, x_name);
    waitfor(handle,"finishedHere",true);
    try
        dataout=handle.data;
        delete(handle)
    catch
        error('setstatus closed before save & exit button was pushed.')
    end
    assignin("base",x_name,dataout)
    disp(['Data status of ',char(x_name),' changed (Workspace variable replaced with updated version).'])
end