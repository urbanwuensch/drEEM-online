function fmax = scores2fmax(data,f)
% <a href = "matlab:doc scores2fmax">fmax = scores2fmax(data,f) (click to access documentation)</a>
%
% <strong>Inputs - Required</strong>
% data (1,1) {mustBeA('drEEMdataset'),drEEMdataset.validate}
% f (1,1)    {drEEMdataset.mustBeModel}
%
% <strong>EXAMPLE(S)</strong>
%   fmax = tbx.scores2fmax(newSamples,5)
arguments
    data (1,1) {mustBeA(data,'drEEMdataset'),drEEMdataset.validate(data)}
    f (1,1) {drEEMdataset.mustBeModel(data,f)}
end
model=data.models(f);
scores=model.loads{1};
fmax=nan(data.nSample,f);
for j=1:size(scores,1)
    fmax(j,:)=(scores(j,:)).*(max(model.loads{2}).*max(model.loads{3}));
end


end