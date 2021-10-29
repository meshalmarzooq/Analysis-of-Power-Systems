function [TA_new, TAF_new] = add_in_linked_list(TA, TAF, aij, i, j)
%% Add element to NRow, NCol, value; Initialize new NIR, NIC, FIR, FIC
if isempty(TA) == false
    index = [TA.index; TA.index(end)+1];
else
    index = [1];
end
value = [TA.value; aij];
NRow = [TA.NRow; i];
NCol = [TA.NCol; j];
NIR = TA.NIR;
NIC = TA.NIC;
FIR = TAF.FIR;
FIC = TAF.FIC;
    
%% Update element in FIR, NIR
row_index = FIR(i);

if row_index == false % update first NIRs, FIRs for Q
    FIR(i) = index(end);
    NIR(index(end), 1) = 0;
else % update NIC, FIC 
    % update NIR, FIR (NRow keeps constant, NCol changes)
    while true
        if NCol(row_index) == j % update an existing value by aij
            value(row_index) = aij;
            value(end) = [];
            index(end) = [];
            NCol(end) = [];
            break;
        elseif NCol(row_index) > j % update aij as FIR in row i
            NIR(index(end)) = row_index;
            FIR(i) = index(end);
            break;
        elseif NIR(row_index) == 0 % update aij as the last element in row i
            NIR = [NIR; NIR(row_index)];
            NIR(row_index) = index(end);
            break;
        elseif NCol(row_index) < j && NCol(NIR(row_index)) > j % update aij in between two elements in row i
            NIR = [NIR; NIR(row_index)];
            NIR(row_index) = index(end);
            break;
        end 
            row_index = NIR(row_index);
    end
end

%% Update element in FIC, NIC
col_index = FIC(j);
    
if col_index == false % update first NICs, FICs for Q
    FIC(j) = index(end);
    NIC(index(end), 1) = 0;
else % update NIC, FIC
    while true
        if  NRow(col_index) == i % update an existing value by aij
            NRow(end) = [];
            break; 
        elseif NRow(col_index) > i  % update aij as FIC in column j
            NIC(index(end)) = col_index;  
            FIC(j) = length(NCol);
            break;   
        elseif NIC(col_index) == 0 % update aij as the last element in column j
            NIC = [NIC; NIC(col_index)];
            NIC(col_index) = index(end);
            break;
        elseif NRow(col_index) < i && NRow(NIC(col_index)) > i % update aij in between two elements in column j
            NIC = [NIC; NIC(col_index)];
            NIC(col_index) = index(end);
            break;
        end     
        col_index = NIC(col_index);        
    end
end
   
%% Make table and table of firsts information
TA_new = table(index, value, NRow, NCol, NIR, NIC);
TAF_new = table(FIR, FIC);

% [A] = restore_sparse_matrix(TA_new, TAF_new)
end