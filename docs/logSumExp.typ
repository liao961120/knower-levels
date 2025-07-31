#import "@local/yongfu:1.0.0": *
#show: Math
#set page(fill: none)

#let hh = $#h(3pt)$
#let v1 = $vec(
  "log"[p (z = 1) #hh p (D divides theta , z = 1)],
  "log"[p (z = 2) #hh p (D divides theta , z = 2)],
   dots.h , 
   "log"[p (z = K) #hh p (D divides theta , z = K)]
)$
#let v2 = $vec(
  p (z = 1) #hh p(D divides theta , z = 1),
  p (z = 2) #hh p(D divides theta , z = 2),
  dots.h , 
  p (z = K) #hh p(D divides theta , z = K)
)$

$
  "lo"&"gSumExp"[ #v1 ]  \
  & = "logSum"[ #v2 ]  \
  & = "log" sum_(k=1)^K p(z=k) #hh p(D divides theta, z=k) 
    #h(6pt) = #h(6pt) "log" p(D divides theta)
$
