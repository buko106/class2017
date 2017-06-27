import numpy as np
from scipy.special import gamma
prior_param = [ 1.0, 0.1, 5.0 ]

eps = 1.0e-10

def beta( x, a, b):
    return (gamma(a+b)/(gamma(a)*gamma(b))) * x**(a-1.0) * (1.0-x)**(b-1.0)

def f( x, a, b):
    return x**(a-1.0) * (1.0-x)**(b-1.0)

def q( x, y ):
    if x <= y:
        return 2.0 * x / y
    else:
        return 2.0 * (1.0-x) / (1.0-y)

def sampling_q( y ):
    return np.random.triangular(0.,y,1.)

for prior in prior_param:
    print("a=b=%f"%prior)
    a,b = prior+5,prior+15
    num = 1000000
    
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

    if True:
        pi = np.linspace(eps,1-eps,num)
        f_pi = (2*(1-pi)/pi) * beta(pi,a,b)
        h = 1./num
        ans = np.sum(f_pi)*h
        print("E[   x   |data] = %f"%ans)
        print("estimated(MH method) = %f\n"%(np.sum(2*(1-t)/t)/num))
    if True:
        pi = np.linspace(eps,0.1,num)
        f_pi = beta(pi,a,b)
        h = 0.1/num
        ans = np.sum(f_pi)*h
        print("E[pi<=0.1|data] = %f"%ans)
        print("estimated(MH method) = %f\n"%(np.sum(t<=0.1)/num))
        
