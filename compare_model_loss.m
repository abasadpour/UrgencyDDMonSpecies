close all; clear
function get_model_statistics(species)

    Model_names = {'case (i)',
        'case (ii)',
        'case (iii)',
        'case (iv)'};
    
    model_data_folder = fullfile('C:\Users\assad\OneDrive - Ulster University\Research projects\Hui''s paper\Real data fit', species);
    base_model_file_name = 'all_models_';
    num_of_models = length(Model_names);
    
    for model_num = 1 : num_of_models
        model_filename = fullfile(model_data_folder,[base_model_file_name num2str(model_num) '.pkl']);
        Model{model_num} = import_model(model_filename);
        [loss_tmp, loss_name] = get_loss_results(Model{model_num});
        loss{model_num} = loss_tmp;
        loss_log(:, model_num) = loss{model_num}(:,1);
        loss_squared(:, model_num) = loss{model_num}(:,2);
    end
    
    p_log = kruskalwallis(loss_log, Model_names);
    ylabel('negative log-likelihood')
    xlabel('Model')
    title(species)
    
    [p_log,tbl_log,stats_log] = kruskalwallis(loss_log);
    c = multcompare(stats_log);
    tbl = array2table(c,"VariableNames", ...
        ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
    
    p_squared = kruskalwallis(loss_squared, Model_names);
    ylabel('Squared Error')
    xlabel('Model')
    
    [p_squared,tbl_squared,stats_squared] = kruskalwallis(loss_squared);
    c_squared = multcompare(stats_squared);
    tbl_squared = array2table(c_squared,"VariableNames", ...
        ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
    title(species)
end