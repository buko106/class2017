import numpy as np
from scipy.special import gamma
prior_param = [ 1.0, 0.1, 5.0 ]
pivot = [ 0.5, 0.8 ]


for prior in prior_param:
    print("a=b=%f"%prior)
    a,b = prior+4,prior+1
    for p in pivot:
        num = 5000000
        pi = np.linspace(p,1.0-1.0e-10,num)
        f = (gamma(a+b)/(gamma(a)*gamma(b))) * pi**(a-1) * (1-pi)**(b-1)
        h = (1-p)/num
        ans = np.sum(f)*h
        print("p(pi>=%f|data)=%f" % (p,ans))
