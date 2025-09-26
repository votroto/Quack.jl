# Characterization and computation of local Nash equilibria in continuous games
# Lillian J. Ratliff; Samuel A. Burden; S. Shankar Sastry

function ex_ratliff13_location()
    # NE
    # x=1; y=-1.1
    # x=-1; y=1.1
    # x=0; y=pi ???

    dom_nneg(x) = π^2 - x[1]^2
    dom_null(x) = 0

    alp = (1, 1.05)

    u1(x, y) = cos(x[1]) - alp[1]*cos(x[1] - y[1])
    u2(x, y) = cos(y[1]) - alp[2]*cos(y[1] - x[1])

    (u1, u2), (dom_nneg, dom_nneg), (dom_null, dom_null), (1, 1)
end