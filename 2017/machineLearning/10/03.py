import numpy as np
import matplotlib.pyplot as plt

A = np.random.normal(size=(2,2))
sigma = A.dot( A.T )

mu = np.random.normal(size=2)

def sampling_p1( x2 ):
    mu1 = mu[0] + sigma[0][1]/sigma[1][1]*(x2-mu[1])
    sigma1 = sigma[0][0] - sigma[0][1]/sigma[1][1]*sigma[1][0]
    x1 = np.random.normal(mu1,sigma1)
    return x1

def sampling_p2( x1 ):
    mu2 = mu[1] + sigma[1][0]/sigma[0][0]*(x1-mu[0])
    sigma2 = sigma[1][1] - sigma[1][0]/sigma[0][0]*sigma[0][1]
    x2 = np.random.normal(mu2,sigma2)
    return x2


num = 1000
burn_in = int(num*0.2)

x = np.zeros((num,2))
for i in range(0,num-1):
    x[i+1][0] = sampling_p1( x[i][1] )
    x[i+1][1] = sampling_p2( x[i+1][0] )

l,v = np.linalg.eig(sigma)
scaled_v = l * v
plt.scatter(x[burn_in:,0],x[burn_in:,1],color="green", s=10)
plt.arrow(mu[0],mu[1],scaled_v[0][0],scaled_v[1][0],color="blue",lw=4)
plt.arrow(mu[0],mu[1],scaled_v[0][1],scaled_v[1][1],color="red",lw=4)
plt.axis("equal")
plt.show()
