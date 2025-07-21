import gurobipy as gp
from gurobipy import GRB
from gurobipy import nlfunc as nl


gamma = 0.3
n = 32
s02 = 1
m0 = 5


model = gp.Model()
UB = m0 * 2

sd2 = 0.11  # m.addVar(lb=-UB, ub=UB, name="sd2")
md = 1      # m.addVar(lb=-UB, ub=UB, name="md")
sa2 = model.addVar(lb=0, ub=UB, name="sa2")
ma = model.addVar(lb=0, ub=UB, name="ma")

E0wa = model.addVar(lb=0, ub=1, name="E_0[wa]")
Eaw0 = model.addVar(lb=0, ub=1, name="E_a[w0]")
V0Za = model.addVar(lb=0, ub=GRB.INFINITY, name="V_0[Za]")
VaZ0 = model.addVar(lb=0, ub=GRB.INFINITY, name="V_a[Z0]")
E0Za = model.addVar(lb=-GRB.INFINITY, ub=GRB.INFINITY, name="E_0[Za]")
EaZ0 = model.addVar(lb=-GRB.INFINITY, ub=GRB.INFINITY, name="E_a[Z0]")

# fmt: off
model.addGenConstrNL(E0wa, nl.logistic(1.702*(E0Za - md)/nl.sqrt(sd2 + V0Za)))    # noqa: E501
model.addGenConstrNL(Eaw0, nl.logistic(1.702*(EaZ0 - md)/nl.sqrt(sd2 + VaZ0)))    # noqa: E501
model.addGenConstrNL(V0Za, n*(s02**2/(2*sa2**2) + s02*(m0-ma)**2/sa2**2 + 0.5 - s02/sa2))  # noqa: E501
model.addGenConstrNL(VaZ0, n*(sa2**2/(2*s02**2) + sa2*(ma-m0)**2/s02**2 + 0.5 - sa2/s02))  # noqa: E501
model.addGenConstrNL(E0Za, n*(nl.log(s02/sa2) - (s02 + (m0-ma)**2)/(2*sa2) + 0.5))     # noqa: E501
model.addGenConstrNL(EaZ0, n*(nl.log(sa2/s02) - (sa2 + (ma-m0)**2)/(2*s02) + 0.5))     # noqa: E501
# fmt: on

model.setObjective(gamma*E0wa + (1-gamma)*Eaw0, sense=GRB.MAXIMIZE)
model.optimize()

# model.write("fil.mps")

print(f"v0Za: {V0Za.X}")
print(f"vaZ0: {VaZ0.X}")
print(f"e0Za: {E0Za.X}")
print(f"eaZ0: {EaZ0.X}")
print(f"e0wa: {E0wa.X}")
print(f"eaw0: {Eaw0.X}")

print(f"sa2: {sa2.X}")
print(f"ma : {ma.X}")

print(f"Obj: {model.ObjVal}")
