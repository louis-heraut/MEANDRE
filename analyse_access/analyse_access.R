# Copyright 2024
# Louis Héraut (louis.heraut@inrae.fr)*1

# *1   INRAE, France

# This file is part of MEANDRE.

# MEANDRE is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# MEANDRE is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with MEANDRE.
# If not, see <https://www.gnu.org/licenses/>.


library(dplyr)
library(ggplot2)
library(lubridate)


## GET ACCESS DATA ___________________________________________________
Paths = list.files("hash_access", full.names=TRUE)
access = dplyr::tibble()

for (path in Paths) {
    IPhash = readLines(path)
    date = as.Date(gsub("(.*[_])|([.].*)", "",
                        basename(path)))
    access = dplyr::bind_rows(access,
                              dplyr::tibble(date=date,
                                            IPhash=IPhash))
}

ASHE::write_tibble(access, "access.csv")


## PLOT ______________________________________________________________
figdir = "figures"
if (!dir.exists(figdir)) {
    dir.create(figdir)
}

dataSHEEP::assign_colors_and_fonts()

### 
access_daily <- access %>%
    group_by(date) %>%
    summarise(unique_IP=n_distinct(IPhash))

plot = ggplot(access_daily, aes(x=date, y=unique_IP)) +
    geom_col(fill=IPCCgrey50) +
    labs(title = "UNIQUE IP PER DAY", x=NULL, y="number of unique IP") +
    dataSHEEP::theme_IPCC(axis.text.x_angle=90,
                          axis.text.x_vjust=0.65) +
    scale_x_date(expand=c(0, 0),
                 breaks="month", date_labels="%m/%Y",
                 minor_breaks="month",
                 guide="axis_minor") +
    scale_y_continuous(expand=c(0, 0), limits=c(0, NA),
                       n.breaks=8)

ggsave(plot=plot,
       path=figdir,
       filename="access_daily.pdf",
       width=20, height=10, units='cm',
       dpi=300, device=cairo_pdf)


###
access_monthly <- access %>%
    mutate(month = floor_date(date, "month")) %>%
    group_by(month) %>%
    summarise(unique_IP = n_distinct(IPhash))

plot = ggplot(access_monthly, aes(x = month, y = unique_IP)) +
    geom_col(fill=IPCCgrey50) +
    labs(title="UNIQUE IP PER MONTH", x=NULL, y="number of unique IP") +
    dataSHEEP::theme_IPCC(axis.text.x_angle=90,
                          axis.text.x_vjust=0.65) +
    scale_x_date(expand=c(0, 0),
                 breaks="month", date_labels="%m/%Y",
                 minor_breaks="month",
                 guide="axis_minor") +
    scale_y_continuous(expand=c(0, 0), limits=c(0, NA),
                       n.breaks=8)

ggsave(plot=plot,
       path=figdir,
       filename="access_monthly.pdf",
       width=20, height=10, units='cm',
       dpi=300, device=cairo_pdf)


### 
access_cumulative <- access %>%
    arrange(date) %>%
    distinct(IPhash, date) %>%
    group_by(date) %>%
    summarise(new_unique_IP = n_distinct(IPhash)) %>%
    mutate(cum_unique_IP = cumsum(new_unique_IP))

plot = ggplot(access_cumulative, aes(x=date, y=cum_unique_IP)) +
    geom_line(color=IPCCgrey50, linewidth = 0.4) +
    labs(title="CUMULATIVE UNIQUE IP OVER TIME",
         x=NULL, y="cumulative IP") +
    dataSHEEP::theme_IPCC(axis.text.x_angle=90,
                          axis.text.x_vjust=0.65) +
    scale_x_date(expand=c(0, 0),
                 breaks="month", date_labels="%m/%Y",
                 minor_breaks="month",
                 guide="axis_minor") +
    scale_y_continuous(expand=c(0, 0), limits=c(0, NA),
                       n.breaks=8)

ggsave(plot=plot,
       path=figdir,
       filename="access_cumulative.pdf",
       width=20, height=10, units='cm',
       dpi=300, device=cairo_pdf)



