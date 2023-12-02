% Define the time-variant gain function gamma(t)
function gain = time_variant_gain(t, d, s_x, s_y)
    gain = (s_y * exp(s_x * (t - d))) ./ (1 + exp(s_x * (t - d))) + ...
           (1 + (1 - s_y) * exp(-s_x * d)) ./ (1 + exp(-s_x * d));
end