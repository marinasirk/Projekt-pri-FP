import random
import math
import numpy

# funkcija tocke(n, a, b) nam da seznam nakljucnih tock v ravnini
# nakljucno izberemo 2n tock v ravnini, n je poljuben
# parametra a in b podata interval, v katerem izbiramo nakljucna stevila

def tocke(n, a, b):
    points = []
    i = 1

    while i <= 2*n:
        (x, y) = (random.uniform(a, b), random.uniform(a, b))
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


# v naslednji vrstici si izberemo poljuben n, a in b, to je vse kar moramo narediti, potem samo še zaženemo program
t = tocke(n=5, a=0, b=10)
A = matrika_povezav(t)
d = len(A)
print "Tocke = ", t
print "A = \n", numpy.array(A)


# PROBLEM 1
# sedaj napisemo linearni program

p = MixedIntegerLinearProgram(maximization = False)
X = p.new_variable(binary = True)

# minimiziramo skupno dolzino povezav
p.set_objective(sum(sum(A[i][j]*X[i, j] for j in range(i, d)) for i in range(d)))

# dodamo pogoje
# pogoj 1 poskrbi, da je vsaka tocka povezana z natanko eno drugo točko
for i in range(d):
    p.add_constraint(sum(X[i, j] for j in range(d)) == 1)

# pogoj 2 poskrbi, da je matrika X simetricna
for i in range(d):
    for j in range(d):
        p.add_constraint(X[i, j] == X[j, i])

# pogoj 3 poskrbi, da so diagonalne vrednosti enake 0, torej tocka ne sme biti povezana sama s sabo
for i in range(d):
    p.add_constraint(X[i, i] == 0)

# p.solve()
min_dolzina1 = p.solve()
print "Resitev problema 1: ", min_dolzina1

resitev1 = p.get_values(X)

Resitev1 = []
for i in range(d):
    for j in range(d):
        if resitev1[i, j] == 1:
            Resitev1.append((i + 1,j + 1))

print "Seznam povezav pri problemu 1: ", Resitev1


# PROBLEM 2

A = numpy.array(A)
B = A[:d/2, d/2:]     # vrstice do izključno d/2, stolpci od vključno d/2

# matrika B je zgornja desna cetrtina matrike A, definiramo jo pa zato, ker sedaj lahko povezemo samo tocke razlicnih barv, zato nas povezave med tockami istih barv ne zanimajo

q = MixedIntegerLinearProgram(maximization = False)
Y = q.new_variable(binary = True)

# minimiziramo skupno dolzino povezav
q.set_objective(sum(sum(B[i][j]*Y[i, j] for j in range(d/2)) for i in range(d/2)))

# dodamo pogoje
# naslednja dva pogoja poskrbita, da je vsaka tocka povezana z natanko eno tocko druge barve
for i in range(d/2):
    q.add_constraint(sum(Y[i, j] for j in range(d/2)) == 1)        # vsota po stolpcih enaka 0
for j in range(d/2):
    q.add_constraint(sum(Y[i, j] for i in range(d/2)) == 1)        # vsota po vrsticah enaka 0

min_dolzina2 = q.solve()
print "Resitev problema 2: ", min_dolzina2

resitev2 = q.get_values(Y)

Resitev2 = []
for i in range(d/2):
    for j in range(d/2):
        if resitev2[i, j] == 1:
            Resitev2.append((i + 1, d/2 + j + 1))

print "Seznam povezav pri problemu 2: ", Resitev2
