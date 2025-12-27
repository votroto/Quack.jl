corr(n, x=1) = (n <= 1) ? x : ww(n-1, atan(x))
act(n) = 1/sqrt((1+2*n)/3)

u1(x,y) = -sqrt(abs(x-y))
u2(x,y) = -sqrt(abs(x-tan(y)))



ex(n) = u2(corr(n), corr(n+1)) - u2(corr(n), corr(n))
wa(n) = corr(n) - corr(n+1)



exe(n) = sqrt(1/sqrt((1+2*(n-1))/3)-1/sqrt((1+2*n)/3))
wae(n) = act(n) - act(n+1)

exw(n) = 3^(1/4) * sqrt(1/sqrt(2*n - 1) - 1/sqrt(2*n + 1))
wxw(n) = sqrt(3) * (1/sqrt(2*n + 1) - 1/sqrt(2*n + 3))