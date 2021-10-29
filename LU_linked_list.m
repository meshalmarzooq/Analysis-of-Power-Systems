function [TQ, TQF] = LU_linked_list(TA, TAF, ordered_index)
Nmulti = 0;
Nnz = 0;
index = [];
value = [];
NRow = [];
NCol = [];
NIR = [];
NIC = [];
FIR = zeros(length(TAF.FIR), 1);
FIC = zeros(length(TAF.FIC), 1);

TQ = table(index, value, NRow, NCol, NIR, NIC);
TQF = table(FIR, FIC);

for j = 1: length(TAF.FIC)
    % calculate the Q column elements
    for k = j: length(TAF.FIR)
        col_temp = 0;
        for i = 1: j-1
            Qki = search_in_linked_list(TQ, TQF, k, i);
            Qij = search_in_linked_list(TQ, TQF, i, j);
            if Qki ~= 0 && Qij ~= 0
                col_temp = col_temp + Qki * Qij;
                Nmulti = Nmulti + 1;
            end
        end
        Akj = search_in_linked_list(TA, TAF, ordered_index(k), ordered_index(j));
        Qkj = Akj - col_temp;
        if Qkj ~= 0 % store non-zeros
            [TQ, TQF] = add_in_linked_list(TQ, TQF, Qkj, k, j);
            Nnz = Nnz + 1;
        end
    end
    
    % calculate the Q row elements
    if search_in_linked_list(TQ, TQF, j, j) ~= 0 % Q(j,j) ~= 0
        for k = j+1: length(FIC)
            row_temp = 0;
            for i = 1: j-1
                Qji = search_in_linked_list(TQ, TQF, j, i);
                Qik = search_in_linked_list(TQ, TQF, i, k);
                if Qji ~= 0 && Qik ~= 0
                    row_temp = row_temp - Qji * Qik;
                end
            end
            Ajk = search_in_linked_list(TA, TAF, ordered_index(j), ordered_index(k));
            Qjj = search_in_linked_list(TQ, TQF, j, j);
            Qjk = (Ajk + row_temp) / Qjj;
            if Qjk ~= 0 % store non-zeros
               [TQ, TQF] = add_in_linked_list(TQ, TQF, Qjk, j, k);
               Nnz = Nnz + 1;
            end
        end
    end
end
fprintf('Number of fills: %d\n', Nnz - length(TA.NIR));
fprintf('Number of non-zeros: %d\n', Nnz);
fprintf('Number of multiplications: %d\n', Nmulti * 2);
fprintf('Number of total processing steps: %d\n', Nnz + Nmulti * 2);
end