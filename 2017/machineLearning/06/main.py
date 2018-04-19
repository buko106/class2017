import numpy as np
import matplotlib.pyplot as plt

def centering_and_sphering( X ): # X = ( x_1 | x_2 | ... | x_n )
    _, n  = X.shape
    H  = np.eye(n) - np.full( (n,n), 1.0/n )
    XH = np.dot(X,H)
    T  = np.dot(XH,XH.transpose()) / n
    l, P = np.linalg.eig(T)
    L_12 = np.diag( l ** (-0.5) )
    T_12 = np.dot(P, np.dot( L_12, np.linalg.inv(P) ))
    return np.dot( T_12, np.dot( X, H))

def normalized(a):
    return a / np.linalg.norm(a, axis=-1)

def disp2D(X,b,xlabel="",ylabel=""):
    plt.plot(X[0],X[1],".",color="blue")
    xlim = plt.xlim()
    ylim = plt.ylim()
    lx = np.array(plt.xlim())
    ly = lx*b[1]/b[0]
    plt.plot(lx,ly,"-",color="red")
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.xlim(xlim)
    plt.ylim(ylim)
    plt.show()
    
def newton( X, b=None, iter=50, g=lambda x:x**3, dg=lambda x:3*(x**2) ):
    # g and dg must caluculate output elementwizly
    d, n = X.shape

    # normalization (and random generation) of b
    if not b:
        b = normalized( np.random.rand(d) )
    else:
        b = normalized( b )

    iter = 0
    while True:
        old_b = b
        bX = np.dot(b,X)
        b = b*( np.sum( dg(bX) )/n) - np.sum( X * g(bX) , axis=-1) / n
        b = normalized(b)

        eps = 1.e-10
        diff_1 = np.linalg.norm(b-old_b)
        diff_2 = np.linalg.norm(b+old_b)

        if iter>50 and min(diff_1,diff_2) < eps:
            break
        iter += 1

    return b
        
if __name__ == "__main__":
    n = 2000

    X = np.array([np.random.randn(n),np.random.rand(n)])
    X = centering_and_sphering(X)

    b = newton( X )

    plt.title("uniform:g(s)=s^3,g'(s)=3s^2")
    disp2D(X,b,xlabel="normal",ylabel="uniform" )
    plt.title("uniform:g(s)=s^3,g'(s)=3s^2")
    plt.hist( np.dot(b,X) , bins = n/100 )
    plt.show()

    #
    
    X = np.array([np.random.laplace(size=n),np.random.randn(n)])
    X = centering_and_sphering(X)
    
    b = newton( X, g = np.tanh, dg=lambda x:1 - np.tanh(x)**2 )
    
    plt.title("laplace:g(s)=tanh(s),g'(s)=1-tanh^2(s)")
    disp2D(X,b,xlabel="laplace",ylabel="normal")
    plt.title("laplace:g(s)=tanh(s),g'(s)=1-tanh^2(s)")
    plt.hist( np.dot(b,X) , bins = n/100 )
    plt.show()
