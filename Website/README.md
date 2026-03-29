# Spatial Map of Mouse Pyelonephritis Rshiny Application

## Introduction
The Spatial Pyelonephritis RShiny application has been meticulously crafted with the explicit purpose of providing researchers, spanning both wet and dry lab domains, a powerful platform for conducting downstream Bioinformatics analyses with utmost efficiency and precision. Tailored to meet the diverse needs of researchers, this application boasts two comprehensive modules, each designed to streamline and enhance the analytical process. 

The Spatial Pyelonephritis RShiny application is equipped with an intuitive and user-friendly interface, allowing researchers to navigate complex analyses with ease and efficiency. With interactive visualizations and customizable workflows, users can tailor their analytical approach to suit specific research objectives, fostering collaboration and accelerating scientific discoveries in the field of pyelonephritis research.

![Pyelonephritis2](https://github.com/gucascau/Pyelonephritis/assets/23031126/64267437-31d4-424c-8227-1fb32f7b841a)


## Description
In this project, we generated a comprehensively high resolution map of mouse kidney remodeling after bacteria infections within different dates.

## Datasets
1. Single cell RNAseq using PIPseq at 0dpi, 3dpi, 7dpi and 28dpi;
2. Spatial transcriptomics at 0dpi(1), 1dpi(2), 3dpi(2), 5dpi(2), 7dpi(1), 28dpi(2), 56dpi(1).

## Methods
<img width="831" alt="ProjectPipeline" src="https://github.com/gucascau/Pyelonephritis/assets/23031126/30c4758b-818a-42c7-93b0-d6f7e6e4abc7">

## Usage
I would strongly recommend running the Pyelonephritis-Shiny app locally instead of using the website, especially considering that the website tends to be slow when uploading large RDS files.

Here are the steps to follow:

1. Download the Pyelonephritis-Shiny app by cloning the repository:
```  
    git clone https://github.com/gucascau/Pyelonephritis-Shiny.git
```  
2. Download the required Single Cell and Spatial transcriptomic RDS files.
3. Run the app using RStudio by executing the App.R file.
```  
    runApp()
```  
4. Upload the Spatial transcriptomic RDS file to analyze gene spatial distribution, Dimplot, and Spatial Cluster Distribution.
5. Upload the Single Cell RDS file to analyze the distribution of various cell types across infected timepoints and for analyzing the distribution of requested genes in scRNA-seq data.

Website link: 
https://pyelonephritis.shinyapps.io/Pyelonephritis-Shiny/

## Copyright
For more detail information, please feel free to contact: xin.wang@nationwidechildrens.org

Copyright (c) 2023 Xin Wang

Current version v1.0
