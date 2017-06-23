import numpy as np
import matplotlib.pyplot as plt

def k_nearest( X, Y, T, ks):
    dist = [ np.linalg.norm(T-x) for x in X ]
    data = zip(dist,Y)
    data = sorted(data,key=lambda x:x[0])
    result = []
    for k in ks:
        count = np.array([0]*10)
        for i in range(k):
            _,c = data[i]
            count[c] += 1
        result += [np.argmax(count)]
    return result

def CrossValidation( Xs, Ys, ks ):
    t = len(Xs)
    accuracy = {}
    for k in ks:
        accuracy[k] = np.zeros(t)
        
    for j in range(t):
        X = []
        Y = []
        TX = []
        TY = []

        for i in range(t):
            if i == j:
                TX += Xs[i]
                TY += Ys[i]
            else:
                X += Xs[i]
                Y += Ys[i]

        for x,y in zip(TX,TY):
            result = k_nearest(X,Y,x,ks)
            for res,k in zip(result,ks):
                if res == y:
                    accuracy[k][j] += 1.
                    
        for k in ks:
            accuracy[k][j] /= len(TX)

    return [ np.average(accuracy[k]) for k in ks ]


train = [ np.loadtxt("data/digit_train%d.csv" % i,delimiter=",",dtype=float) for i in range(10) ]
test = [ np.loadtxt("data/digit_test%d.csv" % i,delimiter=",",dtype=float) for i in range(10) ]

t = 10
Xs = [[] for _ in range(t)]
Ys = [[] for _ in range(t)]
for i,tr in enumerate(train):
    for x in tr:
        j = np.random.randint(0,t)
        Xs[j] += [x]
        Ys[j] += [i]
ks = range(1,11)

accuracy =  CrossValidation(Xs,Ys,ks)

plt.xlabel("k")
plt.ylabel("accuracy")
plt.plot(ks,accuracy)
plt.show()

k = ks[np.argmax(accuracy)]

X = [ x for SX in Xs for x in SX]
Y = [ y for SY in Ys for y in SY]

result = np.zeros((10,10),dtype=np.int)
for i in range(10):
    for t in test[i]:
        result[i][k_nearest(X,Y,t,[k])[0]] += 1

print result
    
