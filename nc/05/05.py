import numpy as np
import matplotlib.pyplot as plt

k = 1.0 ; a = 1.0 ; c = 2.0 ; D = 0.5

# x, y, z for A, B, C respectively.
pos = np.array([[1,0,0,0,0,0],
                [0,1,0,0,0,0],
                [0,0,1,0,0,0],
                [0,0,1,0,0,0],
                [1,0,0,0,0,0],
                [0,1,0,0,0,0]],dtype=np.float)

neg = np.array([[0,0,0,1,0,0],
                [0,0,0,0,1,0],
                [0,0,0,0,0,1],
                [0,0,0,0,0,0],
                [0,0,0,0,0,0],
                [0,0,0,0,0,0]],dtype=np.float)

def f( x ):
    return ((k*a)*np.dot(pos,x)) / (np.ones_like(x)+a*np.dot(pos,x)+c*np.dot(neg,x)) - D*x


if __name__=="__main__":
    x = np.random.uniform(size=6)
    dt = 0.1
    n = int(300/dt)
    result = []

    for i in range(n):
        result+=[x]
        p = x
        k1 = f(p)
        p = x + k1 * 0.5 * dt
        k2 = f(p)
        p = x + k2 * 0.5 * dt
        k3 = f(p)
        p = x + k3 * dt
        k4 = f(p)
        x = x + (k1+2.0*k2+2.0*k3+k4)*(dt/6.)

    result = np.array(result)
    t = dt * np.array(range(n))
    plt.plot(t,result[:,0],label="A")
    plt.plot(t,result[:,1],label="B")
    plt.plot(t,result[:,2],label="C")
    plt.legend()
    plt.show()
    
