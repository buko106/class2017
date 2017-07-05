import numpy as np
import matplotlib.pyplot as plt

mu = np.random.randn(2)
m = np.zeros(2)
A = np.random.randn(2,2)
Sigma  = A.T.dot(A)
Lambda = np.linalg.inv(Sigma)
eps = 1e-4
num = 1000
ans = np.random.multivariate_normal(mu,Sigma,num)
plt.scatter(ans[:,0],ans[:,1])
plt.axis("equal")
xlim = plt.xlim()
ylim = plt.ylim()
plt.pause(1.)

while True:
    old_m = m.copy()
    m[0] = mu[0] - (m[1]-mu[1])*Lambda[0,1]/Lambda[0,0]
    m[1] = mu[1] - (m[0]-mu[0])*Lambda[0,1]/Lambda[1,1]
    print(m)
    x = np.random.normal(m[0],1/Lambda[0,0],num)
    y = np.random.normal(m[1],1/Lambda[1,1],num)
    plt.clf()
    plt.axis("equal")
    plt.xlim(xlim)
    plt.ylim(ylim)
    plt.scatter(x,y)
    plt.pause(0.001)
    if np.linalg.norm(m-old_m) < eps:
        break
