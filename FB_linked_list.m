function [x] = FB_linked_list(TQ, TQF, ordered_index)
% forward substitution
y = zeros(length(TQF.FIR), 1);
for k = 1:length(TQF.FIR)
    y_temp = 0;
    for j = 1:(k-1)
        Qkj = search_in_linked_list(TQ, TQF, k, j);
        y_temp = y_temp + Qkj * y(j);     
    end
    Qkk = search_in_linked_list(TQ, TQF, k, k);
    y(k) = (ordered_index(k) - y_temp)/Qkk;
end

% backward substitution
x = zeros(length(TQF.FIC), 1);
for k = length(TQF.FIC):-1:1
    x_temp = 0;
    for j = (k+1):length(TQF.FIC)
        Qkj = search_in_linked_list(TQ, TQF, k, j);
        x_temp = x_temp + Qkj * x(j);
    end
    x(k) = y(k) - x_temp;
end
end