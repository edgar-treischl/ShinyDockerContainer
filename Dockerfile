# Base R with Shiny and common packages
FROM rocker/r-ver:4.4.1

LABEL maintainer="you@example.com"
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libxt-dev \
    libpng-dev \
    libjpeg-dev \
    libv8-dev \
    libgit2-dev \
    libglpk-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    git \
    pandoc \
    ca-certificates \
    fonts-dejavu \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for GitLab
ARG GITLAB_PAT
ENV GITLAB_PAT=${GITLAB_PAT}

# Install common R packages
RUN install2.r --error \
    shiny \
    tidyverse \
    data.table \
    lubridate \
    janitor \
    plotly \
    DT \
    shinydashboard \
    shinythemes \
    remotes \
    renv \
    devtools \
    markdown

# Set default CRAN repo and shiny options
RUN mkdir -p /etc/R && touch /etc/R/Rprofile.site
RUN echo 'options(repos = c(CRAN = "https://cloud.r-project.org"), shiny.port = 3838, shiny.host = "0.0.0.0")' >> /etc/R/Rprofile.site

RUN R -e "remotes::install_gitlab('edgar-treischl/ReportMaster', host = 'gitlab.lrz.de', auth_token = Sys.getenv('GITLAB_PAT'))"
RUN R -e "remotes::install_gitlab('edgar-treischl/ReportMasterApp', host = 'gitlab.lrz.de', auth_token = Sys.getenv('GITLAB_PAT'))"

RUN groupadd -g 1000 shiny && useradd -m -d /home/shiny -u 1000 -g shiny -s /bin/bash shiny
USER shiny

# No app included; assumes you'll mount or COPY it
# Shiny will run anything placed in /app
#CMD ["R", "-e", "shiny::runApp('/app')"]
CMD ["R", "-q", "-e", "library(ReportMasterApp); shiny::runApp(system.file('app', package = 'ReportMasterApp'))"]

