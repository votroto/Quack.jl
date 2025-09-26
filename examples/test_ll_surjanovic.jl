# All descriptions and examples taken from
# Surjanovic, S. & Bingham, D. (2013). Virtual Library of Simulation
# Experiments: Test Functions and Datasets. Retrieved August 15, 2025,
# from http://www.sfu.ca/~ssurjano.
# The code below is a simple re-implementation of the original R code.
using LinearAlgebra

#=
Description:

   Dimensions: d
   The Ackley function is widely used for testing optimization algorithms.
   In its two-dimensional form, as shown in the plot above, it is
   characterized by a nearly flat outer region, and a large hole at the
   centre. The function poses a risk for optimization algorithms,
   particularly hillclimbing algorithms, to be trapped in one of its many
   local minima.
   Recommended variable values are: a = 20, b = 0.2 and c = 2π.

Input Domain:

   The function is usually evaluated on the hypercube x [i ]∈ [-32.768,
   32.768], for all i = 1, …, d, although it may also be restricted to a
   smaller domain.

References:

   Adorio, E. P., & Diliman, U. P. MVF - Multivariate Test Functions
   Library in C for Unconstrained Global Optimization (2005). Retrieved
   June 2013, from http://http://www.geocities.ws/eadorio/mvf.pdf.

   Molga, M., & Smutnicki, C. Test functions for optimization needs
   (2005). Retrieved June 2013, from
   http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf.

   Back, T. (1996). Evolutionary algorithms in theory and practice:
   evolution strategies, evolutionary programming, genetic algorithms .
   Oxford University Press on Demand.

=#
function ex_surjanovic_ackley()
   function ackley(xx, a=20, b=0.2, c=2 * pi)
      d = length(xx)

      sum1 = sum(xx[i]^2 for i in 1:d)
      sum2 = sum(cos(c * xx[i]) for i in 1:d)

      term1 = -a * exp(-b * sqrt(sum1 / d))
      term2 = -exp(sum2 / d)

      term1 + term2 + a + exp(1)
   end

   dom_nneg(x) = (32.768 + x[1], 32.768 - x[1])
   dom_null(x) = 0

   u1(x, y) = ackley([x[1], y[1]])
   u2(x, y) = -u1(x, y)

   (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end



#=
Description:

   Dimensions: 2
   The Bohachevsky functions all have the same similar bowl shape. The one
   shown above is the first function.

Input Domain:

   The functions are usually evaluated on the square x [i ]∈ [-100, 100],
   for all i = 1, 2.

Reference:

   Global Optimization Test Problems. Retrieved June 2013, from
   http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/
   TestGO.htm.
=#
function ex_surjanovic_boha1()
   function boha1(x1, x2)
      term1 = x1^2
      term2 = 2 * x2^2
      term3 = -0.3 * cos(3 * pi * x1)
      term4 = -0.4 * cos(4 * pi * x2)

      term1 + term2 + term3 + term4 + 0.7
   end

   dom_nneg(x) = (100 + x[1], 100 - x[1])
   dom_null(x) = 0

   u1(x, y) = 0.01 * boha1(x[1], y[1])
   u2(x, y) = -u1(x, y)

   (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end

#=
Description:

   Dimensions: 2
   The Branin, or Branin-Hoo, function has three global minima. The
   recommended values of a, b, c, r, s and t are: a = 1, b = 5.1/(4π ^2
   ), c = 5/π, r = 6, s = 10 and t = 1/(8π).

Input Domain:

   This function is usually evaluated on the square x [1 ]∈ [-5, 10], x [2
   ]∈ [0, 15].

References:

   Dixon, L. C. W., & Szego, G. P. (1978). The global optimization
   problem: an introduction. Towards global optimization, 2 , 1-15.

   Forrester, A., Sobester, A., & Keane, A. (2008). Engineering design via
   surrogate modelling: a practical guide . Wiley.

   Global Optimization Test Problems. Retrieved June 2013, from
   http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/
   TestGO.htm.

   Molga, M., & Smutnicki, C. Test functions for optimization needs
   (2005). Retrieved June 2013, from
   http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf.

   Picheny, V., Wagner, T., & Ginsbourger, D. (2012). A benchmark of
   kriging-based infill criteria for noisy optimization.

=#

function ex_surjanovic_branin()
   function branin(x1, x2, a=1, b=5.1 / (4 * pi^2), c=5 / pi, r=6, s=10, t=1 / (8 * pi))
      term1 = a * (x2 - b * x1^2 + c * x1 - r)^2
      term2 = s * (1 - t) * cos(x1)

      term1 + term2 + s
   end

   dom_nneg1(x) = (5 + x[1], 10 - x[1])
   dom_nneg2(x) = (x[1], 15 - x[1])
   dom_null(x) = 0

   u1(x, y) = branin(x[1], y[1])
   u2(x, y) = -u1(x, y)

   (u1, u2), (dom_nneg1, dom_nneg2), (dom_null, dom_null), (1, 1)
end


#=
Description:

   Dimensions: 2

Input Domain:

   The function is usually evaluated on the rectangle x [1 ]∈ [-1.5, 4], x
   [2 ]∈ [-3, 4].

Reference:

   Adorio, E. P., & Diliman, U. P. MVF - Multivariate Test Functions
   Library in C for Unconstrained Global Optimization (2005). Retrieved
   June 2013, from http://http://www.geocities.ws/eadorio/mvf.pdf.

=#

function ex_surjanovic_mccorm()
   function mccorm(x1, x2)
      term1 = sin(x1 + x2)
      term2 = (x1 - x2)^2
      term3 = -1.5 * x1
      term4 = 2.5 * x2

      term1 + term2 + term3 + term4 + 1
   end

   dom_nneg1(x) = (1.5 + x[1], 4 - x[1])
   dom_nneg2(x) = (3 + x[1], 4 - x[1])
   dom_null(x) = 0

   u1(x, y) = mccorm(x[1], y[1])
   u2(x, y) = -u1(x, y)

   (u1, u2), (dom_nneg1, dom_nneg2), (dom_null, dom_null), (1, 1)
end



#=
Description:

   Dimensions: d
   The Michalewicz function has d! local minima, and it is multimodal. The
   parameter m defines the steepness of they valleys and ridges; a larger
   m leads to a more difficult search. The recommended value of m is m =
   10. The function's two-dimensional form is shown in the plot above.

Input Domain:

   The function is usually evaluated on the hypercube x [i ]∈ [0, π], for
   all i = 1, …, d.

Global Minima:


References:

   Global Optimization Test Functions Index. Retrieved June 2013, from
   http://infinity77.net/global_optimization/test_functions.html#test-func
   tions-index.

   Global Optimization Test Problems. Retrieved June 2013, from
   http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/
   TestGO.htm.

   Molga, M., & Smutnicki, C. Test functions for optimization needs
   (2005). Retrieved June 2013, from
   http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf.

=#
function ex_surjanovic_michal()
   function michal(xx, m=10)
      d = length(xx)
      -sum(sin(xx[i]) * (sin(i * xx[i]^2 / pi))^(2 * m) for i in 1:d)
   end

   dom_nneg(x) = (x[1], pi - x[1])
   dom_null(x) = 0

   u1(x, y) = michal([x[1], y[1]])
   u2(x, y) = -u1(x, y)

   (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end
#=
Description:

   Dimensions: d
   The Rastrigin function has several local minima. It is highly
   multimodal, but locations of the minima are regularly distributed. It
   is shown in the plot above in its two-dimensional form.

Input Domain:

   The function is usually evaluated on the hypercube x [i ]∈ [-5.12,
   5.12], for all i = 1, …, d.

References:

   Global Optimization Test Problems. Retrieved June 2013, from
   http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/
   TestGO.htm.

   Pohlheim, H. GEATbx Examples: Examples of Objective Functions (2005).
   Retrieved June 2013, from
   http://www.geatbx.com/download/GEATbx_ObjFunExpl_v37.pdf.
=#

function ex_surjanovic_rosen()
   function rosen(xx)
      d = length(xx)
      sum(100 * (xx[i+1] - xx[i]^2)^2 + (xx[i] - 1)^2 for i in 1:d-1)
   end

   dom_nneg(x) = (5+x[1], 10-x[1])
   dom_null(x) = 0

   u1(x, y) = 0.0001 * rosen([x[1], y[1]])
   u2(x, y) = -u1(x, y)

   (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end