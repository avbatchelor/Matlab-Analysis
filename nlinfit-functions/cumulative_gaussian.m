function [fit] = cumulative_gaussian(beta, x)

fit = normcdf(x, 0, abs(beta(1)));
