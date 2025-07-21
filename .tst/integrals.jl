using QuadGK, SpecialFunctions

# Define standard normal CDF with mean and standard deviation
Φ(x, μ, σ) = 0.5 * (1 + erf((x - μ) / (σ * sqrt(2))))

# Define standard normal PDF with mean and standard deviation
ϕ(x, μ, σ) = exp(-((x - μ)^2) / (2 * σ^2)) / (σ * sqrt(2π))

# Define the function to integrate
f(x, μ, σ, y, m, s) = Φ(x, μ, σ) * ϕ(y, m, s)


w = 7
c = 15

mu = 2
sig = 3.2

# Compute the integral from 0 to infinity
result, err = quadgk(x -> f(w*x+c, 0, 1, x, mu, sig), -Inf, Inf)
@show result

result, err = quadgk(x -> f(x, -c/w, sqrt(1/w^2), x, mu, sig), -Inf, Inf)
@show result

result = Φ((w*mu + c)/sqrt(1+sig^2*w^2), 0, 1)
@show result