function [ordered_index] = ordering_scheme_tinney0(TA, TAF)
% Initialization parameters
ordered_index = [];
degree = zeros(1, length(TAF.FIR));

% Tinney 0 ordering
% calculate degree at each node
for i = 1:length(TAF.FIR)
    degree(i) = sum(TA.NRow == i) - 1;
end
%degree = sum(A ~= 0) - 1; % get degree for each node
uni_degrees = unique(degree); % get unique degree number

% sort nodes in degree order (in case of tie, keep natural order)
for k = uni_degrees
    ordered_index = [ordered_index, find(degree == k)]; % order nodes from the lowest degree
end
end