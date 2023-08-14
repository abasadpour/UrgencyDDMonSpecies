function [loss, loss_name] = get_loss_results(Model)
%get_loss_results returns the value of loss functions for each model in Model cell
%   Detailed explanation goes here
loss_name = {'negative log_likelihood', 'Squared Error'};
loss = nan(numel(Model), length(loss_name));
for el_num = 1 : numel(Model)
    loss(el_num,:) = cell2mat(Model{el_num}(3:4));
end

end