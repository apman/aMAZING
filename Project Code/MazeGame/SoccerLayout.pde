class SoccerLayout extends MazeLayout {
  
  SoccerLayout() {
  
    int[][][] wallEdgesH = {{{0,12}},                  // outer border (not used for border visual, but for collision         
                          {},
                          {},
                          {},
                          {},
                          {},
                          {},
                          {},
                          {},
                          {},
                          {{0,12}}};                    // outer border (not used for border visual, but for collision  
    int[][][] wallEdgesV = {{{0,10}},                   // outer border (not used for border visual, but for collision             
                          {{0,3}, {4,5}, {6,10}}, 
                          {},
                          {},
                          {},
                          {},
                          {},
                          {},
                          {},
                          {},
                          {},
                          {{0,4}, {5,6}, {7,10}},
                          {{0,10}}};                    // outer border (not used for border visual, but for collision  
                          
    this.wallEdgesH = wallEdgesH;
    this.wallEdgesV = wallEdgesV;
                          
  }

}