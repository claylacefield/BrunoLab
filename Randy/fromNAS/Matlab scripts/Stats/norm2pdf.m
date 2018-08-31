function [result] = norm2pdf(x,p,mu1,mu2,sigma1,sigma2)

result = p*normpdf(x,mu1,sigma1) + (1-p)*normpdf(x,mu2,sigma2);
