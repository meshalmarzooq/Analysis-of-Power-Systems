function [TA, TAF] = store_in_linked_list(A)
%% Initialization parameters
% Initialzie parameters in linked list representation table of matrix A - index, value, NRow, NCol, NIR, NIC
NIC = zeros(length(A), 1); 
NIR = zeros(length(A), 1);
FIR = []; FIC = [];

[NCol, NRow, value] = find(A'); % record sparse matrix information - NCol, NRow, value
index = find(value); % get index value

% Store the next nonzero in row / column
for i = 1:length(A)
    NIR_temp = find(NRow == i); % find index for element which has same row number
    NIR(NIR_temp) = [NIR_temp(2: end); 0];  % next in row
    FIR = [FIR; NIR_temp(1)];  % first in row
    NIC_temp = find(NCol == i); % find index for element which has same column number
    NIC(NIC_temp) = [NIC_temp(2: end); 0];  % next in column
    FIC = [FIC; NIC_temp(1)];  % first in column
end

% Get non-zero elements table of A
TA = table(index, value, NRow, NCol, NIR, NIC);
TAF = table(FIR, FIC);

end