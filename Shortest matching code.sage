import random
import math
import numpy
from sage.plot.point import Point

# funkcija tocke(n, a, b) nam da seznam nakljucnih tock v ravnini
# najprej nakljucno izberemo 2n tock v ravnini, n je poljuben
# izberemo si a in b, ki podata interval, v katerem izbiramo nakljucno stevilo

def tocke(n, a, b):
    points = []
    i = 1

    while i <= 2*n:
        (x, y) = (random.uniform(a, b), random.uniform(a, b))        # ali random.int(a, b) za cela števila
        points.append((x, y))
        i += 1

    return points

# naredimo matriko dolzine povezav med tockami
# razdalja med (x1, y1) in (x2, y2) je sqrt((x1-x2)^2+(y1-y2)^2)

def matrika_povezav(points):
    A = []
    k = 0
    stevilo_tock = len(points)

    while k <= (stevilo_tock - 1):
        point = points[k]       # k-ta tocka
        x_koord = point[0]      # x koordinata k-te tocke
        y_koord = point[1]      # y koordinata k-te tocke
        razdalje = []           # razdalje od k-te tocke do vseh tock v ravnini

        for tocka in points:
            x = tocka[0]
            y = tocka[1]
            dolzina = math.sqrt((x_koord - x)**2 + (y_koord - y)**2)
            razdalje.append(dolzina)

        A.append(razdalje)
        k += 1

    return A


# izberi si n, a in b
t = tocke(n=1, a=0, b=10)
A = matrika_povezav(t)
d = len(A)
print "t = ", t
print "A = \n",numpy.array(A)

# show(points(t, color='darkgreen', pointsize=50), aspect_ratio=1)


# PROBLEM 1
# sedaj napisemo linearni program

p = MixedIntegerLinearProgram(maximization = False)
X = p.new_variable(binary = True)





p.set_objective(sum(sum(A[i][j]*X[i, j] for j in range(i, d)) for i in range(d)))

# dodamo pogoje
# pogoj 1 poskrbi, da je vsaka tocka povezana z natanko eno drugo točko
for i in range(d):
    p.add_constraint(sum(X[i, j] for j in range(d)) == 1)

# pogoj 2 poskrbi, da so elementi matrike X lahko 0 ali 1, če je X binary, tega ne rabimo
#for i in range(d):
#    for j in range(d):
#        pass

# pogoj 3 poskrbi, da je matrika X simetricna
for i in range(d):
    for j in range(d):
        p.add_constraint(X[i, j] == X[j, i])

# pogoj 4 poskrbi, da so diagonalne vrednosti enake 0, torej tocka ne sme biti povezana sama s sabo
for i in range(d):
    p.add_constraint(X[i, i] == 0)

p.solve()

resitev1 = p.get_values(X)

Resitev1 = []
for i in range(d):
    for j in range(d):
        if resitev1[i, j] == 1:
            Resitev1.append((i,j))
print "Resitev Problema 1: ", Resitev1

# PROBLEM 2

q = MixedIntegerLinearProgram(maximization = False)
Y = q.new_variable(binary = True)

q.set_objective(sum(sum(A[i][j]*Y[i, j] for j in range(i+1, d)) for i in range(d)))

# dodamo pogoje
# pogoj 1 poskrbi, da je vsaka tocka povezana z natanko eno tocko druge barve in z nobeno iste barve
for i in range(d/2):
    q.add_constraint(sum(Y[i, j] for j in range(d/2, d)) == 1)
for j in range(d/2):
    q.add_constraint(sum(Y[i, j] for i in range(d/2, d)) == 1)

q.solve()

resitev2 = q.get_values(Y)

Resitev2 = []
for i in range(d):
    for j in range(d):
        if resitev2[i, j] == 1:
            Resitev2.append((i,j))
print "Resitev Problema 2: ", Resitev2
