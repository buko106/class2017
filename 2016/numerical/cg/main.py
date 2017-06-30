# -*- coding: utf-8 -*-
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from scipy.sparse import csr_matrix,lil_matrix

def cg_method( A, b, x=None ):
    eps = 1.0E-12
    if not x:
        x = np.zeros_like(b)
    

    r = b - A.dot(x)
    p = r
    xs = []

    while np.linalg.norm(r)/np.linalg.norm(b) >= eps:
        Ap = A.dot(p)
        alpha = np.dot(r,r) / np.dot( p, Ap )
        x = x + alpha * p
        nr = r - alpha * Ap
        beta = np.dot(nr,nr) / np.dot(r,r)
        p = nr + beta * p
        
        r = nr
        xs += [x]
    return np.array(xs)


F = lambda x,y : 8.0 * np.pi * np.pi * np.sin(2*np.pi*x) * np.sin(2*np.pi*y)
U = lambda x,y : np.sin(2*np.pi*x) * np.sin(2*np.pi*y)

def finite_difference_method_Dirichlet( nx, ny=None, f=F, a=U,xlim=np.array([0.0,1.0]), ylim=np.array([0.0,1.0]) ):
    if not ny:
        ny = nx
    size = (nx-1)*(ny-1)
    A = lil_matrix((size,size))
    dx = (xlim[1]-xlim[0])/nx
    dy = (ylim[1]-ylim[0])/ny
    for i in range(0,nx-1):
        for j in range(0,ny-1):
            # set values for [i,j]
            pos = i*(ny-1)+j
            A[pos,pos]   = 2 * (dx**-2 + dy**-2)
            if j > 0 :
                A[pos,pos-1] = -dy**-2
            if j < ny-2 :
                A[pos,pos+1] = -dy**-2
            if i > 0 :
                A[pos,pos-(ny-1)] = -dx**-2
            if i < nx-2 :
                A[pos,pos+(ny-1)] = -dx**-2
    b = np.zeros(size)
    u = np.zeros(size)
    for i in range(0,nx-1):
        for j in range(0,ny-1):
            # set values for [i,j]
            pos = i*(ny-1)+j
            x = xlim[0] + (i+1)*dx
            y = ylim[0] + (j+1)*dy
            b[pos] = f(x,y)
            u[pos] = a(x,y)
            if j == 0 :
                b[pos] += a(x,ylim[0]) * dy**-2
            if j == ny-2 :
                b[pos] += a(x,ylim[1]) * dy**-2
            if i == 0 :
                b[pos] += a(xlim[0],y) * dx**-2
            if i == nx-2 :
                b[pos] += a(xlim[1],y) * dx**-2
    #
    A = csr_matrix(A)
    xs = cg_method(A,b)
    Z = np.zeros((nx+1,ny+1))
    Z[1:nx,1:ny] = xs[-1].reshape(nx-1,ny-1)
    for i in range(0,nx+1):
        x = xlim[0] + i*dx
        Z[i, 0] = a(x,ylim[0])
        Z[i,ny] = a(x,ylim[1])
        
    for j in range(0,ny+1):
        y = ylim[0] + j*dy
        Z[ 0,j] = a(xlim[0],y)
        Z[nx,j] = a(xlim[1],y)
        
    x = np.linspace( xlim[0], xlim[1], nx+1)
    y = np.linspace( ylim[0], ylim[1], ny+1)
    X, Y = np.meshgrid(x, y, indexing='ij')
    R = b - A.dot(u)


    return X, Y, Z, np.max(np.abs(R)), xs.shape[0]

def test_for_cg_method( n ):
    A = np.random.randn(n,n)
    b = np.random.randn(n)
    AA = np.dot(A.T,A)
    x = np.linalg.solve(AA,b)
    xs = cg_method(AA,b)
    plt.yscale("log")
    plt.plot(np.linalg.norm(xs-x,axis=-1))
    plt.show()
    
def plot3D( X, Y, Z, ANS ):
    fig = plt.figure()
    ax = Axes3D(fig)
    ax.scatter(X,Y,Z,color="blue")
    ax.plot_wireframe(X,Y,ANS,color="red")
    plt.savefig("3D.eps")

    
if __name__ == "__main__":

    # test_for_cg_method( n )
    #
    # exit()
    #
    
    
    origin = [0.0,-0.5]
    length = [1.0,1.0]
    xlim = np.array([origin[0],origin[0]+length[0]])
    ylim = np.array([origin[1],origin[1]+length[1]])
    
    print("n, iter, max(|b-Au(xi,yj)|), max(|u(xi,yj)-u_ij|)")
    # ns = range(10,211,20)
    ns = np.power( 2, np.linspace(4.,8.,10) ).astype(int)
    data = []
    for i in ns:
        nx = i
        ny = i
        X, Y, Z, error_consistency, num = finite_difference_method_Dirichlet( nx , ny, f=F, a=U, xlim=xlim, ylim=ylim )

        error_convergence = np.max(np.abs(U(X,Y)-Z))
        print(nx,num,error_consistency,error_convergence)
        data += [ [nx,num,error_consistency,error_convergence] ]
        if i == ns[0]:
            plot3D( X, Y, Z, U(X,Y) )
        
    data = np.array(data)

    plt.close()
    plt.plot(data[:,0],data[:,1],"o-")
    plt.xlabel("n")
    plt.ylabel("iteration")
    plt.savefig("iteration.eps")
        
    plt.close()
    plt.plot(1/data[:,0],data[:,1],label="iteration")
    plt.plot(1/data[:,0],data[:,2],label="max(|b-Au(x_i,y_j)|)")
    plt.plot(1/data[:,0],data[:,3],label="max(|u(x_i,y_j)-u_i,j|)")
    plt.legend(loc="center left")
    plt.xlabel("h")
    plt.xscale("log")
    plt.yscale("log")
    plt.axis("equal")
    plt.grid(which="both")
    plt.savefig("loglog.eps")
