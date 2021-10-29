function [x_new] = ordering_scheme_reversion(x, ordered_index)

x_new = zeros(length(x), 1);

for i = 1:length(ordered_index)
    x_new(ordered_index(i)) =  x(i);
end

end
