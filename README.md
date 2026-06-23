# BENTH-MARC: Georeferenced zoobenthic biodiversity data from the marine Arctic 

# Authors 
Hanna Modin<sup>1</sup>, Jannik Schnier<sup>2</sup>, Jennifer Dannheim<sup>2</sup>, Paul Renaud<sup>3</sup>, Raul Primicerio<sup>1</sup>, Mikael Sejr<sup>4</sup>, Camille Poitrimol<sup>5</sup>, Cindy Grant<sup>5</sup>, Lisa Treau De Coeli<sup>5</sup>, Philippe Archambault<sup>5</sup>, Bodil Bluhm<sup>1</sup>.

<sup>1</sup> The Arctic University of Norway, Tromsø, 9037, Norway  
<sup>2</sup> Alfred Wegener Institute, Bremerhaven, 27570, Germany  
<sup>3</sup> Akvaplan-niva, Tromsø, 9296, Norway  
<sup>4</sup> Aarhus University, Aarhus, 8000, Denmark  
<sup>5</sup> Université Laval, Québec, G1V 0A6, Canada

*Correspondence to:* Hanna Modin (hanna.m.modin@uit.no)

# Abstract 
As the Arctic Ocean undergoes rapid environmental change and is subjected to increasing anthropogenic pressures, there is a growing need for comprehensive baseline data on its biodiversity. Although sampling efforts have been considerable over the past decades, the existing biodiversity records are often fragmented and scattered across multiple databases. We present BENTH-MARC, an open pan-Arctic database with BENTHos in the Marine ARCtic. BENTH-MARC contains 2,812,548 georeferenced zoobenthic taxon records of 8,331 species and 3,285 taxa at other taxonomic levels from 684 datasets and 210,867 stations (Figure 1). Data span across the entire pan-Arctic realm and integrate regional and global biodiversity databases as well as previously unpublished datasets. The records in BENTH-MARC come from two and a half centuries of sampling, from 1773-2026, and are based on morphological identification. By providing harmonized and accessible data, BENTH-MARC can support the assessment of biological consequences of ongoing environmental change, aid in the identification of biodiversity hotspots and evaluation of conservation targets. The database can also be used to guide future sampling efforts.

<img width="1910" height="1907" alt="map_stations" src="https://github.com/user-attachments/assets/4329de71-93ff-4735-bcd9-58799b2930d4" />
*<B>Figure 1.</B> Spatial distribution of sampling stations in the BENTH-MARC database. The Arctic Large Marine Ecosystems (purple lines) define the main study area. The Large Marine Ecosystems are Labrador Sea (LS), Hudson Bay (HB), Baffin Bay (BB), Beaufort Sea (BeS), Chukchi Sea (CS), West Bering Sea (WBS), East Bering Sea (EBS), Aleutian Islands (AI), East Siberian Sea (ESS), Laptev Sea (LS), Kara Sea (KS), Barents Sea (BaS), Norwegian Sea (NS), Iceland (I), Faroe Plateau (FP), Greenland Sea (GS), North Canadian Archipelago (NCA) and Central Arctic Ocean (CAO).* 

# Data sources
BENTH-MARC includes publicly available, and previously unpublished, georeferenced and morphologically identified metazoan datasets of meio-, macro- and megabenthos in the Arctic LMEs. Only invertebrates were included, more specifically from the following phyla: Annelida, Mollusca, Arthropoda, Echinodermata, Cnidaria, Porifera, Sipuncula, Bryozoa, Chordata, Brachiopoda, Nematoda, Nemertea, Tardigrada, Platyhelminthes, Hemichordata, Kinorhyncha, Priapulida, Loricifera, Phoronida and Entoprocta. Data were extracted from GBIF and OBIS on 2026-05-05. The records were downloaded using the R packages rGBIF and robis, which offer programmatic access to the application programming interface (API) of GBIF and OBIS. To access associated metadata and information, complementary downloads targeted the related Extended Measurement or Fact (eMoF) extensions. The GBIF downloads are available at at https://doi.org/10.15468/dd.a8vs9g26 and https://doi.org/10.15468/dd.qvy3m627. Data from CRITTERBASE were downloaded through Alfred Wegener’s Institute’s dedicated web portal on 2026-02-06. Data from OGSL were obtained from the laboratory of P. Archambault (personal communication, 11 March 2026). References to all included datasets are available in the datasets.csv file.

# Data availability
The data is primarily available as two separate files; one Parquet file with all occurrence records in a long format, and one CSV file with dataset-level metadata. The column datasetKey links these two files. Parquet is a column-oriented data storage format that facilitates efficient data processing and retrieval of big data. Unlike row-based formats like CSV, Parquet organizes data by columns, which allows for better compression and faster analytical queries of big datasets. Although there are no strict upper limits to how much data you can store in a CSV file, analyzing large CSV files requires significantly more processing power than Parquet files. To accommodate users who cannot access the data in Parquet format, the occurrence records are also available as one CSV file per LME. 

All files are available on Zenodo at https://doi.org/10.5281/zenodo.20782806. Usage license is under Creative Commons Attribution 4.0 International (CC-BY-4.0). 

# Code availability
The R, Python and LaTeX code that was used to create the database BENTH-MARC and to generate this manuscript can be found in the GitHub repository benth-marc at https://github.com/hanna-modin/benth-marc. The workflow behind the database includes 19 scripts, of which five are in R and 14 in Python. Note that certain scripts are computationally intensive and require substantial CPU and memory resources. In the main folder of the GitHub repository and on Zenodo are also Excel files that give an overview of the workflow, glossary, mapping of columns from source databases to BENTH-MARC, and the main taxonomic filter. In workflow.xlsx, we have described the execution order, purpose, location, potential input and output files, and potential requirement of manual work associated with each script. The full process can be repeated without any new manual work if the same input occurrence data is used, but if new harvests from OBIS and GBIF are performed, there will be a need to manually update the filters and MoF selection based on the new datasets. In glossary.xlsx, there is an overview of all 67 columns in BENTH-MARC's main occurrence file and the 12 columns in the dataset-level file. We have specified the data types and data coverage of each column, added explanations, and marked which columns are valid Darwin Core terms. The file column_mapping.xlsx describes which column in the source databases has been mapped to which column in BENTH-MARC, whereas taxonomic_filter.xlsx gives an overview of the main taxonomic filter and its validation through WoRMS.

 	Hanna Modin
PhD Candidate
P: +47 77 64 50 27
hanna.m.modin@uit.no
Faculty of Biosciences, Fisheries and Economics
UiT The Arctic University of Norway
