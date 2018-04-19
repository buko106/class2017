import numpy as np
import matplotlib.pyplot as plt

def myrand(n):
    x = np.zeros(n)
    u = np.random.rand(n)
    
    flag = np.logical_and(0.<=u,u<1./8.)
    x[flag] = np.sqrt(8*u[flag])
    
    flag = np.logical_and(1./8.<=u,u<1./4.)
    x[flag] = 2. - np.sqrt( 2 - 8*u[flag] )

    flag = np.logical_and(1./4.<=u,u<1./2.)
    x[flag] = 1 + 4*u[flag]

    flag = np.logical_and(1./2.<=u,u<3./4.)
    x[flag] = 3 + np.sqrt(4*u[flag]-2)

    flag = np.logical_and(3./4.<=u,u<=1)
    x[flag] = 5 - np.sqrt(4-4*u[flag])

    return x

def K(x):
    return np.exp(-0.5*(x**2)) / ((2.*np.pi)**0.5)

def p_estimated( x, xi, n, h ):
    return (1./n/h) * np.sum(K((x-xi)/h))

def CrossValidation( T, hs ):
    t = len(T)
    LCV = {}
    for h in hs:
        LCV[h] = np.zeros(t)

    for j in range(t):
        xi = []
        Tj = []
        for i in range(t):
            if i == j:
                Tj += T[i]
            else:
                xi += T[i]

        xi = np.array(xi)
        n = xi.size
        Tj = np.array(Tj)

        for h in hs:
            LCV[h][j] = np.average(np.log([ p_estimated(x,xi,n,h) for x in Tj ]))

    return np.array([[h,np.average(LCV[h])] for h in hs])

n = 1000
xi = myrand(n)
t = 10

c = np.random.randint(0,t,n)
T = [ [] for _ in range(t) ]
for j,x in zip(c,xi):
    T[j].append(x)

LCV = CrossValidation( T, np.logspace(-2.,-0.5,10) )
h = LCV[np.argmax(LCV[:,1]),0]
xs = np.linspace(0,5,1000)
p = np.array([ p_estimated(x,xi,n,h) for x in xs ])


plt.hist(xi,bins=50,normed=True)
plt.plot(xs,p,lw=3,c="r")
plt.title("h="+str(h))
plt.show()
plt.close

plt.xlabel("h")
plt.ylabel("LCV")
plt.plot(LCV[:,0],LCV[:,1])
plt.show()
