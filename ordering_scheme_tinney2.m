function [ordered_index] = ordering_scheme_tinney2(TA, TAF)
% Initialization parameters
ordered_index = [];
NRow = TA.NRow;
NCol = TA.NCol;
FIR = TAF.FIR;

% Tinney 2 ordering
% calculated the order of A (order_index)
for i = 1:length(FIR)
    % Initialization parameters
    fills = zeros(1, length(FIR));
    order_temp = []; % initialize temporary ordering index
    
    % calculate degree at each node
    for j = 1:length(FIR)
        degree(j) = sum(NRow == j) - 1;
    end
    uni_degrees = unique(degree); % get unique degree number
    for k = uni_degrees
        order_temp = [order_temp, find(degree == k)];
    end
    
    for n = 1:length(FIR)
        NRow_temp = NRow;
        NCol_temp = NCol;
        
        nz_index = find(NRow_temp == n); % get correlative nodes
        nz_index(NCol_temp(nz_index) == n) = []; % remove the current node
        
        for j = NCol_temp(nz_index)'
            for k = NCol_temp(nz_index)'
                if ~ismember(k, NCol_temp(find(NRow_temp == j)))
%                     NRow_temp(end + 1) = j;
%                     NCol_temp(end + 1) = k;
                    fills(n) = fills(n) + 1;
                end
            end
        end
    end

    if isempty(ordered_index) == false
        fills(ordered_index) = -1;
    end   

    fills_min = find(fills == min(fills(gt(fills, -1)))); % get the lowest fills index
 
    % record current the lowest degree node (the node after reducing the degrees will list at front)
    if length(fills_min) > 1
        fillsNdegree_min_index = find(degree(fills_min) == min(degree(fills_min)));
        ordered_index(i) = fills_min(fillsNdegree_min_index(1));
    else
        ordered_index(i) = fills_min;
    end
    
    index = find(NRow == ordered_index(i)); % get correlative nodes
    for j = NCol(index)'
        for k = NCol(index)'
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