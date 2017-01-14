class DefaultMaze extends MazeLayout {
  
  DefaultMaze() {
  
    int[][][] wallEdgesH = {{{0,12}},                  // outer border (not used for border visual, but for collision         
                          {{3,5},{6,7},{9,11}}, 
                          {{0,2},{5,6},{7,8}},
                          {{4,5},{7,9},{10,12}},
                          {{1,3},{4,5},{6,8},{9,10}},
                          {{2,4},{5,6},{8,9}},
                          {{1,2},{4,6},{7,8},{10,11}},
                          {{0,1},{6,7},{10, 12}},
                          {{1,2},{7,8},{10, 11}},
                          {{2,3},{4,5},{7,9},{10,11}},
                          {{0,12}}};                    // outer border (not used for border visual, but for collision  
    int[][][] wallEdgesV = {{{0,10}},                   // outer border (not used for border visual, but for collision             
                          {{0,1},{3,6},{8,9}}, 
                          {{1,3},{6,8}},
                          {{1,3},{5,9}},
                          {{2,3},{6,8},{9,10}},
                          {{1,2},{4,6},{7,9}},
                          {{0,1},{2,3},{4,5},{6,9}},
                          {{1,2},{5,6},{9,10}},
                          {{1,2},{4,5},{6,8}},
                          {{1,3},{6,8}},
                          {{3,5}},
                          {{1,2},{4,6},{8,9}},
                          {{0,10}}};                    // outer border (not used for border visual, but for collision  
                          
    this.wallEdgesH = wallEdgesH;
    this.wallEdgesV = wallEdgesV;
                          
  }

}