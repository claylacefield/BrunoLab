function ccgplot(A, B)

[n, x] = CrossCorrelate(A, B);
subplot(2, 1, 1); plot(x, n);
subplot(2, 1, 2); plot(x(abs(x) <= 50), n(abs(x) <= 50));

