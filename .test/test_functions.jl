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
function ackley(xx, a=20, b=0.2, c=2 * pi)
   d = length(xx)

   sum1 = sum(xx[i]^2 for i in 1:d)
   sum2 = sum(cos(c * xx[i]) for i in 1:d)

   term1 = -a * exp(-b * sqrt(sum1 / d))
   term2 = -exp(sum2 / d)

   term1 + term2 + a + exp(1)
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
function boha1(xx)
   x1 = xx[1]
   x2 = xx[2]

   term1 = x1^2
   term2 = 2 * x2^2
   term3 = -0.3 * cos(3 * pi * x1)
   term4 = -0.4 * cos(4 * pi * x2)

   term1 + term2 + term3 + term4 + 0.7
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

Modifications and Alternate Forms:

   Picheny et al. (2012) use the following rescaled form of the Branin-Hoo
   function, on [0, 1] ^2 :


   This rescaled form of the function has a mean of zero and a variance of
   one. The authors also add a small Gaussian error term to the output.
   For the purpose of Kriging prediction, Forrester et al. (2008) use a
   modified form of the Branin-Hoo function, in which they add a term 5x
   [1 ]to the response. As a result, there are two local minima and only
   one global minimum, making it more representative of engineering
   functions.

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
function branin(xx, a=1, b=5.1 / (4 * pi^2), c=5 / pi, r=6, s=10, t=1 / (8 * pi))
   x1 = xx[1]
   x2 = xx[2]

   term1 = a * (x2 - b * x1^2 + c * x1 - r)^2
   term2 = s * (1 - t) * cos(x1)

   term1 + term2 + s
end
#=
Description:

   Dimensions: 2
   The fifth function of De Jong is multimodal, with very sharp drops on a
   mainly flat surface.

Input Domain:

   The function is usually evaluated on the square x [i ]∈ [-65.536,
   65.536], for all i = 1, 2.

Reference:

   Molga, M., & Smutnicki, C. Test functions for optimization needs
   (2005). Retrieved June 2013, from
   http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf.

=#
function dejong5(xx)
   x1 = xx[1]
   x2 = xx[2]

   a = [-32, -16, 0, 16, 32]
   A = zeros(2, 25)
   A[1, :] = repeat(a, outer=5)
   A[2, :] = repeat(a, inner=5)

   total = sum(1 / (i + (x1 - A[1, i])^6 + (x2 - A[2, i])^6) for i in 1:25)
   1 / (0.002 + total)
end
#=
Description:

   Dimensions: 2
   The Drop-Wave function is multimodal and highly complex. The second
   plot above shows the function on a smaller input domain, to illustrate
   its characteristic features.

Input Domain:

   The function is usually evaluated on the square x [i ]∈ [-5.12, 5.12],
   for all i = 1, 2.

Reference:

   Global Optimization Test Functions Index. Retrieved June 2013, from
   http://infinity77.net/global_optimization/test_functions.html#test-func
   tions-index.

=#
function drop(xx)
   x1 = xx[1]
   x2 = xx[2]

   frac1 = 1 + cos(12 * sqrt(x1^2 + x2^2))
   frac2 = 0.5 * (x1^2 + x2^2) + 2

   -frac1 / frac2
end
#=
Description:

   Dimensions: 2
   The Easom function has several local minima. It is unimodal, and the
   global minimum has a small area relative to the search space.

Input Domain:

   The function is usually evaluated on the square x [i ]∈ [-100, 100],
   for all i = 1, 2.

Reference:

   Global Optimization Test Problems. Retrieved June 2013, from
   http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/
   TestGO.htm.

=#
function easom(xx)
   x1 = xx[1]
   x2 = xx[2]

   fact1 = -cos(x1) * cos(x2)
   fact2 = exp(-(x1 - pi)^2 - (x2 - pi)^2)

   fact1 * fact2
end
#=
Description:

   Dimensions: d
   The Griewank function has many widespread local minima, which are
   regularly distributed. The complexity is shown in the zoomed-in plots.

Input Domain:

   The function is usually evaluated on the hypercube x [i ]∈ [-600, 600],
   for all i = 1, …, d.

References:

   Global Optimization Test Problems. Retrieved June 2013, from
   http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/
   TestGO.htm.

   Molga, M., & Smutnicki, C. Test functions for optimization needs
   (2005). Retrieved June 2013, from
   http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf.

=#
function griewank(xx)
   d = length(xx)
   vsum = sum(xx[i]^2 / 4000 for i in 1:d)
   vprod = prod(cos(xx[i] / sqrt(i)) for i in 1:d)

   vsum - vprod + 1
end
#=
Description:

   Dimensions: d
   The Langermann function is multimodal, with many unevenly distributed
   local minima. The recommended values of m, c and A , as given by Molga
   & Smutnicki (2005) are (for d = 2): m = 5, c = (1, 2, 5, 2, 3) and:


Input Domain:

   The function is usually evaluated on the hypercube x [i ]∈ [0, 10], for
   all i = 1, …, d.

Reference:

   Adorio, E. P., & Diliman, U. P. MVF - Multivariate Test Functions
   Library in C for Unconstrained Global Optimization (2005). Retrieved
   June 2013, from http://http://www.geocities.ws/eadorio/mvf.pdf.

   Molga, M., & Smutnicki, C. Test functions for optimization needs
   (2005). Retrieved June 2013, from
   http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf.

=#
function langer(xx, m=5, c=missing, A=missing)
   d = length(xx)

   if (ismissing(c))
      if (m == 5)
         c = [1, 2, 5, 2, 3]
      else
         error("Value of the m-dimensional vector cvec is required.")
      end
   end

   if (ismissing(A))
      if (m == 5 && d == 2)
         A = [
            3 5
            5 2
            2 1
            1 4
            7 9
         ]
      else
         error("Value of the (mxd)-dimensional matrix A is required.")
      end
   end

   outer = sum(c[i] * exp(-sum((xx[j] - A[i, j])^2 for j in 1:d) / pi) * cos(pi * sum((xx[j] - A[i, j])^2 for j in 1:d)) for i in 1:m)

   outer
end
#=
Description:

   Dimensions: 2

Input Domain:

   The function is usually evaluated on the square x [i ]∈ [-10, 10], for
   all i = 1, 2.

Reference:

   Global Optimization Test Functions Index. Retrieved June 2013, from
   http://infinity77.net/global_optimization/test_functions.html#test-func
   tions-index.

=#
function levy13(xx)
   x1 = xx[1]
   x2 = xx[2]

   term1 = (sin(3 * pi * x1))^2
   term2 = (x1 - 1)^2 * (1 + (sin(3 * pi * x2))^2)
   term3 = (x2 - 1)^2 * (1 + (sin(2 * pi * x2))^2)

   term1 + term2 + term3
end
#=
Description:

   Dimensions: d

Input Domain:

   The function is usually evaluated on the hypercube x [i ]∈ [-10, 10],
   for all i = 1, …, d.

Reference:

   Global Optimization Test Functions Index. Retrieved June 2013, from
   http://infinity77.net/global_optimization/test_functions.html#test-func
   tions-index.

   Laguna, M., & Marti, R. Experimental Testing of Advanced Scatter Search
   Designs for Global Optimization of Multimodal Functions (2002).
   Retrieved June 2013, from
   http://www.uv.es/rmarti/paper/docs/global1.pdf.

=#
function levy(xx)
   d = length(xx)
   w = [1 + (xx[i] - 1) / 4 for i in 1:d]

   term1 = (sin(pi * w[1]))^2
   term3 = (w[d] - 1)^2 * (1 + 1 * (sin(2 * pi * w[d]))^2)
   tsum = sum((w[i] - 1)^2 * (1 + 10 * (sin(pi * w[i] + 1))^2) for i in 1:d-1)

   term1 + tsum + term3
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
function mccorm(xx)
   x1 = xx[1]
   x2 = xx[2]

   term1 = sin(x1 + x2)
   term2 = (x1 - x2)^2
   term3 = -1.5 * x1
   term4 = 2.5 * x2

   term1 + term2 + term3 + term4 + 1
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
function michal(xx, m=10)
   d = length(xx)
   -sum(sin(xx[i]) * (sin(i * xx[i]^2 / pi))^(2 * m) for i in 1:d)
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
function rastr(xx)
   d = length(xx)
   10 * d + sum(xx[i]^2 - 10 * cos(2 * pi * xx[i]) for i in 1:d)
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

function rosen(xx)
  d = length(xx)
  sum(100*(x[i+1]-x[i]^2)^2 + (x[i]-1)^2 for i in 1:d-1)
end

#=
Description:

   Dimensions: 2
   The second Schaffer function. It is shown on a smaller input domain in
   the second plot to show detail.

Input Domain:

   The function is usually evaluated on the square x [i ]∈ [-100, 100],
   for all i = 1, 2.

Reference:

   Test functions for optimization. In Wikipedia . Retrieved June 2013,
   from https://en.wikipedia.org/wiki/Test_functions_for_optimization.

=#
function schaffer2(xx)
   x1 = xx[1]
   x2 = xx[2]

   fact1 = (sin(x1^2 - x2^2))^2 - 0.5
   fact2 = (1 + 0.001 * (x1^2 + x2^2))^2

   0.5 + fact1 / fact2
end
#=
Description:

   Dimensions: 2
   The Shubert function has several local minima and many global minima.
   The second plot shows the the function on a smaller input domain, to
   allow for easier viewing.

Input Domain:

   The function is usually evaluated on the square x [i ]∈ [-10, 10], for
   all i = 1, 2, although this may be restricted to the square x [i ]∈
   [-5.12, 5.12], for all i = 1, 2.

Reference:

   Global Optimization Test Problems. Retrieved June 2013, from
   http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/
   TestGO.htm.

=#
function shubert(xx)
   x1 = xx[1]
   x2 = xx[2]

   sum1 = sum(i * cos((i + 1) * x1 + i) for i in 1:5)
   sum2 = sum(i * cos((i + 1) * x2 + i) for i in 1:5)

   sum1 * sum2
end

tf_many_local_minima = [
   ackley,
   drop,
   griewank,
   langer,
   levy,
   levy13,
   rastr,
   schaffer2,
   shubert
]

tf_bowl_shaped = [
   boha1
]

tf_plate_shaped = [
   mccorm,
]

tf_valley_shaped = [
   rosen
]
tf_steep_ridges = [
   dejong5,
   easom,
   michal
]
tf_other = [
   branin,
]

tf_all = [
   tf_many_local_minima;
   tf_bowl_shaped;
   tf_plate_shaped;
   tf_valley_shaped;
   tf_steep_ridges;
   tf_other
]