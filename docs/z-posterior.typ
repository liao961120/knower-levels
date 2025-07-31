#import "@local/yongfu:1.0.0": *
#show: Math
#set page(fill: none)

$ 
p (z divides D) & = frac(p (z , D), p (D))\
 & = integral_theta frac(p (z , D divides theta), p (D divides theta)) 
     underbrace(p (theta divides D), 
     #text(7pt)[posterior of \ continuous parameter]) d theta \
     & approx 1 / M sum_(m = 1)^M frac(p (z , D divides theta^((m))), p (D divides theta^((m)))) \
     & = 1/M sum_(m=1)^M p(z,D divides theta^((m))) / (sum_z p(z, D divides theta^((m))))
$