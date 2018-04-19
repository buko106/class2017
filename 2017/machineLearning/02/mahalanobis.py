import numpy as np
import sys

def logp( x , mean_y , logsdet_y , s_yinv , num_y ):
    return -0.5*(x-mean_y).dot( s_yinv.dot(x-mean_y) ) - 0.5*logsdet_y+np.log(num_y)

train = [ np.loadtxt("data/digit_train%d.csv" % i,delimiter=",",dtype=float).transpose() for i in range(10) ]
test = [ np.loadtxt("data/digit_test%d.csv" % i,delimiter=",",dtype=float).transpose() for i in range(10) ]

sigma = [ np.cov(train[i])+0.00000001*np.eye(train[i].shape[0]) for i in range(10) ]
mean  = [ np.average(train[i],axis=1) for i in range(10) ]

n_y = [ train[i].shape[1] for i in range(10) ]
n = np.sum(n_y)

sinv = np.linalg.inv(sigma)
L,V = np.linalg.eig(sigma)
logsdet = [ np.sum( np.log(l) ) for l in L ]

result = []
for c in range(0,10):
    for i in range(test[c].shape[1]):
        ps = [ logp( test[c][:,i] ,  mean[y] , logsdet[y] , sinv[y] , n_y[y] )  for y in range(10) ]# likely-hood of y
        y = ps.index(max(ps))
        result.append((c,y))

num = [ [0]*10 for i in range(10) ]
for (c,y) in result:
    num[c][y] += 1

for ns in num:
    for n in ns:
        sys.stdout.write("%4d"%n)
    sys.stdout.write("\n")
