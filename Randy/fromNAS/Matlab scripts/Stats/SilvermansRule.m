function [bandwidth] = SilvermansRule(data)

bandwidth = 1.06 * min(std(data), iqr(data)/1.34) * length(data)^-0.2;

 
 