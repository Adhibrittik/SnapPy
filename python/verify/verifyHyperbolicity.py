
def verify_logarithmic_gluing_equations_and_positively_oriented_tets(
        manifold, shape_intervals, verbose = False):

    """
    Given a SnapPy manifold manifold and complex intervals for the shapes
    shape_intervals that are certified to contain a solution to the
    rectangular gluing equations, verify that the logarithmic gluing equations
    are also fulfilled and that all shapes have positive imaginary part.
    This is sufficient to prove that the manifold is indeed hyperbolic.
    
    Since the given interval are supposed to contain a true solution of
    the rectangular gluing equations, the logarithmic gluing equations
    are known to be fulfilled up to a multiple of 2 pi i. Thus it is enough
    to certify that the  absolute error of the logarithmic gluing
    equations is < 0.1. Using interval arithmetic, this function certifies
    this and positivity of the imaginary parts of the shapes.

    >>> from snappy import Manifold
    >>> M = Manifold("m019")
    >>> verify_logarithmic_gluing_equations_and_positively_oriented_tets(
    ...    M, M.tetrahedra_shapes('rect', intervals=True))
    True

    The SnapPy triangulation of the following hyperbolic manifold contains
    actually negatively oriented tetrahedra:

    >>> M = Manifold("t02774")
    >>> verify_logarithmic_gluing_equations_and_positively_oriented_tets(
    ...    M, M.tetrahedra_shapes('rect', intervals=True), verbose = True)
    Shape with non-positive imaginary part
    False

    """

    # Check that the shapes have positive imaginary part.
    for shape in shape_intervals:
        if not shape.imag() > 0:
            if verbose:
                print("Shape with non-positive imaginary part")
            return False

    # Compute the logarithms of z, z', z''
    logZ   = [             z.log() for z in shape_intervals ]
    logZp  = [ (1 / (1 - z)).log() for z in shape_intervals ]
    logZpp = [ ((z - 1) / z).log() for z in shape_intervals ]

    # A list 
    #    log(z_0) log(z'_0) log(z''_0) log(z_1) log(z'_1) log (z''_1) ...
    logs = [ z for triple in zip(logZ, logZp, logZpp) for z in triple ]

    # Number of tetrahedra and cusps
    n_tet = manifold.num_tetrahedra()
    n_cusps = manifold.num_cusps()

    # The gluing equations in logarithmic form
    equations = manifold.gluing_equations()

    # Compute the LHS of the gluing equations
    #     a_0 * log(z_0) + b_0 * log(z'_0) + c_0 * log(z''_0) + ...
    # Also, see manifold.gluing_equations
    LHSs = [
        sum([l * expo for l, expo in zip(equation, logs)])
        for equation in equations ]

    # Get the ComplexIntervalField of the shape intervals
    BaseField = shape_intervals[0].parent()
    # 2 pi i in that field
    TWO_PI_I = BaseField.pi() * BaseField(2j)

    # Index of the next gluing equation to check
    LHS_index = 0

    # The first n_tet gluing equations are edge equations
    for edge_index in range(n_tet):
        # An edge equation should sum up to 2 pi i
        if not abs(LHSs[LHS_index] - TWO_PI_I) < 0.1:
            if verbose:
                print("Edge equation %d failed" % edge_index)
            return False
        LHS_index += 1
        
    # Then there are one, respectively, two equations per cusp
    for cusp_index in range(n_cusps):

        # For a complete cusp, we have two equations (meridian
        # and longitude), for both of them the log's add up to 0

        # For a filled cusp, we have only one equation (for the
        # curve we fill), the log's add up to 2 pi i.
        num_LHSs, value = (
            (2, 0) if manifold.cusp_info(cusp_index)['complete?'] else
            (1, TWO_PI_I))

        # Check the one or two equations
        for j in range(num_LHSs):
            if not abs(LHSs[LHS_index] - value) < 0.1:
                if verbose:
                    print("Equation %d for cusp %d failed" % (j, cusp_index))
                return False
            # Advance to the next gluing equation
            LHS_index += 1

    return True
    

def verify_hyperbolicity(manifold, verbose = False, bits_prec = 53):

    """
    Given an orientable SnapPy Manifold, verifies its hyperbolicity.
    Similar to HIKMOT's verify_hyperbolicity, the result is either
    (True, listOfShapeIntervals) or (False, []) if verification failed.
    listOfShapesIntervals is a list of complex intervals (elements in
    sage's ComplexIntervalField) certified to contain the true shapes
    for the hyperbolic manifold.

    Higher precision intervals can be obtained by setting bits_prec.

    >>> from snappy import Manifold
    >>> M = Manifold("m019")
    >>> verify_hyperbolicity(M)
    (True, [0.7805525278508? + 0.9144736629678?*I, 0.7805525278508? + 0.91447366296773?*I, 0.46002117557372? + 0.63262419360526?*I])
    
    >>> M = Manifold("t02333(3,4)")
    >>> verify_hyperbolicity(M)
    (True, [2.152188153612? + 0.28494066790?*I, 1.92308491369? + 1.10360701507?*I, 0.014388591584? + 0.143084469681?*I, -2.5493670288? + 3.7453498408?*I, 0.142120333822? + 0.176540027036?*I, 0.50486686588? + 0.82829881681?*I, 0.50479249917? + 0.98036162786?*I, -0.58949570508? + 0.81267480427?*I])

    A non-hyperbolic manifold

    >>> M = Manifold("t02333(1,0)")
    >>> verify_hyperbolicity(M)
    (False, [])

    Under the hood, the function will call the CertifiedShapesEngine to produce
    intervals certified to contain a solution to the rectangular gluing equations.
    It then calls verify_logarithmic_gluing_equations_and_positively_oriented_tets
    to verify that the logarithmic gluing equations are fulfilled and that all
    tetrahedra are positively oriented.
    """

    try:
        shape_intervals = manifold.tetrahedra_shapes(
            'rect', bits_prec = bits_prec, intervals = True)
    except:
        if verbose:
            print("Could not certify solution to rectangular gluing equations")
        return False, []

    if not verify_logarithmic_gluing_equations_and_positively_oriented_tets(
            manifold, shape_intervals, verbose = verbose):
        return False, []

    return True, shape_intervals