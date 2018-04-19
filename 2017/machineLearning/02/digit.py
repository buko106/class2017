import numpy as np
import sys

def logp( x , mean_y , sinv , num_y ):
    return mean_y.dot(sinv.dot(x)) - 0.5*mean_y.dot(sinv.dot(mean_y)) + np.log(num_y)

train = [ np.loadtxt("data/digit_train%d.csv" % i,delimiter=",",dtype=float).transpose() for i in range(10) ]
test = [ np.loadtxt("data/digit_test%d.csv" % i,delimiter=",",dtype=float).transpose() for i in range(10) ]

sigma = [ np.cov(train[i]) for i in range(10) ]
mean  = [ np.average(train[i],axis=1) for i in range(10) ]

n_y = [ train[i].shape[1] for i in range(10) ]
n = np.sum(n_y)
s = np.average( [(n_y[i]*sigma[i])/n for i in range(10)] , axis = 0 )
sinv = np.linalg.inv(s)

result = []
for c in range(0,10):
    for i in range(test[c].shape[1]):
        ps = [ logp( test[c][:,i] ,  mean[y] , sinv , n_y[y] )  for y in range(10) ]# likely-hood of y
        result.append((c,ps.index(max(ps))))

num = [ [0]*10 for i in range(10) ]
for (c,y) in result:
    num[c][y] += 1

for ns in num:
    for n in ns:
        sys.stdout.write("%4d"%n)
    sys.stdout.write("\n")
