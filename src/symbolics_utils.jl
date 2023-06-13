using Symbolics: build_function, get_variables

function compile_sym(sym, vars=get_variables(sym))
    build_function(sym, vars; expression=false)
end