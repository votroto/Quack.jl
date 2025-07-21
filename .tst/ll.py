import gurobipy as gp
from gurobipy import GRB
from gurobipy import nlfunc as nl

model = gp.Model()
E0wa = model.addVar(lb=0, ub=1, name="E_0[wa]")
model.addGenConstrNL(E0wa, nl.logistic(1.702*E0wa))
# fmt: on

model.setObjective(3*E0wa, sense=GRB.MAXIMIZE)
model.optimize()

model.write("fil.mps")