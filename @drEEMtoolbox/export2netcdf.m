function export2netcdf(data,filename)
error('not yet implemented. Urban@work')
filename='example.nc';

flds=fieldnames(data);

nccreate(filename,"myvar", ...
         "Dimensions",{"x",data.nSample,"y",data.nEm,"z",data.nEx},"FillValue","disable")
end