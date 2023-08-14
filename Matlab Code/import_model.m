function Model = import_model(filename)
%import_model import a python model list into MATLAB
% filename = 'C:\Users\assad\OneDrive - Ulster University\Research projects\Hui''s paper\Real data fit\Human\all_models_sample.pkl';
fid = py.open(filename,'rb');
data = py.pickle.load(fid);
Model = list2cell(data);