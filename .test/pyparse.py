import sys

def parse_input_file(file_path):
    """Parse the input file and aggregate solver times by example."""
    with open(file_path, 'r') as f:
        lines = [line.strip() for line in f.readlines()]

    results = {}
    current_example = None
    current_solver = None

    i = 0
    while i < len(lines):
        line = lines[i]

        # Empty line might indicate a new example follows
        if not line:
            i += 1
            # Check if next line exists and isn't an iter marker
            if i < len(lines) and lines[i] and not lines[i].startswith(";iter"):
                current_example = lines[i]
                results[current_example] = {}
                current_solver = None
                i += 1  # Move past the example name
            continue

        # Check for iteration marker
        if line.startswith(";iter"):
            i += 1
            continue

        # Try to parse as a float
        try:
            value = float(line)
            # It's a float, add to current solver
            if current_example is not None and current_solver is not None:
                results[current_example][current_solver] += value
        except ValueError:
            # Not a float, it's a solver name
            if current_example is not None:  # Make sure we're in an example
                current_solver = line
                if current_solver not in results[current_example]:
                    results[current_example][current_solver] = 0.0

        i += 1

    return results

def generate_tex_table(results):
    """Generate a LaTeX table with examples as rows and solvers as columns."""
    # Collect all unique solvers
    all_solvers = set()
    for example in results.values():
        for solver in example.keys():
            all_solvers.add(solver)

    all_solvers = sorted(list(all_solvers))
    examples = sorted(list(results.keys()))

    # Generate LaTeX table header
    tex = "\\begin{tabular}{l" + "c" * len(all_solvers) + "}\n"
    tex += "\\hline\n"
    tex += "Example & " + " & ".join(all_solvers) + " \\\\\n"
    tex += "\\hline\n"

    # Generate rows
    for example in examples:
        row = [example]
        for solver in all_solvers:
            if solver in results[example]:
                row.append(f"{1000*results[example][solver]:.1f}")
            else:
                row.append("-")
        tex += " & ".join(row) + " \\\\\n"

    # Finish table
    tex += "\\hline\n"
    tex += "\\end{tabular}"

    return tex

def main():

    input_file = sys.argv[1]
    results = parse_input_file(input_file)
    tex_table = generate_tex_table(results)
    print(tex_table)

    # Optionally, write to a file
    with open("results_table.tex", "w") as f:
        f.write(tex_table)

if __name__ == "__main__":
    main()