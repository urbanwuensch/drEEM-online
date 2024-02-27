function export2netcdf(data,filename)
filename='example.nc';

flds=fieldnames(data);

nccreate(filename,"myvar", ...
         "Dimensions",{"x",data.nSample,"y",data.nEm,"z",data.nEx},"FillValue","disable")
end