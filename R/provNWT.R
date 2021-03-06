provNWT <- function(ml, runName, dataDir, canProvs, asStudyArea = FALSE) {
  dataDirNWT <- file.path(dataDir, "NWT") %>% checkPath(create = TRUE)

  nwt <- canProvs[canProvs$NAME_1 %in% c("Northwest Territories"), ]

  id <- which(ml[["Provincial Boundaries"]][["NAME_1"]] == "Northwest Territories")
  NWT <- ml[["Provincial Boundaries"]][id, ]
  shapefile(NWT, filename = file.path(dataDirNWT, "NWT_full.shp"), overwrite = TRUE)

  ## reportingPolygons
  NWT[["Name"]] <- NWT[["NAME_1"]]
  NWT.caribou <- postProcess(ml[["LandWeb Caribou Ranges"]],
                             studyArea = NWT, useSAcrs = TRUE,
                             filename2 = file.path(dataDirNWT, "NWT_caribou.shp"),
                             overwrite = TRUE) %>%
    joinReportingPolygons(., NWT)

  ml <- mapAdd(NWT, ml, layerName = "NWT", useSAcrs = TRUE, poly = TRUE,
               analysisGroupReportingPolygon = "NWT", isStudyArea = isTRUE(asStudyArea),
               columnNameForLabels = "Name", filename2 = NULL)
  ml <- mapAdd(NWT.caribou, ml, layerName = "NWT Caribou", useSAcrs = TRUE, poly = TRUE,
               analysisGroupReportingPolygon = "NWT Caribou",
               columnNameForLabels = "Name", filename2 = NULL)

  ## studyArea shouldn't use analysisGroup because it's not a reportingPolygon
  NWT_sr <- postProcess(ml[["LandWeb Study Area"]],
                        studyArea = amc::outerBuffer(NWT, 50000), # 50 km buffer
                        useSAcrs = TRUE,
                        filename2 = file.path(dataDirNWT, "NWT_SR.shp"),
                        overwrite = TRUE)

  plotFMA(NWT, provs = nwt, caribou = NWT.caribou, xsr = NWT_sr,
          title = "Northwest Territories",
          png = file.path(dataDirNWT, "NWT.png"))
  #plotFMA(NWT, provs = nwt, caribou = NWT.caribou, xsr = NWT_sr,
  #        title = "Northwest Territories", png = NULL)

  if (isTRUE(asStudyArea)) {
    ml <- mapAdd(NWT_sr, ml, isStudyArea = TRUE, layerName = "NWT SR",
                 useSAcrs = TRUE, poly = TRUE, studyArea = NULL, # don't crop/mask to studyArea(ml, 2)
                 columnNameForLabels = "NSN", filename2 = NULL)
  }

  return(ml)
}
