function [ordered_index] = ordering_scheme_tinney1(TA, TAF)
% Initialization parameters
ordered_index = [];
NRow = TA.NRow;
NCol = TA.NCol;
FIR = TAF.FIR;

% Tinney 1 ordering
% calculated the order of A (order_index)
for i = 1:length(FIR)
    order_temp = []; % initialize temporary ordering index
    degree = zeros(1, length(FIR));
    % calculate degree at each node
    for j = 1:length(FIR)
        degree(j) = sum(NRow == j) - 1;
    end
    uni_degrees = unique(degree); % get unique degree number
    for k = uni_degrees
        order_temp = [order_temp, find(degree == k)];
    end
    
    % record current the lowest degree node (the node after reducing the degrees will list at front)
    ordered_index(i) = order_temp(i);
    
    nz_index = NCol(find(NRow == ordered_index(i))); % get correlative node index
    for j = nz_index'
        for k = nz_index'
            if ~ismember(k, NCol(find(NRow == j)))
                NRow(end + 1) = j;
                NCol(end + 1) = k;
            end
        end
    end
    
    % eliminate the current node and reduce the order
    del_index = find(NRow == ordered_index(i));
    NRow(del_index) = [];
    NCol(del_index) = [];
    del_index = find(NCol == ordered_index(i));
    NRow(del_index) = [];
    NCol(del_index) = [];
end

end

