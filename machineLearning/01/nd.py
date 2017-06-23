
import numpy as np
import matplotlib.pyplot as plt

n = 1000
mean = [1,2]
cov  = [[2,1],[1,4]]
xy = np.random.multivariate_normal(mean,cov,n)
x  = xy[:,0]
y  = xy[:,1]

l,v = np.linalg.eig(cov)
e0 = np.array([mean,mean+l[0]*v[:,0]])
e1 = np.array([mean,mean+l[1]*v[:,1]])
plt.plot(x,y,".")
plt.plot(e0[:,0],e0[:,1],lw=10)
plt.plot(e1[:,0],e1[:,1],lw=10)
# print(xy)
# print(x)
# print(y)
plt.axis("equal")
plt.show()
