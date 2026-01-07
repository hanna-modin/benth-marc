# nolint start
setwd("C:\\Users\\hamod4691\\OneDrive - UiT Office 365\\Data paper code\\OBIS")
# install.packages("lubridate")

# Load required libraries
library(robis) # For downloading data from OBIS
library(arrow) # For saving and reading Parquet files
library(dplyr) # For data manipulation
library(lubridate) # For date parsing and extracting years

# Define the AphiaIDs for the phyla you want to download
aphia_ids <- c(882, 51, 1065, 1806, 1267, 558, 146142, 1821, 1803, 799, 152391, 1276, 793, 1818, 101060, 101063, 101061, 1789) # Sipuncula is not recognized as phylum according to WoRMS # nolint

# Define a WKT string for the geographic area (example: a bounding box)
US_wkt <- "POLYGON ((0 61.994641, 0 90, -2 90, -4 90, -6 90, -8 90, -10 90, -12 90, -14 90, -16 90, -18 90, -20 90, -22 90, -24 90, -26 90, -28 90,
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

eurasia_wkt <- "POLYGON ((0 61.994641, 0.137754 61.994446, 0.787393 61.993977, 1.315226 61.993826, 1.843057 61.99418, 2.492697 61.994899, 3.142335 61.996071,
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


# ---------------------- Download US ---------------------

# Download occurrences for US wkt
occurrences_US <- occurrence(
  taxonid = aphia_ids,
  geometry = US_wkt,
  mof = TRUE
)

cat("US Occurrence data downloaded:", nrow(occurrences_US), "records\n")
str(occurrences_US)

# Flatten the MoF data
mof_US <- unnest_extension(
  occurrences_US,
  "MeasurementOrFact",
  fields = c("id", "eventID")
)

# Save the mof data
write_parquet(mof_US, "mof_US.parquet")

# Remove nested mof column from occurrences to be able to save as parquet
occurrences_US_nomof <- occurrences_US %>%
  select(-mof) # Remove the 'mof' column

# Double check structure
str(occurrences_US_nomof)

# Save the occurrences data
write_parquet(occurrences_US_nomof, "occurrences_US.parquet")

# ------------------- Download Eurasia -------------------

# Download occurrences for Eurasia wkt
occurrences_eurasia <- occurrence(
  taxonid = aphia_ids,
  geometry = eurasia_wkt,
  mof = TRUE
)

cat("Eurasia occurrence data downloaded:", nrow(occurrences_eurasia), "records\n")
str(occurrences_eurasia)

# Flatten the MoF data
mof_eurasia <- unnest_extension(
  occurrences_eurasia,
  "MeasurementOrFact",
  fields = c("id", "eventID")
)

# Save the mof data
write_parquet(mof_eurasia, "mof_eurasia.parquet")

# Remove nested mof column from occurrences to be able to save as parquet
occurrences_eurasia_nomof <- occurrences_eurasia %>%
  select(-mof) # Remove the 'mof' column

# Double check structure
str(occurrences_eurasia_nomof)

# Save the occurrences data
write_parquet(occurrences_eurasia_nomof, "occurrences_eurasia.parquet")

# //////////////////////////////// OCCURRENCE WORKFLOW /////////////////////////////////

# ------------------------- Define taxon filters using aphiaID ------------------------------


excluded_classes <- c(
  1836, 1837, 178701, 1300, 1304, 1305, 1278, 147799, 394515, 1298360, 849233, 877220, 1051, 162563, 843665, 135219, 10193, 20300,
  10196, 798, 1250, 20285, 843662, 135220, 22626, 10189, 843666, 1517380, 293496, 1517379, 1517374, 1069, 104897, 182712, 104019,
  146271, 1083, 19948
)

excluded_orders <- c(
  196109, 1490567, 2689, 10305, 10313, 10329, 11014, 10331, 10211, 325345, 325345, 103353, 447, 10304, 17931, 10309, 10326, 16349,
  10295, 177531, 10306, 10297, 154206, 154156, 342486, 10308, 148390, 10316, 1600607, 10294, 160002, 11730, 10322, 1600798, 10327,
  10321, 10919, 10288, 10310, 10320, 767376, 10296, 10314, 10332, 991168, 154219, 397228, 151811, 120239, 154217, 151956, 1600606,
  10323, 10315, 833292, 154157, 22621, 10317, 152241, 833022, 123096, 833089, 154244, 10319, 154571, 1600603, 10318, 484684, 715608,
  10201, 1374984, 1100, 1101, 345938, 22597, 1106, 22598, 22605, 1035042, 1104, 325345, 325345, 1128
)

excluded_families <- c(
  101417, 101420, 101418, 101422, 236594, 101415, 196118, 158321, 110671, 154884, 104077, 104079, 104084, 104087, 104092, 128586,
  345271, 5953, 101424, 104103, 104104, 958, 227115
)

excluded_genera <- c(
  129715, 129329, 206129, 129722, 104108, 104111, 117212, 101749, 104137, 458856, 458856, 125815, 125815, 1434994, 117107, 104115,
  104193, 104159, 104116, 104117, 127533, 117216, 101602, 148370, 135361, 122429, 104174, 105399, 110673, 103358, 104121, 117111,
  104183, 104190, 104164, 115341, 103367, 129102, 104201, 196874, 104165, 104126, 105410, 104228, 104229, 104236, 104149, 110679,
  128691, 104204, 458856, 125815, 227368, 1296320
)

excluded_species <- c(
  104251, 104257, 104267, 254600, 104270, 104272, 117849, 157611, 103086, 104372, 104375, 265150, 127766, 127767, 148379, 117615,
  117616, 117333, 146735, 104283, 104464, 104465, 104467, 104496, 104284, 104287, 346271, 350046, 346272, 104290, 104292, 346278,
  139178, 146852, 150191, 183084, 183086, 285347, 117855, 135414, 135301, 102553, 135418, 346375, 127782, 149756, 104396, 196775,
  220851, 105414, 105416, 254621, 103375, 266042, 346483, 254602, 237965, 104316, 104321, 196593, 104422, 346520, 104578, 104579,
  117623, 135900, 107590, 107591, 103251, 103253, 247787, 325370, 353202, 254606, 104593, 353211, 220910, 346637, 117742, 110690,
  106377, 104632, 104633, 196784, 157675, 104513, 116115, 346683, 348210, 104841, 353500, 715130, 135442, 104470, 1770057, 103417,
  103413, 254722, 106642, 106656, 129110, 149765, 344717, 128930, 128931, 128935, 149767, 128944, 128946, 344725, 128948, 104694,
  104557, 104560, 104561, 104566, 104568, 117457, 254603, 130219, 135294, 362050, 338262, 117458, 1565062, 104514, 104515, 104516,
  104517, 104339, 105445, 254609, 117989, 105448, 105457, 254610, 104790, 104798, 104799, 254611, 103278, 104811, 720272, 117866,
  117267, 104846, 254612, 104848, 254613, 104851, 104852, 104853, 104855, 104856, 104878, 104459, 103259, 156451, 325384, 110708,
  110709, 110711, 131554, 128956, 128957, 128960, 131582, 104701, 360768, 423829, 104713, 423830, 102166, 102297, 102644, 102647,
  1765892, 139662, 1412088
)

# ------------------- Filter US based on taxa ------------------------------

# Step 1: Load the OBIS dataset
obis_data_US <- read_parquet("occurrences_US.parquet")
# Step 2: Count the number of records before filtering
records_before_US <- nrow(obis_data_US)
cat("Number of records before filtering:", records_before_US, "\n")
# Step 3: Apply filters to exclude the specified taxa
filtered_obis_data_US <- obis_data_US %>%
  filter(
    !(classid %in% excluded_classes) & # Exclude specified classes
      !(orderid %in% excluded_orders) & # Exclude specified orders
      !(familyid %in% excluded_families) & # Exclude specified families
      !(genusid %in% excluded_genera) & # Exclude specified genera
      !(speciesid %in% excluded_species) # Exclude specified species
  )
# Step 4: Count the number of records after filtering
records_after_US <- nrow(filtered_obis_data_US)
cat("Number of records after filtering:", records_after_US, "\n")
# Step 5: Save the filtered dataset
write_parquet(filtered_obis_data_US, "filtered_occurrences_US.parquet")

# ------------------- Filter Eurasia based on taxa ------------------------------

# Step 1: Load the OBIS dataset
obis_data_eurasia <- read_parquet("occurrences_eurasia.parquet")
# Step 2: Count the number of records before filtering
records_before_eurasia <- nrow(obis_data_eurasia)
cat("Number of records before filtering:", records_before_eurasia, "\n")
# Step 3: Apply filters to exclude the specified taxa
filtered_obis_data_eurasia <- obis_data_eurasia %>%
  filter(
    !(classid %in% excluded_classes) & # Exclude specified classes
      !(orderid %in% excluded_orders) & # Exclude specified orders
      !(familyid %in% excluded_families) & # Exclude specified families
      !(genusid %in% excluded_genera) & # Exclude specified genera
      !(speciesid %in% excluded_species) # Exclude specified species
  )
# Step 4: Count the number of records after filtering
records_after_eurasia <- nrow(filtered_obis_data_eurasia)
cat("Number of records after filtering:", records_after_eurasia, "\n")
# Step 5: Save the filtered dataset
write_parquet(filtered_obis_data_eurasia, "filtered_occurrences_eurasia.parquet")

# ------------------- Filter US based on GBIF stations ------------------------------

# Step 1: Load the OBIS data
obis_data_US <- read_parquet("filtered_occurrences_US.parquet")
# Step 2: Load the GBIF stations (stations_GBIF.csv)
gbif_data <- read.csv("stations_GBIF.csv")
# Step 3: Ensure numeric columns and round coordinates to 4 decimal places
obis_data_US <- obis_data_US %>%
  mutate(
    decimalLatitude = as.numeric(decimalLatitude),
    decimalLongitude = as.numeric(decimalLongitude),
    eventDate = as.character(eventDate) # Ensure eventDate is a character column
  )
# Step 4: Fix specific problematic record
obis_data_US <- obis_data_US %>%
  mutate(eventDate = ifelse(eventDate == "0196-05-29", "1996-05-29", eventDate))
# Step 4.1: Manually fix specific entries that should all be year 2021
obis_data_US <- obis_data_US %>%
  mutate(eventDate = ifelse(eventDate %in% c(
    "11/10/2061", "11/10/2062", "11/10/2063",
    "11/10/2064", "11/10/2065", "11/10/2068",
    "11/10/2069"
  ),
  "2021", eventDate
  ))
# Step 4.2: Manually fix specific entries that should all be 1947-1949
obis_data_US <- obis_data_US %>%
  mutate(eventDate = case_when(
    eventDate %in% c("8/23/47", "8/10/47", "7/20/47", "6/29/47", "7/11/47") ~ "1947",
    eventDate %in% c("7/10/48", "7/28/48") ~ "1948",
    eventDate %in% c("6/30/49", "8/23/49", "7/6/49", "8/3/49", "8/24/49") ~ "1949",
    TRUE ~ eventDate # Keep all other dates unchanged
  ))
# Step 5: Extract year programmatically from eventDate
extract_year <- function(date_str) {
  # Handle MM/DD/YYYY format explicitly
  if (grepl("\\d{1,2}/\\d{1,2}/\\d{4}", date_str)) {
    return(as.numeric(sub(".*/.*/(\\d{4})$", "\\1", date_str))) # Extract the 4-digit year
  }

  # Handle ISO 8601 and YYYY formats
  if (grepl("\\b\\d{4}\\b", date_str)) {
    return(as.numeric(sub(".*?(\\d{4}).*", "\\1", date_str)))
  }

  # Handle DD.MM.YYYY format
  if (grepl("\\d{2}\\.\\d{2}\\.\\d{4}", date_str)) {
    return(as.numeric(sub(".*?(\\d{4}).*", "\\1", date_str)))
  }

  # Handle MM/DD/YY or DD/MM/YY format (assuming MM/DD/YY)
  if (grepl("\\d{1,2}/\\d{1,2}/\\d{2}", date_str)) {
    year <- as.numeric(sub(".*?/(\\d{2})$", "\\1", date_str))
    return(ifelse(year < 50, 2000 + year, 1900 + year)) # Convert to 4-digit year
  }

  # Handle YYYY/YYYY ranges (take the first year)
  if (grepl("\\d{4}/\\d{4}", date_str)) {
    return(as.numeric(sub("(\\d{4})/.*", "\\1", date_str)))
  }

  # Return NA if no year could be extracted
  return(NA)
}
# Apply the year extraction function
obis_data_US <- obis_data_US %>%
  mutate(extractedEventYear = sapply(eventDate, extract_year))
# Step 6: Round coordinates and create unique identifiers
obis_data_US <- obis_data_US %>%
  mutate(
    roundedLatitude = trimws(format(round(decimalLatitude, 4), nsmall = 4)), # Remove whitespaces
    roundedLongitude = trimws(format(round(decimalLongitude, 4), nsmall = 4)), # Remove whitespaces
    unique_id = paste(extractedEventYear, roundedLatitude, roundedLongitude, sep = "_") # Unique identifier
  )
gbif_data <- gbif_data %>%
  mutate(
    decimalLatitude = as.numeric(decimalLatitude),
    decimalLongitude = as.numeric(decimalLongitude),
    year = as.character(year), # Convert year to character
    roundedLatitude = trimws(format(round(decimalLatitude, 4), nsmall = 4)), # Remove whitespaces
    roundedLongitude = trimws(format(round(decimalLongitude, 4), nsmall = 4)), # Remove whitespaces
    unique_id = paste(year, roundedLatitude, roundedLongitude, sep = "_") # Unique identifier
  )
# Step 7: Check the number of records before filtering
num_records_before <- nrow(obis_data_US)
cat("Number of records in OBIS data before filtering:", num_records_before, "\n")
# Step 8: Filter out duplicates from OBIS based on GBIF stations
filtered_obis_data_US <- obis_data_US %>%
  filter(!unique_id %in% gbif_data$unique_id)
# Step 9: Check the number of records after filtering
num_records_after <- nrow(filtered_obis_data_US)
cat("Number of records in OBIS data after filtering:", num_records_after, "\n")
num_filtered <- num_records_before - num_records_after
cat("Number of records filtered out:", num_filtered, "\n")
# Step 10: Save the filtered OBIS data back to a Parquet file
write_parquet(filtered_obis_data_US, "filtered_notgbif_US.parquet")


# ---------------- Filter Eurasia based on GBIF stations ------------------------------

# Step 1: Load the OBIS data
obis_data_eurasia <- read_parquet("filtered_occurrences_eurasia.parquet")
# Step 2: Load the GBIF stations (stations_GBIF.csv)
gbif_data <- read.csv("stations_GBIF.csv")
# Step 3: Ensure numeric columns and round coordinates to 4 decimal places
obis_data_eurasia <- obis_data_eurasia %>%
  mutate(
    decimalLatitude = as.numeric(decimalLatitude),
    decimalLongitude = as.numeric(decimalLongitude),
    eventDate = as.character(eventDate) # Ensure eventDate is a character column
  )
# Step 4: Extract year programmatically from eventDate
extract_year <- function(date_str) {
  # Handle MM/DD/YYYY format explicitly
  if (grepl("\\d{1,2}/\\d{1,2}/\\d{4}", date_str)) {
    return(as.numeric(sub(".*/.*/(\\d{4})$", "\\1", date_str))) # Extract the 4-digit year
  }

  # Handle ISO 8601 and YYYY formats
  if (grepl("\\b\\d{4}\\b", date_str)) {
    return(as.numeric(sub(".*?(\\d{4}).*", "\\1", date_str)))
  }

  # Handle DD.MM.YYYY format
  if (grepl("\\d{2}\\.\\d{2}\\.\\d{4}", date_str)) {
    return(as.numeric(sub(".*?(\\d{4}).*", "\\1", date_str)))
  }

  # Handle MM/DD/YY or DD/MM/YY format (assuming MM/DD/YY)
  if (grepl("\\d{1,2}/\\d{1,2}/\\d{2}", date_str)) {
    year <- as.numeric(sub(".*?/(\\d{2})$", "\\1", date_str))
    return(ifelse(year < 50, 2000 + year, 1900 + year)) # Convert to 4-digit year
  }

  # Handle YYYY/YYYY ranges (take the first year)
  if (grepl("\\d{4}/\\d{4}", date_str)) {
    return(as.numeric(sub("(\\d{4})/.*", "\\1", date_str)))
  }

  # Return NA if no year could be extracted
  return(NA)
}
# Apply the year extraction function
obis_data_eurasia <- obis_data_eurasia %>%
  mutate(extractedEventYear = sapply(eventDate, extract_year))

# Step 5: Round coordinates and create unique identifiers
obis_data_eurasia <- obis_data_eurasia %>%
  mutate(
    roundedLatitude = trimws(format(round(decimalLatitude, 4), nsmall = 4)), # Remove whitespaces
    roundedLongitude = trimws(format(round(decimalLongitude, 4), nsmall = 4)), # Remove whitespaces
    unique_id = paste(extractedEventYear, roundedLatitude, roundedLongitude, sep = "_") # Unique identifier
  )
gbif_data <- gbif_data %>%
  mutate(
    decimalLatitude = as.numeric(decimalLatitude),
    decimalLongitude = as.numeric(decimalLongitude),
    year = as.character(year), # Convert year to character
    roundedLatitude = trimws(format(round(decimalLatitude, 4), nsmall = 4)), # Remove whitespaces
    roundedLongitude = trimws(format(round(decimalLongitude, 4), nsmall = 4)), # Remove whitespaces
    unique_id = paste(year, roundedLatitude, roundedLongitude, sep = "_") # Unique identifier
  )
# Step 6: Check the number of records before filtering
num_records_before <- nrow(obis_data_eurasia)
cat("Number of records in OBIS data before filtering:", num_records_before, "\n")
# Step 7: Filter out duplicates from OBIS based on GBIF stations
filtered_obis_data_eurasia <- obis_data_eurasia %>%
  filter(!unique_id %in% gbif_data$unique_id)
# Step 8: Check the number of records after filtering
num_records_after <- nrow(filtered_obis_data_eurasia)
cat("Number of records in OBIS data after filtering:", num_records_after, "\n")
# Step 9: Calculate the number of filtered records
num_filtered <- num_records_before - num_records_after
cat("Number of records filtered out:", num_filtered, "\n")
# Step 10: Save the filtered OBIS data back to a Parquet file
write_parquet(filtered_obis_data_eurasia, "filtered_notgbif_eurasia.parquet")

# ---------------- Check columns and merge to one parquet file ------------------------------

# Load the datasets
notgbif_US <- read_parquet("filtered_notgbif_US.parquet")
notgbif_eurasia <- read_parquet("filtered_notgbif_eurasia.parquet")
# Check the columns in each dataset
cat("Columns in filtered_notgbif_US:\n")
print(colnames(notgbif_US))
cat("\nColumns in filtered_notgbif_eurasia:\n")
print(colnames(notgbif_eurasia))
# Get all unique column names from both datasets
all_columns <- union(colnames(notgbif_US), colnames(notgbif_eurasia))
# Add missing columns to each dataset
notgbif_US[setdiff(all_columns, colnames(notgbif_US))] <- NA
notgbif_eurasia[setdiff(all_columns, colnames(notgbif_eurasia))] <- NA
# Merge the datasets
merged_data <- rbind(notgbif_US, notgbif_eurasia)
# Remove duplicates based on the 'id' column
merged_data <- merged_data %>%
  distinct(id, .keep_all = TRUE)
# Save the merged dataset to a Parquet file
write_parquet(merged_data, "merged_notgbif.parquet")
cat("Merged dataset saved to 'merged_notgbif.parquet' with unique entries in the 'id' column.\n")

# -------------------- Data quality filters -------------------------

# Apply filtering steps using dplyr
filtered_merged <- merged_data %>%
  filter(
    (!basisOfRecord %in% c("FOSSIL_SPECIMEN") | is.na(basisOfRecord)) &
      (!preparations %in% c("FOSSIL") | is.na(preparations)) &
      (coordinatePrecision < 0.01 | is.na(coordinatePrecision)) &
      (coordinateUncertaintyInMeters < 10000 | is.na(coordinateUncertaintyInMeters)) &
      (!coordinateUncertaintyInMeters %in% c(301, 3036, 999, 9999) | is.na(coordinateUncertaintyInMeters))
  )
# Save the filtered data with UTF-8 encoding
write_parquet(filtered_merged, "merged_filtered.parquet")


# /////////////////////// MOF WORKFLOW /////////////////////////////

# CHECK WHETHER ALL MOF ENTRIES HAVE ASSIGNED ID VALUES

# ---------------------- Merge datasets ---------------------------

# Read the MoF Parquet files
mof_US <- read_parquet("mof_US.parquet")
mof_eurasia <- read_parquet("mof_eurasia.parquet")
# Merge the MoF data
mof_combined <- bind_rows(mof_US, mof_eurasia)
# Remove potential duplicates
mof_combined <- mof_combined %>%
  distinct()
# Save the combined MoF data
write_parquet(mof_combined, "mof_combined.parquet")
cat("Combined MoF data saved to 'mof_combined.parquet'\n")

# ----------- Filter based on merged occurrence file --------------

# Read the combined MoF file
mof_combined <- read_parquet("mof_combined.parquet")
# Read the filtered file
merged_filtered <- read_parquet("merged_filtered.parquet")
# Filter the MoF data to keep only matching `id` values
filtered_mof <- mof_combined %>%
  filter(id %in% merged_filtered$id)
# Save the filtered MoF data
write_parquet(filtered_mof, "filtered_mof_combined.parquet")
cat("Filtered MoF data saved to 'filtered_mof_combined.parquet'\n")

# nolint end
