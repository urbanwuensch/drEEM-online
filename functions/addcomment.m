function addcomment(data,comment)

arguments
    data ...
        (1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    comment (1,:) {mustBeText}
end

outname=inputname(1);
idx=height(data.history);
dataout=data;
if not(dataout.history(idx).usercomment=="") % Add an entry
    idx=height(data.history)+1;
    dataout.history(idx,1)=...
        drEEMhistory.addEntry('usercomment',"user-added comment");
    dataout.history(idx).usercomment=string(comment);
else % New entry
    dataout.history(idx).usercomment=string(comment);
end
assignin("base",outname,dataout)

end