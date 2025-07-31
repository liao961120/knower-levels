#import "@local/yongfu:1.0.0": *
#show: Math

Marginalizing out the discrete parameter to fit Stan model:

$ p (D divides theta) = sum_z p (z , D divides theta) = sum_z p (z) p (D divides theta, z) $

Recovering (the pmf of) the discrete parameter $z$:

$ p (z , D) & = integral_theta p (z , D , theta) dif theta\
 & = integral_theta p (theta) p (z , D divides theta) dif theta\
 & = integral_theta frac(p (theta divides D), p (theta divides D)) p (theta) p (z , D divides theta) dif theta\
 & = integral_theta p (theta divides D) frac(p (D), p (D divides theta)) p (z , D divides theta) dif theta quad (because frac(p (theta), p (theta divides D)) = frac(p (D), p (D divides theta)))\
 & = p (D) integral_theta frac(p (z , D divides theta), p (D divides theta)) p (theta divides D) dif theta $

$ 
p (z divides D) & = frac(p (z , D), p (D))\
 & = integral_theta frac(p (z , D divides theta), p (D divides theta)) 
     underbrace(p (theta divides D), 
     #text(7pt)[posterior of \ continuous parameter]) d theta \
     & approx 1 / M sum_(m = 1)^M frac(p (z , D divides theta^((m))), p (D divides theta^((m)))) \
     & = 1/M sum_(m=1)^M p(z,D divides theta^((m))) / (sum_z p(z, D divides theta^((m))))
$
