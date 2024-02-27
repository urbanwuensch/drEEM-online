function addcomment(data,comment)

arguments
    data ...
        (1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    comment (1,:) {mustBeText}
end

outname=inputname(1);
idx=height(data.history);
dataout=data;
dataout.history(idx).usercomment=comment;
assignin("base",outname,dataout)

end