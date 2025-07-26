
# Generic continuous Games with Quack

So far we focused on the case where oracles can be tailored to each game individually. This raises the question of how applicable our technique is. In this section we will show that the branch and bound reformulations that were described before can be successfully applied to solve a wide range of games, without the need to develop a new oracle each time. A consistent use of one particular oracle method also allows us to analyze the time complexity of our approach.


...

experiments

## Separable game
Utilities:
$$
\begin{aligned}
u_1(x, y, z) &= -2xy^2 - 2x^2 + 5xy - 4xz - y - 2z, \\
u_2(x, y, z) &= 2xy^2 - 2y z^2 - 2x^2 - 5xy - 2y^2 + 5yz + y, \\
u_3(x, y, z) &= 2yz^2 + 4x^2 + 4xz + 2y^2 - 5yz + 2z.
\end{aligned}
$$

Strategy sets:
$$[-1,1]$$
Result

    8 iterations
    1.670455 seconds

    -0.058, 99.8 %; -0.073, 0.1 %;
    0.344, 57.4 %; 0.367, 42.6 %;
    1.0, 72.1 %; -1.0, 27.9 %;

## Karlin
Utilities:
$$
\begin{aligned}
u_1(x,y) &= (y-0.5) \left( \frac{1+(x-0.5)(y-0.5)^2}{1+(x-0.5)^2(y-0.5)^4} - \frac{1}{1+(\frac{x}{3}-0.5)(y-0.5)^4} \right), \\
u_2(x,y) &= -u_1(x,y).
\end{aligned}
$$
Strategy sets:
$$[0,1]$$
Result

    4 iterations
    0.079012 seconds

    0.5, 84.5 %; 1.0, 15.5 %;
    1.0, 32.5 %; 0.111, 67.5 %;

## Mertikopoulos fst
Source

    OPTIMISTIC MIRROR DESCENT IN SADDLE-POINT PROBLEMS:
    GOING THE EXTRA (GRADIENT) MILE

    Figure 1

$$
\begin{aligned}
u_1(x,y) &= (x-0.5)(y-0.5) + \frac{1}{3} \exp\left(-\left(x - \frac{1}{4}\right)^2 - \left(y - \frac{3}{4}\right)^2\right), \\
u_2(x,y) &= -u_1(x,y).
\end{aligned}
$$

[0,1]

    4 iterations
    0.038613 seconds

    0.5, 4.6 %; 0.373, 95.4 %;
    0.0, 40.6 %; 1.0, 59.4 %;


## Mtkpls snd

Source

    OPTIMISTIC MIRROR DESCENT IN SADDLE-POINT PROBLEMS:
    GOING THE EXTRA (GRADIENT) MILE

    example 2.2

$$
\begin{aligned}
u_1(x,y) &= -(x^4y^2 + x^2 + 1)(x^2y^4 - y^2 + 1), \\
u_2(x,y) &= -u_1(x,y).
\end{aligned}
$$

[-1,1]

    1 iteration
    0.004913 seconds

    0.0, 100.0 %;
    0.0, 100.0 %;

## Nguy

Source:

    arXiv:2309.07897v1 [cs.GT] 14 Sep 2023
    Equation (18)

Parameters

$$
\begin{align*}
n_0 &= 0.43 \times 10^{-6}\\
\beta &=
\begin{bmatrix}
0.5 & 0.51 & 0.52 & 0.3 & 0.31 & 0.32
\end{bmatrix} \\
\alpha &=
\begin{bmatrix}
0.261 & 0.494 & 0.107 & 0.366 & 0.208 & 0.305
\end{bmatrix}\\
\Phi &=
\begin{bmatrix}
7.463 & 7.378 & 7.293 & 7.210 & 7.127 & 6.965 \\
7.451 & 7.365 & 7.281 & 7.198 & 7.115 & 6.953 \\
7.438 & 7.353 & 7.269 & 7.186 & 7.103 & 6.942 \\
7.427 & 7.342 & 7.258 & 7.175 & 7.093 & 6.931 \\
7.409 & 7.324 & 7.240 & 7.157 & 7.075 & 6.914 \\
7.387 & 7.303 & 7.219 & 7.136 & 7.055 & 6.894
\end{bmatrix} \times 10^{-5}
\end{align*}
$$

Definitions
$$
\gamma_i(x) = \frac{x_i}{n_0 + \sum_{j=1}^6 \phi_{ij} x_j}
$$

Utility Function:
$$
u_i(x) = - x_i + \beta_i \left( \log\left(1 + \frac{\alpha_i \gamma_i(x)}{1 - \phi_{ii} \gamma_i(x)} \right) - x_i \right)
$$

Strategy sets
$$
[0.2,2]
$$

Results

    5.343410 seconds
    2 iterations

    0.332, 100.0 %;
    0.337, 100.0 %;
    0.338, 100.0 %;
    0.229, 100.0 %;
    0.235, 100.0 %;
    0.241, 100.0 %;


## Stein fst

Source

    DOI 10.1007/s00182-008-0129-2
    Separable and low-rank continuous games
    Example 2.3

$$
\begin{aligned}
u_1(x,y) &= 2xy + 3y^3 - 2x^3 - x - 3x^2y^2, \\
u_2(x,y) &= 2x^2y^2 - 4y^3 - x^2 + 4y + xy^2.
\end{aligned}
$$

Strategy sets
$$[-1,1]$$

Known NE:

    -1.0, 55.3 %; 0.115, 44.7 %;
    0.72, 100.0 %;

Results

    0.092252 seconds
    7 iterations

    -1.0, 55.8 %; 0.112, 1.0 %; 0.115, 43.2 %;
    0.71, 57.2 %; 0.726, 42.8 %;

## Stein snd

Source

    DOI 10.1007/s00182-008-0129-2
    Separable and low-rank continuous games
    Example 3.10

$$
\begin{aligned}
u_1(x,y,z) &= 1 + 2x + 3x^2 + 2yz + 4xyz + 6x^2yz + 3y^2z^2 + 6xy^2z^2 + 9x^2y^2z^2, \\
u_2(x,y,z) &= 7 + 2x + 3x^2 + 2y + 4xy + 6x^2y + 3z^2 + 6xz^2 + 9x^2z^2, \\
u_3(x,y,z) &= -z - 2xz - 3x^2z - 2yz - 4xyz - 6x^2yz - 3yz^2 - 6xyz^2 - 9x^2yz^2.
\end{aligned}
$$

[-1,1]

    0.045315 seconds
    3 iterations

    1.0, 100.0 %;
    1.0, 100.0 %;
    -0.5, 100.0 %;

## Stein third

Source

    DOI 10.1007/s00182-008-0129-2
    Separable and low-rank continuous games
    Example 2.4

Parameters
$$\alpha = 0.5$$

Utilities
$$
\begin{aligned}
u_1(x,y) &= cos(x-y)\\
u_2(x,y) &= cos(x-y-\alpha)
\end{aligned}
$$

Strategy sets
$$[-\pi,\pi]$$

Known equilibria

    Both players pick any theta and theta+pi with equal support

Results

    2.800521 seconds
    23 iterations

    0.0, 6.4 %; -0.499, 15.4 %; -0.999, 13.7 %; -1.499, 2.9 %; -2.473, 23.9 %; 2.323, 0.1 %; 1.806, 37.6 %;
    0.0, 3.7 %; -0.5, 26.9 %; -1.499, 19.7 %; 2.824, 24.1 %; 1.826, 0.6 %; 1.806, 24.9 %; 0.812, 0.2 %;


## Parrilo Guess

Source

    P. A. Parrilo, "Polynomial games and sum of squares optimization," Proceedings of the 45th IEEE Conference on Decision and Control, San Diego, CA, USA, 2006, pp. 2855-2860, doi: 10.1109/CDC.2006.377261. keywords: {Polynomials;Game theory;Control systems;USA Councils;Laboratories;Mathematical model;Nash equilibrium;Minimax techniques;Linear programming},

    Example 2.1

Utility functions
$$
\begin{aligned}
p_1(x, y) &= (x - y)^2, \\
p_2(x, y) &= -p_1(x, y).
\end{aligned}
$$

Strategy sets:
$$[-1,1]$$

Known equilibria

    -1.0, 50.0 %; 1.0, 50.0 %;
    0.0 100.0 %;

Results

    0.024141 seconds
    7 iterations

    -1.0, 51.6 %; 1.0, 48.4 %;
    0.0, 100.0 %;


## Parrilo Concave

Source

    P. A. Parrilo, "Polynomial games and sum of squares optimization," Proceedings of the 45th IEEE Conference on Decision and Control, San Diego, CA, USA, 2006, pp. 2855-2860, doi: 10.1109/CDC.2006.377261. keywords: {Polynomials;Game theory;Control systems;USA Councils;Laboratories;Mathematical model;Nash equilibrium;Minimax techniques;Linear programming},

    Example 3.1

Utility functions
$$
\begin{aligned}
u_1(x,y) &= 2xy^2 - x^2 - y, \\
u_2(x,y) &= -u_1(x,y).
\end{aligned}
$$

Strategy sets:
$$[-1,1]$$

Known equilibria

    0.397, 100.0 %;
    0.63, 100.0 %;

Results

    0.023780 seconds
    7 iterations

    0.391, 100.0 %;
    0.625, 100.0 %;


## Parrilo Last

Source

    P. A. Parrilo, "Polynomial games and sum of squares optimization," Proceedings of the 45th IEEE Conference on Decision and Control, San Diego, CA, USA, 2006, pp. 2855-2860, doi: 10.1109/CDC.2006.377261. keywords: {Polynomials;Game theory;Control systems;USA Councils;Laboratories;Mathematical model;Nash equilibrium;Minimax techniques;Linear programming},

    Example 3.2

Utility functions
$$
\begin{aligned}
u_1(x,y) &= 5xy - 2x^2 - 2xy^2 - y, \\
u_2(x,y) &= -u_1(x,y).
\end{aligned}
$$

Strategy sets:
$$[-1,1]$$

Known equilibria

    0.2, 100.0 %;
    1.0, 78.0 %; -1.0, 22.0 %;

Results

    0.027322 seconds
    8 iterations

    0.188, 46.7 %; 0.211, 53.3 %;
    1.0, 78.0 %; -1.0, 22.0 %;

## Torus

Source


    Chasnov, B., Ratliff, L., Mazumdar, E. &amp; Burden, S.. (2020). Convergence Analysis of Gradient-Based Learning in Continuous Games. <i>Proceedings of The 35th Uncertainty in Artificial Intelligence Conference</i>, in <i>Proceedings of Machine Learning Research</i> 115:935-944 Available from https://proceedings.mlr.press/v115/chasnov20a.html.

    5.2 TORUS GAME


Parameters
$$
\begin{aligned}
\phi &= \left(0, \frac{\pi}{8}\right), \\
\alpha &= (1, 1.5), \\
\end{aligned}
$$

Utilities
$$
\begin{aligned}
p_1(x, y) &= \alpha_1 \cos(x - \phi_1) - \cos(x - y)\\
p_2(x, y) &= \alpha_2 \cos(y - \phi_2) - \cos(y - x).
\end{aligned}
$$

Strategy sets
$$[-\pi, \pi]$$

Known equilibria:

    1:
    -1.063, 100.0 %;
    1.014, 100.0 %;

    2:
    1.408, 100.0 %;
    -0.325, 100.0 %;

Result

    0.041457 seconds
    3 iterations

    -1.081, 100.0 %;
    0.98, 100.0 %;

## Daskalakis D

source

    https://proceedings.mlr.press/v195/daskalakis23b/daskalakis23b.pdf
    (Appendix D)

def

    u1(x,y) = (x-1/2)*(y-1/2)
    u2(x,y) = -u1(x,y)

    [0,1]

result

    0.002456 seconds
    1 iter

    0.5, 100.0 %;
    0.5, 100.0 %;


## Guangming

Source

    Saddle points of rational functions


utils

    u1(x, y) = -(x[1]^2 * y[1] + 2 * x[2]^2 * y[2] + 3 * x[3]^2 * y[3] - x[1] - x[2] - x[3]) / (x[1] * y[1] + 1)
    u2(x, y) = -u1(x, y)

constr

    nrm1(x) = 1 - x[1]^2 - x[2]^2 - x[3]^2

known ne

    (0.473, 0.448, 0.342), 100.0 %;
    (0.671, 0.558, 0.488), 100.0 %;


results

    0.243850 seconds
    10 iters

    (0.486, 0.433, 0.352), 45.2 %; (0.461, 0.468, 0.335), 54.8 %;
    (0.643, 0.589, 0.49), 35.2 %; (0.673, 0.541, 0.504), 64.8 %;
