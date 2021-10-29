function [aij] = search_in_linked_list(TA, TAF, i, j)

row_index = TAF.FIR(i);

if  row_index == 0 % if value index 'row_index' is 0,the i th row are all zeros and return aij=0; 
    aij = 0;
    return
else
    while row_index ~= 0 % search all value in the row i
        if TA.NCol(row_index) == j % if NCOL(row_index) equals j, the target value in jth column is returned
            aij = TA.value(row_index);
            return;
        end
        row_index = TA.NIR(row_index);
    end
    aij = 0; % if not found at the i th row, then return 0;
end

end


