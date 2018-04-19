import numpy as np
from scipy.special import gamma
prior_param = [ 1.0, 0.1, 5.0 ]

eps = 1.0e-10

for prior in prior_param:
    print("a=b=%f"%prior)
    a,b = prior+5,prior+15
    num = 1000000
    if True:
        pi = np.linspace(eps,1-eps,num)
        f = (2*(1-pi)/pi) * (gamma(a+b)/(gamma(a)*gamma(b))) * pi**(a-1) * (1-pi)**(b-1)
        h = 1./num
        ans = np.sum(f)*h
        print("E[   x   |data] = %f"%ans)
    if True:
        pi = np.linspace(eps,0.1,num)
        f = (gamma(a+b)/(gamma(a)*gamma(b))) * pi**(a-1) * (1-pi)**(b-1)
        h = 0.1/num
        ans = np.sum(f)*h
        print("E[pi<=0.1|data] = %f"%ans)
        

