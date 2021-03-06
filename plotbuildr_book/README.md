---
title: "Create Interactive Plots Dynamically: plotbuildR"
author: |
   | Niket Doshi^1^ and Eliano Marques^2^
   |
   | 1. Sr. Data Scientist, Think Big Analytics, A Teradata Company
   | 2. Director, Head of Data Science International, Think Big Analytics, A Teradata Company
institute: 
   - Think Big Analytics
output: html_document
nocite: | 
---

**Keywords**: Visualization, **shiny**, **plotly**, **networkD3**, **leaflet**

**Webpages**: https://thinkbiganalytics.github.io/PlotBuildR/

*R* has many packages that facilitate the visualisation of data at camera-ready standards for journal publication. In particular **ggplot2** is a very popular package that follows the principle of grammar of graphics. However, this may be difficult to access for non-expert users. Other packages that offer APIs for easier access to interactive graphing capabilities also exist. For example, **Plotly** has a great visualisation API that can render several dynamic plots. However, tweaking plots can be cumbersome, and may be a challenge for newcomers to *R*. Likewise, **NetworkD3** has a visualisation API that renders network graphs. A challenge to using these packages is that there is a separate function to each kind of graph. These different packages do not have a consistent behaviour, as they take different arguments, putting a larger demand of effort on the user.

To alleviate these issues, we propose the package **plotbuildR**. This is a visualisation framework built on **Shiny** which leverages all the powerful graphing libraries in *R*, such as **Plotly**, **NetworkD3**, **leaflet** and **dygraph**. It allows users to create highly dynamic graphs in a **Shiny** app on the fly. It can work as a stand alone application or be parts of other applications as a self contained module.

The package **plotbuildR** is highly flexible and offers a dynamic visualisation framework. It provides a common interface to several existing *R* packages, and an intuitive list of plots from which to select. This makes it easy compare several kind of graphs with a few quick clicks, to see which lends itself to interpretation most effortlessly.

Since the package will potentially be open sourced, anyone can add ports to their graphics package. We hope this can offer an intuitive way into the world of graphics in **R** for all levels of useRs, be it novices to **R** or expert users seeking to compare many different visualisations quickly or try out packages they have not used before.
