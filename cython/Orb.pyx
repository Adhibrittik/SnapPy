ctypedef double Real

cdef extern from "stdlib.h":
    ctypedef unsigned long size_t
    void* malloc(size_t size)
    void free(void *mem)

cdef extern from "SnapPea.h":
    ctypedef struct Real_struct:
        Real x

    ctypedef struct Complex:
        Real real
        Real imag

cdef extern from "triangulation.h":
    ctypedef struct c_Tetrahedron "Tetrahedron":
        int index
        Real Gram_matrix[4][4]
        c_Tetrahedron *next

cdef extern from "SnapPea.h":
    ctypedef struct EdgeClass:
        EdgeClass* prev
        EdgeClass* next
        int order

    ctypedef struct c_Triangulation "Triangulation":
        c_Tetrahedron  tet_list_begin
        c_Tetrahedron  tet_list_end
        EdgeClass edge_list_begin
        EdgeClass edge_list_end
        int num_generators
        int num_tetrahedra

    ctypedef enum c_SolutionType "SolutionType":
        not_attempted
        geometric_solution
        nongeometric_solution
        flat_solution
        degenerate_solution
        other_solution
        no_solution
        externally_computed

    ctypedef char Boolean

    extern int get_num_tetrahedra(c_Triangulation *manifold) except *

    extern c_SolutionType find_structure( c_Triangulation *manifold, Boolean manual )

    extern double my_volume( c_Triangulation *manifold, Boolean *ok)

cdef extern from "unix_file_io.h":
    extern c_Triangulation *get_triangulation(char *file_name)

cdef extern from "casson_typedefs.h":
    ctypedef struct c_CassonFormat "CassonFormat":
        pass
    
cdef extern from "casson.h":
    extern c_Triangulation *casson_to_triangulation(c_CassonFormat *)
    extern Boolean verify_casson(c_CassonFormat *)
    extern void free_casson(c_CassonFormat *)

cdef extern from "parse_orb.h":
    extern void read_orb(const char * file_name, char **name, c_CassonFormat ** cf, char ** orb_link_projection_data)

cdef class Orbifold(object):
    """

       >>> from snappy import Triangulation
       >>> from snappy.dev.orb_test import __path__ as test_dirs
       >>> import tempfile, os

       >>> test_dir = test_dirs[0]
       >>> dir_obj = tempfile.TemporaryDirectory()
       >>> tmp_dir = dir_obj.name

       >>> o = Orbifold(snappea_path = os.path.join(test_dir, "m004.tri").encode())
       >>> o.num_tetrahedra()
       2
       >>> o.find_structure()
       0
       >>> o.volume() # doctest: +NUMERIC12
       2.0298832128194415
       >>> o.gram_matrices() # doctest: +NUMERIC12
       [[[5.542172900669407e-14, -23.09401076758509, -23.09401076758509, -23.09401076758509], [-23.09401076758509, 5.542172900669407e-14, -23.09401076758509, -23.09401076758509], [-23.09401076758509, -23.09401076758509, 5.542172900669407e-14, -23.09401076758509], [-23.09401076758509, -23.09401076758509, -23.09401076758509, 5.542172900669407e-14]], [[5.542172900669407e-14, -23.09401076758509, -23.09401076758509, -23.09401076758509], [-23.09401076758509, 5.542172900669407e-14, -23.09401076758509, -23.09401076758509], [-23.09401076758509, -23.09401076758509, 5.542172900669407e-14, -23.09401076758509], [-23.09401076758509, -23.09401076758509, -23.09401076758509, 5.542172900669407e-14]]]

       >>> n = Orbifold(orb_path = os.path.join(test_dir, "example1.orb").encode())
       >>> n.num_tetrahedra()
       11
       >>> n.find_structure()
       0
       >>> n.volume() # doctest: +NUMERIC12
       17.465765479338014
       >>> n.gram_matrices() # doctest: +NUMERIC12
       [[[1.717375589279206, -1.6444691182119784, -1.7675765969343664, -1.6444691182119784], [-1.6444691182119784, 0.5381747299511807, -0.5134102280797109, -1.2757799800924705], [-1.7675765969343664, -0.5134102280797109, 0.11206443736252883, -0.5134102280797109], [-1.6444691182119784, -1.2757799800924705, -0.5134102280797109, 0.5381747299511807]], [[1.717375589279206, -1.6444691182119784, -1.6444691182119784, -0.16320984937307226], [-1.6444691182119784, 0.5381747299511807, -1.2757799800924705, -0.0893294349796859], [-1.6444691182119784, -1.2757799800924705, 0.5381747299511807, -0.4983728971277385], [-0.16320984937307226, -0.0893294349796859, -0.4983728971277385, 0.0051983594920345265]], [[1.717375589279206, -1.6444691182119784, -0.16320984937307226, -1.967551006107562], [-1.6444691182119784, 0.5381747299511807, -0.0893294349796859, -1.2757799800924705], [-0.16320984937307226, -0.0893294349796859, 0.0051983594920345265, -0.4983728971277385], [-1.967551006107562, -1.2757799800924705, -0.4983728971277385, 0.5381747299511807]], [[0.5381747299511807, -0.4983728971277385, -1.967551006107562, -1.2757799800924705], [-0.4983728971277385, 0.0051983594920345265, -0.16320984937307226, -1.201697041759719], [-1.967551006107562, -0.16320984937307226, 1.717375589279206, -1.6444691182119784], [-1.2757799800924705, -1.201697041759719, -1.6444691182119784, 0.5381747299511807]], [[0.23050150804982544, -0.3696690384857791, -0.1607203217107846, -0.3696690384857791], [-0.3696690384857791, 0.5381747299511807, -0.5134102280797109, -1.2757799800924705], [-0.1607203217107846, -0.5134102280797109, 0.11206443736252883, -0.5134102280797109], [-0.3696690384857791, -1.2757799800924705, -0.5134102280797109, 0.5381747299511807]], [[0.23050150804982544, -1.4757772757160132, -1.4757772757160132, -0.3696690384857791], [-1.4757772757160132, 0.0051983594920345265, -0.7401704876950608, -1.9398676071685292], [-1.4757772757160132, -0.7401704876950608, 0.0051983594920345265, -1.9906125041115235], [-0.3696690384857791, -1.9398676071685292, -1.9906125041115235, 0.5381747299511807]], [[0.5381747299511807, -0.4983728971277385, -1.2757799800924705, -1.201697041759719], [-0.4983728971277385, 0.0051983594920345265, -1.201697041759719, -0.7401704876950608], [-1.2757799800924705, -1.201697041759719, 0.5381747299511807, -1.9398676071685292], [-1.201697041759719, -0.7401704876950608, -1.9398676071685292, 0.0051983594920345265]], [[0.0051983594920345265, -0.16320984937307226, -1.4757772757160132, -0.7401704876950608], [-0.16320984937307226, 1.717375589279206, -1.8779718991535677, -0.16320984937307226], [-1.4757772757160132, -1.8779718991535677, 0.23050150804982544, -1.4757772757160132], [-0.7401704876950608, -0.16320984937307226, -1.4757772757160132, 0.0051983594920345265]], [[0.0051983594920345265, -0.16320984937307226, -0.7401704876950608, -0.4983728971277385], [-0.16320984937307226, 1.717375589279206, -0.16320984937307226, -1.6444691182119784], [-0.7401704876950608, -0.16320984937307226, 0.0051983594920345265, -1.201697041759719], [-0.4983728971277385, -1.6444691182119784, -1.201697041759719, 0.5381747299511807]], [[0.0051983594920345265, -0.7401704876950608, -1.9398676071685292, -1.9906125041115235], [-0.7401704876950608, 0.0051983594920345265, -1.201697041759719, -1.9398676071685292], [-1.9398676071685292, -1.201697041759719, 0.5381747299511807, -1.2757799800924705], [-1.9906125041115235, -1.9398676071685292, -1.2757799800924705, 0.5381747299511807]], [[0.5381747299511807, -1.2757799800924705, -1.9906125041115235, -0.3696690384857791], [-1.2757799800924705, 0.5381747299511807, -1.9398676071685292, -0.3696690384857791], [-1.9906125041115235, -1.9398676071685292, 0.0051983594920345265, -1.4757772757160132], [-0.3696690384857791, -0.3696690384857791, -1.4757772757160132, 0.23050150804982544]]]

    """

    cdef c_Triangulation* c_triangulation

    def __cinit__(self, snappea_path = None, orb_path = None):
        cdef char * c_path
        cdef char * c_name
        cdef c_CassonFormat * c_cassonFormat
        cdef char * orb_link_projection_data
        
        self.c_triangulation = NULL
        if snappea_path:
            c_path = snappea_path
            self.c_triangulation = get_triangulation(c_path)
        if orb_path:
            c_path = orb_path
            read_orb(c_path, &c_name, &c_cassonFormat, &orb_link_projection_data)
            
            if not verify_casson(c_cassonFormat):
                raise Exception("Invalid file")
            
            self.c_triangulation = casson_to_triangulation(c_cassonFormat)
            free_casson(c_cassonFormat)

            free(c_name)

            free(orb_link_projection_data)

    def num_tetrahedra(self):
        if self.c_triangulation is NULL: return 0
        return get_num_tetrahedra(self.c_triangulation)

    def find_structure(self):
         
        return find_structure(self.c_triangulation, False)
         
    def gram_matrices(self):
         
        cdef c_Tetrahedron* tet
        
        result = []
        
        tet = self.c_triangulation.tet_list_begin.next
        while tet != &(self.c_triangulation.tet_list_end):
            matrix = []
            for i in range(4):
                row = []
                for j in range(4):
                    row.append(tet.Gram_matrix[i][j])
                matrix.append(row)
            result.append(matrix)
            tet = tet.next

        return result

    def volume(self):
        cdef Boolean ok

        return my_volume(self.c_triangulation, &ok)
