function is_in_array_or_not = is_in_array(array,find_element)
    %IS_IN_ARRAY Summary of this function goes here
    %   Detailed explanation goes here
    array_unique = unique(array);
    array_len = length(array_unique);
    for i = 1:array_len
        if array_unique(i)==find_element
            is_equal(i) = 1;
        else
            is_equal(i) = 0;
        end
    end
    if sum(is_equal)==0
        is_in_array_or_not=logical(0);
    else
        is_in_array_or_not=logical(1);
    end
end

