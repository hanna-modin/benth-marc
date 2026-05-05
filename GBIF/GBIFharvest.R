# nolint start
#install.packages("bit64")
#install.packages("pak")
#install.packages("rgbif")  # Comment this out to avoid overwriting the dev version
pak::pkg_install("ropensci/rgbif") # dev version - uncomment to install/update

#install.packages("devtools")
#devtools::install_github("ropensci/rgbif")  # Alternative: use this instead of pak if needed

 

setwd("C:\\Users\\hamod4691\\Code\\arctic-benthic-biodiversity\\GBIF")

library(rgbif)
packageVersion("rgbif")  # Should show 3.8.5.1
library(dplyr)
library(data.table)

Sys.setenv(
  GBIF_USER = "hannamodin",
  GBIF_PWD = "Eternalsunshi85",
  GBIF_EMAIL = "hanna.m.modin@uit.no"
)

# Define the list of benthic phyla
taxon_keys <- c(42, 52, 54, 50, 43, 105, 74, 53, 44, 110, 5967481, 63, 14, 108, 75, 5959089, 5963150, 5967457, 19, 8173593)

west_wkt <- "POLYGON ((0 61.994641, 0 90, -2 90, -4 90, -6 90, -8 90, -10 90, -12 90, -14 90, -16 90, -18 90, -20 90, -22 90, -24 90, -26 90, -28 90,
-30 90, -32 90, -34 90, -36 90, -38 90, -40 90, -42 90, -44 90, -46 90, -48 90, -50 90, -52 90, -54 90, -56 90, -58 90, -60 90, -62 90, -64 90, -66 90,
-68 90, -70 90, -72 90, -74 90, -76 90, -78 90, -80 90, -82 90, -84 90, -86 90, -88 90, -90 90, -92 90, -94 90, -96 90, -98 90, -100 90, -102 90,
-104 90, -106 90, -108 90, -110 90, -112 90, -114 90, -116 90, -118 90, -120 90, -122 90, -124 90, -126 90, -128 90, -130 90, -132 90, -134 90, -136 90,
-138 90, -140 90, -142 90, -144 90, -146 90, -148 90, -150 90, -152 90, -154 90, -156 90, -158 90, -160 90, -162 90, -164 90, -166 90, -168 90, -170 90,
-172 90, -174 90, -176 90, -178 90, -180 90, -180 88, -180 86, -180 84, -180 82, -180 80, -180 78, -180 76, -180 75.982481, -180 74, -180 72, -180 70,
-180 68, -180 66, -180 64, -180 62, -180 61.512214, -180 60, -180 58, -180 56, -180 54, -180 52.347289, -180 52, -180 50.67979, -179.96105 50.674588,
-169.952014 51.802685, -168.838924 52.087643, -168.029445 52.268591, -164.959166 53.1774, -164.898843 54.593373, -163.568016 54.829976, -163.24978 54.935708,
-163.143642 55.150609, -162.770067 55.12774, -162.600778 55.307255, -162.1794 55.296739, -161.678102 55.788453, -160.921312 55.658582, -160.148974 55.756746,
-159.407112 56.240077, -157.202273 57.276168, -155.888522 58.964131, -157.474944 59.770135, -161.68552 61.272819, -165.400542 61.557595, -164.977644 61.683236,
-164.638645 61.781014, -164.287733 61.882576, -163.913226 61.991054, -163.492447 62.113382, -163.081751 62.232798, -162.738815 62.332847, -162.395042 62.433219,
-162.004633 62.547541, -161.543909 62.682558, -161.185821 62.787616, -160.861743 62.882928, -160.502054 62.988788, -160.153129 63.091613, -159.791692 63.198256,
-159.080496 67.026126, -159.376786 67.266077, -159.65091 67.47865, -159.908614 67.670624, -160.201454 67.880379, -160.476276 68.06975, -160.759715 68.257766,
-161.002267 68.413456, -161.220959 68.549608, -161.495748 68.715676, -161.688437 68.853733, -161.491138 68.994087, -161.179869 69.151354, -160.898207 69.290348,
-160.593558 69.437141, -160.228164 69.608702, -159.930253 69.745024, -159.550649 69.914212, -159.084642 70.115485, -158.667203 70.28995, -158.240542 70.462827,
-157.846514 70.617855, -157.423254 70.779541, -157.034965 70.923769, -156.730786 71.068211, -156.352375 70.253136, -152.369081 69.875417, -134.69721 67.925924,
-120.101744 67.863385, -108.175521 65.962914, -95.039794 66.423809, -93.03769 67.64804, -92.534247 69.231898, -91.395099 68.008415, -88.380083 66.870769,
-91.473991 66.573067, -95.641992 64.056734, -96.800298 60.70246, -95.730458 57.493299, -93.327994 55.690458, -89.446864 55.006042, -83.836114 54.30698,
-82.851963 51.813568, -81.200646 49.999249, -79.197428 49.939233, -76.973455 51.822458, -77.359952 54.366693, -74.77362 56.732856, -75.284243 59.224872,
-75.072234 60.610768, -73.553609 61.045604, -71.550018 59.921136, -70.854167 57.9677, -69.547398 56.984598, -67.228199 57.301603, -64.90562 58.190482,
-62.021602 54.284094, -60.221983 52.702486, -58.213377 52.792035, -56.7054 52.014577, -56.485763 50.963429, -56.73811 50.586289, -57.163053 49.998122,
-56.86223 49.992144, -56.553984 49.989113, -56.137873 49.985735, -55.814247 49.983556, -55.547132 49.982201, -55.228656 49.981075, -54.889638 49.980326,
-54.612261 49.980119, -54.211606 49.980633, -53.831492 49.981602, -53.53356 49.982892, -53.173978 49.985136, -52.783558 49.988097, -52.454768 49.991209,
-52.023208 49.996169, -51.632714 50.001234, -51.344961 50.005467, -51.067469 50.009976, -50.738564 50.015784, -50.409626 50.022066, -50.111498 50.02821,
-49.844187 50.034068, -49.504876 50.042099, -49.134662 50.051319, -49.080201 50.821326, -52.418312 54.754985, -58.276474 57.062763, -60.094424 59.997135,
-59.209242 62.976142, -55.451575 63.014324, -46.926847 59.035062, -46.477605 59.024007, -46.123921 59.016964, -45.6842 59.009963, -45.22536 59.004663,
-44.747393 59.001504, -44.335037 59.000441, -42.003248 59.003398, -40.003339 61.980587, -32.140874 64.99706, -30.076513 64.776802, -28.311778 64.553528,
-24.718372 63.106064, -18.565419 62.917752, -13.599474 63.887805, -10.442916 62.02619, -12.782258 60.006604, -12.238717 59.99869, -11.845003 59.99698,
-11.451289 59.995728, -11.057573 59.994935, -10.590034 59.994659, -10.122495 59.994889, -9.728779 59.995643, -9.335064 59.996856, -8.941351 59.998527,
-8.54764 60.000657, -8.153931 60.003245, -7.760226 60.006292, -7.366525 60.009797, -3.75564 62.006725, -3.110429 62.003576, -2.460795 62.000845,
-1.81116 61.998566, -1.161523 61.99674, -0.511885 61.995367, 0 61.994641))"

east_wkt <- "POLYGON ((0 61.994641, 0.137754 61.994446, 0.787393 61.993977, 1.315226 61.993826, 1.843057 61.99418, 2.492697 61.994899, 3.142335 61.996071,
3.791972 61.997694, 4.441609 61.999771, 5.091243 62.0023, 5.731005 62.005209, 7.405854 62.081979, 8.273698 62.200394, 11.057224 63.169396, 12.112365 63.754348,
13.506069 65.507623, 15.246571 66.519988, 14.648717 67.118063, 15.551459 67.048202, 16.55603 67.167799, 18.175375 67.649737, 20.536666 68.753852,
25.288968 69.074687, 28.660871 68.936223, 31.054727 67.007113, 32.316293 65.758155, 34.770418 64.028925, 37.568076 63.213859, 39.681152 63.727947,
42.580482 65.018233, 47.472999 66.542494, 48.698876 67.098502, 51.609338 68.148663, 55.322244 67.906166, 58.833481 67.885074, 60.41716 68.134069,
61.890697 68.81782, 61.01232 69.580582, 69.775921 65.744677, 73.13084 65.646135, 78.839157 67.232023, 84.944616 69.470737, 84.184315 72.740616,
88.185841 73.531249, 90.147705 74.583191, 96.849124 75.483119, 101.702217 76.079777, 106.626389 76.081725, 110.116876 76.100797, 111.12325 75.598432,
103.510197 72.39661, 104.398459 72.119954, 109.678983 72.84639, 119.515071 72.419953, 125.822842 72.553281, 126.988556 71.180798, 131.022777 70.229729,
133.325039 70.745943, 138.688407 70.904763, 142.034138 71.839735, 145.326817 71.395, 147.808947 71.968781, 147.700587 71.493552, 150.758596 70.171393,
155.719068 70.151475, 158.323452 69.20735, 162.819486 68.802602, 169.792552 68.380908, 173.529123 68.958453, 174.863202 69.586359, 174.873564 69.397824,
174.867726 69.240087, 174.861868 69.082347, 174.854791 68.893055, 174.846504 68.67221, 174.838158 68.45136, 174.829775 68.230505, 174.821337 68.009644,
174.736931 67.736862, 174.565234 67.486779, 174.410405 67.264079, 174.291955 67.095602, 174.157995 66.907167, 174.027981 66.725675, 173.906456 66.557868,
173.784232 66.390248, 173.665944 66.22955, 173.552004 66.075714, 173.432192 65.915408, 173.291631 65.728618, 173.129619 65.515505, 172.961482 65.296082,
172.853839 65.156648, 172.762647 65.024664, 172.998173 64.897215, 173.447693 64.779395, 173.871985 64.664861, 174.231825 64.565034, 174.647203 64.446706,
175.077223 64.320622, 175.521138 64.186509, 175.902491 64.068039, 176.335546 63.929614, 176.781378 63.782864, 177.128052 63.670087, 177.431157 63.568482,
177.731312 63.456803, 177.992977 63.350076, 178.246933 63.235932, 178.509264 63.106894, 178.782144 62.957059, 179.011509 62.779359, 177.012759 63.050907,
174.167599 62.513234, 170.781957 61.301201, 165.189673 60.947967, 162.795927 60.074878, 161.013955 58.719416, 161.192747 57.689218, 161.479761 57.160793,
160.608904 56.057755, 158.715741 54.170332, 157.577673 52.528928, 156.905193 51.213675, 159.020524 50.258921, 163.985956 54.92459, 171.394709 52.161094,
172.420861 51.692091, 180 50.67979, 180 52, 180 52.347289, 180 54, 180 56, 180 58, 180 60, 180 61.512214, 180 62, 180 64, 180 66, 180 68, 180 70, 180 72,
180 74, 180 75.982481, 180 76, 180 78, 180 80, 180 82, 180 84, 180 86, 180 88, 180 90, 178 90, 176 90, 174 90, 172 90, 170 90, 168 90, 166 90, 164 90,
162 90, 160 90, 158 90, 156 90, 154 90, 152 90, 150 90, 148 90, 146 90, 144 90, 142 90, 140 90, 138 90, 136 90, 134 90, 132 90, 130 90, 128 90, 126 90,
124 90, 122 90, 120 90, 118 90, 116 90, 114 90, 112 90, 110 90, 108 90, 106 90, 104 90, 102 90, 100 90, 98 90, 96 90, 94 90, 92 90, 90 90, 88 90, 86 90,
84 90, 82 90, 80 90, 78 90, 76 90, 74 90, 72 90, 70 90, 68 90, 66 90, 64 90, 62 90, 60 90, 58 90, 56 90, 54 90, 52 90, 50 90, 48 90, 46 90, 44 90, 42 90,
40 90, 38 90, 36 90, 34 90, 32 90, 30 90, 28 90, 26 90, 24 90, 22 90, 20 90, 18 90, 16 90, 14 90, 12 90, 10 90, 8 90, 6 90, 4 90, 2 90, 0 90, 0 61.994641))"

# Download one wkt at a time

gbif_west <- occ_download(
  pred_within(west_wkt),
  pred_in("taxonKey", taxon_keys), # Use pred_in for multiple taxon keys
  pred("hasCoordinate", TRUE), # Filter for records with coordinates
  format = "DWCA",
  verbatim_extensions = "http://rs.tdwg.org/dwc/terms/MeasurementOrFact"
    )

occ_download_wait(gbif_west)
# Check the status of the west download
occ_download_meta(gbif_west)

# Download the zipped folder using the download link provided by meta. Unzip folder, name west_data and put in working directory.

gbif_east <- occ_download(
  pred_within(east_wkt),
  pred_in("taxonKey", taxon_keys), # Use pred_in for multiple taxon keys
  pred("hasCoordinate", TRUE), # Filter for records with coordinates
  format = "DWCA",
  verbatim_extensions = "http://rs.tdwg.org/dwc/terms/MeasurementOrFact"
    )

occ_download_wait(gbif_east)
# Check the status of the east download
occ_download_meta(gbif_east)

# Download the zipped folder using the download link provided by meta. Unzip folder, name east_data and put in working directory

# ------------------- PREPARE FILTERS ------------------------------------

exclude_classes <- c(
  212, 359, 131, 367, 360, 10713444, 361, 216, 253, 11592253, 11374670, 7742773, 11210652, 11186032, 9273948, 144, 7188530, 11733052,
  176, 121, 140, 120, 7774442, 224, 254, 11881065, 352, 11418114, 207, 119, 11500725, 11377931, 11569602, 281, 7375758, 139, 355,
  11146120, 11699831, 345
)

exclude_orders <- c(
  1313, 549, 590, 587, 588, 883, 9697017, 1441, 1456, 1068, 1005, 1306, 550, 837, 495, 473, 774, 538, 548, 1153, 497, 544, 1305, 12261528,
  1307, 1077, 8403901, 499, 9341894, 773, 890, 888, 1103, 1166, 498, 659, 1312, 1308, 772, 9311931, 1311, 1067, 494, 782, 1310, 537, 12216105,
  1107, 1106, 9463058, 708, 1163, 1069, 11205145, 901, 11125512, 1165, 547, 1167, 12233564, 496, 11131731, 12182793, 771, 11164857, 679,
  687, 9445058, 693, 694, 695, 1417, 11443919, 1428, 9697017, 868, 6902, 8391193, 9301143, 1435, 709, 711, 901
)

exclude_families <- c(
  7990, 4453, 7996, 4455, 8008, 4428, 4449, 8001, 2073, 6103, 4901, 4902, 4303274, 4960, 9044, 5048, 9052, 6207, 4461, 9054, 9055, 3589,
  6498, 3254532, 4479, 4424, 7385843, 5978, 4437, 3977, 2852, 6488, 2851, 8899, 8674, 3247675, 5765
)

exclude_genera <- c(
  2312692, 2316452, 2312497, 2316610, 2114424, 2115369, 2269480, 2115030, 6180409, 2406056, 10816205, 2269549, 2115338, 2114220,
  2114718, 2115124, 2115195, 7927564, 2269491, 5431531, 2234785, 7544733, 2506123, 2114333, 2307067, 2228004, 2332495, 2115284, 2269508,
  2114265, 2114807, 2114924, 2111272, 2332548, 2115460, 2114350, 2114914, 2115157, 2306892, 2114649, 2114705, 2114882, 2114837, 2227984, 
  4322151, 2115436, 2281428, 2283858, 2286678, 4407666, 9045267, 2112523, 2253224, 9204348, 2308045, 2253243, 2253037, 2308260, 2282714, 
  1007034, 8286089, 2111133, 2307934, 4807701, 2253212, 4592617, 11719099, 4807401, 2308538, 2112597, 4807841, 2283075, 2252982, 4573288, 
  4857051, 2308495, 2308196, 2308413, 7867945, 2308058, 2252942, 2308178, 2308564, 9571446, 8276709, 2284722
)

exclude_species <- c(
  2114445, 2114439, 2115377, 2115373, 2115371, 2115375, 2269484, 4282555, 2115037, 2115035, 6180410, 2406057, 5233140, 4987686,
  4987684, 2234694, 2269550, 2269551, 2266609, 2115346, 2115344, 5166399, 5166402, 5166405, 2114723, 2115141, 2115138, 2115131, 2115142,
  2115128, 2115197, 2115202, 2115200, 5193700, 1028577, 1028479, 1028572, 1028559, 2269492, 2269495, 2264841, 2264478, 5717325, 2264800,
  4334397, 1028478, 5166387, 2115074, 5166468, 4333480, 2307068, 2307078, 2114329, 2332511, 2332507, 2115300, 2115324, 2115303, 2115325,
  2115305, 5185508, 2115009, 2115018, 5166441, 5166453, 2269510, 4331035, 2222553, 2222554, 5177646, 5177649, 2115262, 5717403, 5718524,
  5165879, 2114278, 2114282, 2114270, 2114284, 8217523, 2227978, 5233166, 2114824, 11082687, 2114817, 2114926, 2114925, 2111274, 2114872,
  4334013, 2114874, 2114873, 7661024, 2264798, 2114956, 2332555, 2332553, 2332557, 4356840, 5166645, 5166639, 2307435, 5165790, 5165820,
  5165822, 5165823, 5165827, 5165810, 5165819, 5165809, 5165793, 5165784, 2115466, 11602113, 2114417, 2114406, 2114351, 2114401, 2265711,
  2115523, 2316453, 5185412, 4334981, 2312501, 2265692, 1028563, 2114923, 2114921, 2114916, 2114917, 2115159, 2307011, 4339887, 2265599,
  5193904, 5193937, 4334696, 2114661, 2114668, 2114663, 4334690, 2217381, 2114711, 8166174, 2269500, 2269434, 2114890, 2114884, 2114900,
  2114894, 2114895, 2114902, 2114886, 2114903, 2114897, 5166379, 2114838, 5177644, 5177643, 5177641, 2227991, 2227990, 2227985, 2312723,
  4322171, 4322180, 9483153, 2316612, 2115437, 4335010, 6467075, 4335044, 6467074, 2216393, 2219836, 2219631, 2219636, 7441628, 5193615,
  10698600, 1003652, 9485325, 2308346, 9265812, 11343379, 1030143, 8189162, 10403436, 1029478, 1029703, 6470965, 1029714, 6470945, 1029751, 
  6470964, 10804367, 7021017, 2219853, 2307956, 2307957, 9683534, 9038558, 8420492, 1029801, 2293089, 2287024, 7654206, 9171033, 9611334, 
  9024144, 4409846, 4409839, 8841146, 4409844, 9118285, 8931520, 4857221, 5863379, 2308095, 8597431, 10881058, 7441628, 1029523, 10839317, 
  12242974, 1010040, 9633156, 9479629, 2206247
)

# -------------------- WEST DATA FILTERS AND SAVE -------------------------

# Read the data using fread with the correct encoding
data_west <- fread("C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/west_data/occurrence.txt", quote = "", encoding = "Latin-1") # ISO-8859-1 is equivalent to Latin-1

# Apply filtering steps
filtered_data_west <- data_west[
  occurrenceStatus == "PRESENT" &
    (!basisOfRecord %in% c("FOSSIL_SPECIMEN") | is.na(basisOfRecord)) &
    (!preparations %in% c("FOSSIL") | is.na(preparations)) &
    (coordinatePrecision < 0.01 | is.na(coordinatePrecision)) &
    (coordinateUncertaintyInMeters < 10000 | is.na(coordinateUncertaintyInMeters)) &
    (!coordinateUncertaintyInMeters %in% c(301, 3036, 999, 9999) | is.na(coordinateUncertaintyInMeters)) &
    (!(classKey %in% exclude_classes) | is.na(classKey)) &
    (!(orderKey %in% exclude_orders) | is.na(orderKey)) &
    (!(familyKey %in% exclude_families) | is.na(familyKey)) &
    (!(genusKey %in% exclude_genera) | is.na(genusKey)) &
    (!(speciesKey %in% exclude_species) | is.na(speciesKey))
]
# Save the filtered data with UTF-8 encoding
fwrite(filtered_data_west, "C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/filtered_data_west.txt", sep = "\t", bom = TRUE)

# -------------------- EAST DATA FILTERS AND SAVE -------------------------

# Define the file paths
input_file <- "C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/east_data/occurrence.txt"
output_file <- "C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/filtered_data_east.txt"
# Remove the output file if it exists to avoid appending to old data
if (file.exists(output_file)) {
  file.remove(output_file)
}
# Define chunk size
chunk_size <- 1e6 # 1 million rows per chunk
# Read the header (column names) separately with the correct encoding
header <- fread(input_file, nrows = 0, encoding = "Latin-1") # ISO-8859-1 is equivalent to Latin-1
column_names <- names(header) # Store column names
# Initialize variables
skip <- 0 # Number of rows to skip
chunk_number <- 1
append <- FALSE # Append mode for fwrite
# Loop through the file in chunks
repeat {
  # Read a chunk of data with the correct encoding
  chunk <- fread(input_file, nrows = chunk_size, skip = skip, header = FALSE, quote = "", encoding = "Latin-1")

  # Break the loop if the chunk is empty (end of file)
  if (nrow(chunk) == 0) break

  # Assign column names to the chunk
  setnames(chunk, column_names)

  # Apply filtering steps
  filtered_chunk <- chunk[
    occurrenceStatus == "PRESENT" &
      (!basisOfRecord %in% c("FOSSIL_SPECIMEN") | is.na(basisOfRecord)) &
      (!preparations %in% c("FOSSIL") | is.na(preparations)) &
      (coordinatePrecision < 0.01 | is.na(coordinatePrecision)) &
      (coordinateUncertaintyInMeters < 10000 | is.na(coordinateUncertaintyInMeters)) &
      (!coordinateUncertaintyInMeters %in% c(301, 3036, 999, 9999) | is.na(coordinateUncertaintyInMeters)) &
      (!(classKey %in% exclude_classes) | is.na(classKey)) &
      (!(orderKey %in% exclude_orders) | is.na(orderKey)) &
      (!(familyKey %in% exclude_families) | is.na(familyKey)) &
      (!(genusKey %in% exclude_genera) | is.na(genusKey)) &
      (!(speciesKey %in% exclude_species) | is.na(speciesKey))
  ]

  # Write the filtered chunk to the output file with the correct encoding
  fwrite(filtered_chunk, output_file, sep = "\t", append = append, bom = TRUE)

  # Update variables for the next iteration
  skip <- skip + chunk_size
  append <- TRUE # Append mode for subsequent chunks
  chunk_number <- chunk_number + 1

  # Print progress
  cat("Processed chunk", chunk_number, "\n")
}
}
cat("Processing complete. Filtered data saved to", output_file, "\n")

#//////////////////////////// MERGE FILTERED GBIF DATA INTO PARQUET ////////////////////////////

# Install/load arrow package for parquet
if (!requireNamespace("arrow", quietly = TRUE)) {
  install.packages("arrow")
}
library(arrow)

# Read both filtered data files
cat("Merging filtered GBIF data into parquet...\n")
merged_gbif <- rbind(
  fread("C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/filtered_data_east.txt", encoding = "Latin-1"),
  fread("C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/filtered_data_west.txt", encoding = "Latin-1")
)

cat("Total rows after merging:", nrow(merged_gbif), "\n")

# Save as parquet file
merged_parquet_path <- "C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/merged_GBIF.parquet"
write_parquet(merged_gbif, merged_parquet_path)
cat("Saved merged GBIF data to:", merged_parquet_path, "\n")

#//////////////////////////// EXTRACT DATASET INFORMATION FOR EAST ////////////////////////////

# Install/load required packages
if (!requireNamespace("xml2", quietly = TRUE)) {
  install.packages("xml2")
}
if (!requireNamespace("writexl", quietly = TRUE)) {
  install.packages("writexl")
}

library(xml2)
library(writexl)
library(dplyr)

# Define the directory containing XML files
xml_dir <- "C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/east_data/dataset"

# Get list of all XML files
xml_files <- list.files(xml_dir, pattern = "\\.xml$", full.names = TRUE)

cat("Found", length(xml_files), "XML files to process\n")

# Initialize an empty list to store extracted data
datasets_list <- list()

# Function to safely extract text from XML nodes
extract_text <- function(node, xpath, ns = NULL) {
  result <- tryCatch({
    nodes <- xml_find_all(node, xpath, ns = ns)
    if (length(nodes) == 0) {
      return(NA_character_)
    }
    text_values <- xml_text(nodes)
    # Return as comma-separated if multiple values
    paste(text_values, collapse = "; ")
  }, error = function(e) {
    return(NA_character_)
  })
  return(result)
}

# Function to extract UUID-format alternateIdentifier
extract_uuid_identifier <- function(node, ns = NULL) {
  tryCatch({
    alt_ids <- xml_find_all(node, ".//d1:alternateIdentifier", ns = ns)
    if (length(alt_ids) == 0) {
      # Try without namespace
      alt_ids <- xml_find_all(node, ".//alternateIdentifier")
    }
    
    for (alt_id in alt_ids) {
      text <- xml_text(alt_id)
      # Check if matches UUID pattern
      if (grepl("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", text, ignore.case = TRUE)) {
        return(text)
      }
    }
    return(NA_character_)
  }, error = function(e) {
    return(NA_character_)
  })
}

# Loop through each XML file and extract data
for (i in seq_along(xml_files)) {
  tryCatch({
    cat("Processing file", i, "of", length(xml_files), "\r")
    
    # Read XML file
    xml_doc <- read_xml(xml_files[i])
    
    # Define namespace
    ns <- c(d1 = "https://eml.ecoinformatics.org/eml-2.2.0",
            xsi = "http://www.w3.org/2001/XMLSchema-instance")
    
    # Extract title
    title <- extract_text(xml_doc, ".//d1:title", ns = ns)
    if (is.na(title)) {
      title <- extract_text(xml_doc, ".//title")
    }
    
    # Extract abstract
    abstract <- extract_text(xml_doc, ".//d1:abstract/d1:para", ns = ns)
    if (is.na(abstract)) {
      abstract <- extract_text(xml_doc, ".//abstract/para")
    }
    
    # Extract intellectualRights
    intellectual_rights <- extract_text(xml_doc, ".//d1:intellectualRights/d1:para", ns = ns)
    if (is.na(intellectual_rights)) {
      intellectual_rights <- extract_text(xml_doc, ".//intellectualRights/para")
    }
    
    # Extract URL (get first online URL)
    url <- extract_text(xml_doc, ".//d1:distribution/d1:online/d1:url[1]", ns = ns)
    if (is.na(url)) {
      url <- extract_text(xml_doc, ".//distribution/online/url[1]")
    }
    
    # Extract citation (if exists)
    citation <- extract_text(xml_doc, ".//d1:citation", ns = ns)
    if (is.na(citation)) {
      citation <- extract_text(xml_doc, ".//citation")
    }
    
    # Extract alternateIdentifier (UUID format)
    alternate_id <- extract_uuid_identifier(xml_doc, ns = ns)
    
    # Extract pubDate
    pub_date <- extract_text(xml_doc, ".//d1:pubDate", ns = ns)
    if (is.na(pub_date)) {
      pub_date <- extract_text(xml_doc, ".//pubDate")
    }
    
    # Extract licenseName
    license_name <- extract_text(xml_doc, ".//d1:licensed/d1:licenseName", ns = ns)
    if (is.na(license_name)) {
      license_name <- extract_text(xml_doc, ".//licensed/licenseName")
    }
    
    # Add to list
    datasets_list[[i]] <- data.frame(
      title = title,
      abstract = abstract,
      intellectualRights = intellectual_rights,
      url = url,
      citation = citation,
      alternateIdentifier = alternate_id,
      pubDate = pub_date,
      licenseName = license_name,
      stringsAsFactors = FALSE
    )
    
  }, error = function(e) {
    cat("Error processing file:", xml_files[i], "Error:", conditionMessage(e), "\n")
  })
}

cat("\n")

# Combine all data into a single data frame
if (length(datasets_list) > 0) {
  datasets_df <- bind_rows(datasets_list)
  
  # Remove rows where all fields are NA
  datasets_df <- datasets_df %>%
    filter(!if_all(everything(), is.na))
  
  # Save to Parquet file (no Excel cell character limit issues)
  output_path <- "C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/east_data_metadata.parquet"
  arrow::write_parquet(datasets_df, output_path)
  
  cat("Extracted metadata from", nrow(datasets_df), "datasets\n")
  cat("Saved to:", output_path, "\n")
} else {
  cat("No data extracted from XML files\n")
}


#//////////////////////////// EXTRACT DATASET INFORMATION FOR WEST ////////////////////////////

# Define the directory containing XML files
xml_dir_west <- "C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/west_data/dataset"

# Get list of all XML files
xml_files_west <- list.files(xml_dir_west, pattern = "\\.xml$", full.names = TRUE)

cat("Found", length(xml_files_west), "XML files to process in west_data\n")

# Initialize an empty list to store extracted data
datasets_list_west <- list()

# Loop through each XML file and extract data
for (i in seq_along(xml_files_west)) {
  tryCatch({
    cat("Processing file", i, "of", length(xml_files_west), "\r")
    
    # Read XML file
    xml_doc <- read_xml(xml_files_west[i])
    
    # Define namespace
    ns <- c(d1 = "https://eml.ecoinformatics.org/eml-2.2.0",
            xsi = "http://www.w3.org/2001/XMLSchema-instance")
    
    # Extract title
    title <- extract_text(xml_doc, ".//d1:title", ns = ns)
    if (is.na(title)) {
      title <- extract_text(xml_doc, ".//title")
    }
    
    # Extract abstract
    abstract <- extract_text(xml_doc, ".//d1:abstract/d1:para", ns = ns)
    if (is.na(abstract)) {
      abstract <- extract_text(xml_doc, ".//abstract/para")
    }
    
    # Extract intellectualRights
    intellectual_rights <- extract_text(xml_doc, ".//d1:intellectualRights/d1:para", ns = ns)
    if (is.na(intellectual_rights)) {
      intellectual_rights <- extract_text(xml_doc, ".//intellectualRights/para")
    }
    
    # Extract URL (get first online URL)
    url <- extract_text(xml_doc, ".//d1:distribution/d1:online/d1:url[1]", ns = ns)
    if (is.na(url)) {
      url <- extract_text(xml_doc, ".//distribution/online/url[1]")
    }
    
    # Extract citation (if exists)
    citation <- extract_text(xml_doc, ".//d1:citation", ns = ns)
    if (is.na(citation)) {
      citation <- extract_text(xml_doc, ".//citation")
    }
    
    # Extract alternateIdentifier (UUID format)
    alternate_id <- extract_uuid_identifier(xml_doc, ns = ns)
    
    # Extract pubDate
    pub_date <- extract_text(xml_doc, ".//d1:pubDate", ns = ns)
    if (is.na(pub_date)) {
      pub_date <- extract_text(xml_doc, ".//pubDate")
    }
    
    # Extract licenseName
    license_name <- extract_text(xml_doc, ".//d1:licensed/d1:licenseName", ns = ns)
    if (is.na(license_name)) {
      license_name <- extract_text(xml_doc, ".//licensed/licenseName")
    }
    
    # Add to list
    datasets_list_west[[i]] <- data.frame(
      title = title,
      abstract = abstract,
      intellectualRights = intellectual_rights,
      url = url,
      citation = citation,
      alternateIdentifier = alternate_id,
      pubDate = pub_date,
      licenseName = license_name,
      stringsAsFactors = FALSE
    )
    
  }, error = function(e) {
    cat("Error processing file:", xml_files_west[i], "Error:", conditionMessage(e), "\n")
  })
}

cat("\n")

# Combine all data into a single data frame
if (length(datasets_list_west) > 0) {
  datasets_df_west <- bind_rows(datasets_list_west)
  
  # Remove rows where all fields are NA
  datasets_df_west <- datasets_df_west %>%
    filter(!if_all(everything(), is.na))
  
  # Save to Parquet file (no Excel cell character limit issues)
  output_path_west <- "C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/west_data_metadata.parquet"
  arrow::write_parquet(datasets_df_west, output_path_west)
  
  cat("Extracted metadata from", nrow(datasets_df_west), "datasets\n")
  cat("Saved to:", output_path_west, "\n")
} else {
  cat("No data extracted from XML files\n")
}

#//////////////////////////// FILTER METADATA BY OCCURRENCE DATA AND MERGE ////////////////////////////

# Read the merged filtered occurrence data from parquet
merged_gbif_data <- read_parquet("C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/merged_GBIF.parquet") %>%
  select(datasetKey) %>%
  distinct()

# Get unique datasetKey values
unique_datasets <- unique(merged_gbif_data$datasetKey)

cat("Found", length(unique_datasets), "unique datasets in merged occurrence data\n")

# Read the metadata Parquet files
east_metadata <- read_parquet("C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/east_data_metadata.parquet")
west_metadata <- read_parquet("C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/west_data_metadata.parquet")

cat("East metadata has", nrow(east_metadata), "entries\n")
cat("West metadata has", nrow(west_metadata), "entries\n")

# Merge the two metadata files first
merged_metadata <- bind_rows(east_metadata, west_metadata)

# Filter merged metadata to keep only entries with UUIDs that exist in the occurrence data
merged_metadata <- merged_metadata %>%
  filter(!is.na(alternateIdentifier) & alternateIdentifier %in% unique_datasets)

cat("Merged metadata filtered to", nrow(merged_metadata), "entries\n")

# Remove duplicate UUIDs (keep first occurrence)
merged_metadata <- merged_metadata %>%
  distinct(alternateIdentifier, .keep_all = TRUE)

cat("Merged metadata has", nrow(merged_metadata), "unique entries\n")

# Save the merged and filtered metadata to Parquet
output_merged <- "C:/Users/hamod4691/Code/arctic-benthic-biodiversity/GBIF/datasets_GBIF.parquet"
arrow::write_parquet(merged_metadata, output_merged)

cat("Saved merged and filtered metadata to:", output_merged, "\n")

# nolint end