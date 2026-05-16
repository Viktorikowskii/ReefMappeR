# set_roi maintains stable output over time (snapshot test)

    Code
      result
    Output
      $bathymetry
      class       : SpatRaster 
      size        : 144, 168, 1  (nrow, ncol, nlyr)
      resolution  : 0.004166667, 0.004166667  (x, y)
      extent      : 145.4, 146.1, -17.2, -16.6  (xmin, xmax, ymin, ymax)
      coord. ref. : +proj=longlat +ellps=WGS84 +no_defs 
      source(s)   : memory
      varname     : elevation (Elevation relative to sea level) 
      name        : elevation 
      min value   :       -55 
      max value   :      1240 
      unit        :         m 
      
      $seagrass
      Simple feature collection with 51 features and 15 fields
      Geometry type: POLYGON
      Dimension:     XY
      Bounding box:  xmin: 145.7628 ymin: -16.98682 xmax: 145.9967 ymax: -16.86776
      Geodetic CRS:  WGS 84
      First 10 features:
            datasetID                             BIO_CLASS
      5205        130     Hydrocharitaceae halophila ovalis
      5206        130     Hydrocharitaceae halophila ovalis
      5207        130     Hydrocharitaceae halophila ovalis
      5208        130     Hydrocharitaceae halophila ovalis
      5209        130     Hydrocharitaceae halophila ovalis
      5210        130     Hydrocharitaceae halophila ovalis
      5212        130     Hydrocharitaceae halophila ovalis
      5213        130     Hydrocharitaceae halophila ovalis
      11091       131 Hydrocharitaceae halophila tricostata
      11380       130     Cymodoceaceae Cymodocea serrulata
                                                                                         fieldNotes
      5205                        Continuous zostera with c. serrulata/h. ovalis/h. uninervis (mud)
      5206                                     Continuous zostera with h. ovalis/h. pinilofia (mud)
      5207  Narrow band of zostera/h. uninervis (narrow) with h. decipiens/h. ovalis (narrow) (mud)
      5208  Narrow band of zostera/h. uninervis (narrow) with h. decipiens/h. ovalis (narrow) (mud)
      5209  Narrow band of zostera/h. uninervis (narrow) with h. decipiens/h. ovalis (narrow) (mud)
      5210  Narrow band of zostera/h. uninervis (narrow) with h. decipiens/h. ovalis (narrow) (mud)
      5212                        Continuous zostera with c. serrulata/h. ovalis/h. uninervis (mud)
      5213                                                  Continuous h. ovalis/h. pinifolia (mud)
      11091                                                       H. tricostata/h. decipiens (sand)
      11380                       Continuous zostera with c. serrulata/h. ovalis/h. uninervis (mud)
             habitat   AREA_SQKM         vernacular           FAMILY     GENUS
      5205  Seagrass 2.082844016 Oval leaf seagrass Hydrocharitaceae Halophila
      5206  Seagrass 0.106112690 Oval leaf seagrass Hydrocharitaceae Halophila
      5207  Seagrass 0.017626281 Oval leaf seagrass Hydrocharitaceae Halophila
      5208  Seagrass 0.010244031 Oval leaf seagrass Hydrocharitaceae Halophila
      5209  Seagrass 0.044507680 Oval leaf seagrass Hydrocharitaceae Halophila
      5210  Seagrass 0.009940853 Oval leaf seagrass Hydrocharitaceae Halophila
      5212  Seagrass 1.397256688 Oval leaf seagrass Hydrocharitaceae Halophila
      5213  Seagrass 0.252655972 Oval leaf seagrass Hydrocharitaceae Halophila
      11091 Seagrass 0.102539953       Not reported Hydrocharitaceae Halophila
      11380 Seagrass 2.082844016       Not reported    Cymodoceaceae Cymodocea
                      scientific    habitatID
      5205      Halophila ovalis Not reported
      5206      Halophila ovalis Not reported
      5207      Halophila ovalis Not reported
      5208      Halophila ovalis Not reported
      5209      Halophila ovalis Not reported
      5210      Halophila ovalis Not reported
      5212      Halophila ovalis Not reported
      5213      Halophila ovalis Not reported
      11091 Halophila tricostata Not reported
      11380  Cymodocea serrulata Not reported
                                           nameAccord       eventDate        verif
      5205  urn:lsid:marinespecies.org:taxname:208930      1984-11-01 Not reported
      5206  urn:lsid:marinespecies.org:taxname:208930      1984-11-01 Not reported
      5207  urn:lsid:marinespecies.org:taxname:208930      1984-11-01 Not reported
      5208  urn:lsid:marinespecies.org:taxname:208930      1984-11-01 Not reported
      5209  urn:lsid:marinespecies.org:taxname:208930      1984-11-01 Not reported
      5210  urn:lsid:marinespecies.org:taxname:208930      1984-11-01 Not reported
      5212  urn:lsid:marinespecies.org:taxname:208930      1984-11-01 Not reported
      5213  urn:lsid:marinespecies.org:taxname:208930      1984-11-01 Not reported
      11091 urn:lsid:marinespecies.org:taxname:374726 1987-10/1987-11 Not reported
      11380 urn:lsid:marinespecies.org:taxname:208919      1984-11-01 Not reported
            Shape_Leng  Shape_Area                       geometry
      5205  10739.5256 2094508.321 POLYGON ((145.7754 -16.9092...
      5206   2179.6296  106706.927 POLYGON ((145.7886 -16.9126...
      5207   1157.5781   17724.909 POLYGON ((145.7932 -16.9603...
      5208    884.7040   10301.288 POLYGON ((145.7952 -16.9681...
      5209   1719.6881   44756.530 POLYGON ((145.793 -16.97243...
      5210    576.3882    9996.415 POLYGON ((145.7831 -16.9854...
      5212   8508.4732 1405085.657 POLYGON ((145.7671 -16.8935...
      5213   3195.9918  254071.453 POLYGON ((145.7731 -16.8890...
      11091  1305.3699  103113.920 POLYGON ((145.9963 -16.9219...
      11380 10739.5256 2094508.321 POLYGON ((145.7754 -16.9092...
      
      $benthic
      class       : SpatRaster 
      size        : 6680, 7793, 1  (nrow, ncol, nlyr)
      resolution  : 8.983153e-05, 8.983153e-05  (x, y)
      extent      : 145.4, 146.1, -17.20004, -16.59997  (xmin, xmax, ymin, ymax)
      coord. ref. : lon/lat WGS 84 
      source      : spat_37aabf82c2_890_nuG041ZyJVTUGUr.tif 
      varname     : Cairns_benthic 
      name        : benthic 
      min value   :      11 
      max value   :      18 
      
      $bbox
       xmin  ymin  xmax  ymax 
      145.4 -17.2 146.1 -16.6 
      

