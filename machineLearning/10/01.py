import numpy as np
from scipy.special import gamma
prior_param = [ 1.0, 0.1, 5.0 ]
pivot = [ 0.5, 0.8 ]

def beta( x, a, b):
    return (gamma(a+b)/(gamma(a)*gamma(b))) * x**(a-1.0) * (1.0-x)**(b-1.0)

def f( x, a, b):
    return x**(a-1.0) * (1.0-x)**(b-1.0)


def q( x, y ):
    return 1.0

def sampling_q( y ):
    return np.random.uniform(0.0,1.0)

for prior in prior_param:
    print("a=b=%f"%prior)
    a,b = prior+4,prior+1
    for p in pivot:
        num = 500000
        pi = np.linspace(p,1.0-1.0e-10,num)
        f_pi = beta(pi,a,b)
        h = (1-p)/num
        ans = np.sum(f_pi)*h
        print("p(pi>=%f|data)=%f" % (p,ans))
        t = np.zeros(num)
        t[0] = np.random.uniform()
        for i in range(0,num-1):
            t_next = sampling_q(t[i])
            P = min(1.0, q(t[i],t_next)/q(t_next,t[i])*f(t_next,a,b)/f(t[i],a,b))
            u = np.random.uniform(0.0,1.0)
            if u < P:
                t[i+1] = t_next
            else:
                t[i+1] = t[i]
        print("estimated(MH method)=%f\n" % (np.sum(t>=p)/num))
