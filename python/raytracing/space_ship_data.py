class SpaceShipData:
    num_triangles = 1
    
    def __init__(self):
        self.supporting_planes = [ (1.0, 0.0, 0.0, 0.0) ]
        self.bounding_planes = [ (1.0, 1.0, 0.0, 0.0),
                                 (1.0, 1.0, 0.0, 0.0), (1.0, 1.0, 0.0, 0.0)
                                ]
space_ship_data = SpaceShipData()
