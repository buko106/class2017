import numpy as np
import matplotlib.pyplot as plt

n = 600
alpha = 0.1
n1 = np.sum(np.random.rand(n)<alpha)
n2 = n-n1
s = np.array([[1,0],[0,9]])
x1 = np.random.multivariate_normal([ 2,0],s,n1)
x2 = np.random.multivariate_normal([-2,0],s,n2)

# solve

sigma1 = np.cov(x1[:,0],x1[:,1])
sigma2 = np.cov(x2[:,0],x2[:,1])
sigma  = (x1.size * sigma1 + x2.size * sigma2 ) / (x1.size+x2.size)
m1     = np.average(x1,axis=0)
m2     = np.average(x2,axis=0)
sinv   = np.linalg.inv(sigma)
a      = sinv.dot(m1-m2)
b      = -0.5*(m1.dot(sinv.dot(m1))-m2.dot(sinv.dot(m2))) + np.log(float(x1.size)/float(x2.size))

# a[0]*x + a[1]*y + b = 0
# x = (a[1]*y+b)/(-a[0])

plt.plot(x1[:,0],x1[:,1],".")
plt.plot(x2[:,0],x2[:,1],".")
y = np.array(plt.ylim()) # to draw line
plt.plot((a[1]*y+b)/(-a[0]),y,"-",lw=3)
plt.show()
