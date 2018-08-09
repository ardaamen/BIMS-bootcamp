# Using 4 characters (slashes/dashes/comments/etc.) adds these lines to code outline; to access select icon on top left of source window; these lines are indicated by an arrow next to the row number on code

# Load library -----
library(tidyverse) #an R environment that tries to "tidy" up and unify the way basic functions are used
# or load readr, dplyr, ggplot2 if issues; all are in tidyverse library

# Download data and skeleton script from GitHub into project -----

# Go to GitHub [repo](https://github.com/mariekekjones/BIMS-bootcamp) to get these materials

# NHANES data ---- .csv table file to read in

# Read in downloaded data using `read_csv()` from {readr} package; reads into a tibble: a "tidy dataframe"
nh <- read_csv("nhanes.csv")

# Show the first few lines of the data and the dimensions
head(nh) #default is first 6 rows as a tibble 
head(nh, 10) #to show more rows, in this case, 10

dim(nh) #shows dimensions in rowsxcolumns

# Optionally bring up data in a viewer window.
View(nh)

# dplyr review --------

# Access dplyr cheat sheet from `Help` menu > Cheatsheets link

# dplyr verbs
# 1. `filter()`
# 2.. `group_by()` 
# 3. `summarize()`

# dplyr takes a tibble dataframe as its first argument and then a logical condition to meet as the second argument

# - `==`: Equal to
# - `!=`: Not equal to
# - `>`, `>=`: Greater than, greater than or equal to
# - `<`, `<=`: Less than, less than or equal to
 
# If you want to satisfy *all* of multiple conditions, you can use the "and" operator, `&`. 
# The "or" operator `|` (the pipe character, usually shift-backslash) will return a subset that meet *any* of the conditions.

# Let's use filter to return rows where the person was elderly (defined as >= 80 years old)
filter(nh, Age >= 80)
filter(nh, Age == 80)


# Using the pipe ----- 
# `%>%` or `Control + Shift + M` 

# `head()` without pipe
head(nh, 8)

# `head()` with pipe; start with data set and then functions to modify the data set
nh %>% head(8)

# Now let's use the pipe operator with filter to subset for elderly people >= 80 years old
# without pipe
filter(nh, Age >= 80)

# with pipe
nh %>% filter(Age >= 80)

# Nesting v. %>% ----------

# Let's say we want to see the mean height, grouped by Race, only for adults.
# without pipe
summarize(
  group_by(
    filter(nh, Age > 18), Race), meanHeight = mean(Height, na.rm = TRUE))

# with pipe; allows arguments that belong to a function to stay with that function 
nh %>% 
  filter(Age < 18) %>% 
  group_by(Race) %>% 
  summarize(meanHeight = mean(Height, na.rm = TRUE))

# with pipe arranged in order
nh %>% 
  filter(Age > 18) %>% 
  group_by(Race) %>% 
  summarize(meanHeight = mean(Height, na.rm = TRUE)) %>% 
  arrange(meanHeight)

#desc arrange
nh %>% 
  filter(Age > 18) %>% 
  group_by(Race) %>% 
  summarize(meanHeight = mean(Height, na.rm = TRUE)) %>% 
  arrange(desc(meanHeight))

# ** EXERCISE 1 ** ------------
# ** YOUR TURN **
#   A. How many observations are there of children (< 18 years old)?
nh %>% filter(Age < 18) 

#   B. How many cases of obese children are there (BMI >= 30)?
nh %>% filter(Age < 18) %>% 
  filter(BMI <= 30) 

nh %>% 
  filter(Age < 18 & BMI >= 30)

#   C. Use `filter()`, `group_by()` and `summarize()` to find the mean BMI by Smoking Status for only Adults who have Diabetes. Do diabetic smokers or non-smokers have higher BMI?
nh %>% 
  filter(Age > 18) %>% 
  filter(Diabetes == "Yes") %>% 
  group_by(SmokingStatus) %>% 
  summarize(meanBMI = mean(BMI, na.rm = TRUE))

nh %>% 
  filter(Age > 18) %>% 
  group_by(SmokingStatus, Diabetes) %>% 
  summarize(meanBMI = mean(BMI, na.rm = TRUE))

# ggplot2 ---------

# allows you to build a plot layer-by-layer by specifying:
 
# - a **geom**, which specifies how the data are represented on the plot (points, lines, bars, etc.),
# - **aesthetics** that map variables in the data to axes on the plot or to plotting size, shape, color, etc.,
# - **facets**, which we've already seen above, that allow the data to be divided into chunks on the basis of other categorical or continuous variables and the same plot drawn for each chunk.
 
# Scatterplots ---------
# Age (X) against Height (Y) (continuous X, continuous Y)
nh %>% 
  ggplot(aes(x = Age, y = Height)) #just canvas, add geoms for scatterplot

nh %>% 
  ggplot(aes(x = Age, y = Height)) +  #use'+' instead of pipe for ggplot package
  geom_point()

# color the points by Gender
nh %>% 
  ggplot(aes(x = Age, y = Height, color = Gender)) +
  geom_point()

#or; colors only the geom_point plot but not downstream additions
nh %>% 
  ggplot(aes(x = Age, y = Height)) +
  geom_point(aes(color = Gender))

# color the points blue and shape them as +
nh %>% 
  ggplot(aes(x = Age, y = Height)) +
  geom_point(color = "blue", shape = 3)

# what is the difference between coloring by a variable and coloring by static values?
  #don't need to call aesthetics for whole plot changes, only for mods to a certain variable

# plot points colored by Gender and smoothed line
nh %>% 
  ggplot(aes(x = Age, y = Height)) +
  geom_point(aes(color = Gender)) +
  geom_smooth(method = "auto")

?geom_smooth()

# plot smoothed trend line and points both colored by gender
nh %>% 
  ggplot(aes(x = Age, y = Height)) +
  geom_point(aes(color = Gender)) +
  geom_smooth(aes(color = Gender))

# color all layers by Gender
nh %>% 
  ggplot(aes(x = Age, y = Height, color = Gender)) +
  geom_point() +
  geom_smooth()


# color all layers by Gender, add transparency to points, make line bolder
nh %>% 
  ggplot(aes(x = Age, y = Height, color = Gender)) +
  geom_point(alpha = .2 ) + #add transparency with alpha
  geom_smooth(lwd = 2) #increase weight of line


# ** EXERCISE 2 ** ----------
# ** YOUR TURN **
#   A. Use a scatterplot to investigate the relationship between Age and Testosterone.
nh %>% 
  ggplot(aes(x = Age, y = Testosterone)) +
  geom_point()

#   B. Color the plot in A by Gender.
nh %>% 
  ggplot(aes(x = Age, y = Testosterone, color = Gender)) +
  geom_point()

#or
nh %>% 
  ggplot(aes(x = Age, y = Testosterone)) +
  geom_point(aes(color = Gender))

#   C. Create the plot in A for just men.
nh %>%
  filter(Gender == "male") %>% 
  ggplot(aes(x = Age, y = Testosterone)) +
  geom_point()

#   D. Filter for men > 65 and < 80 years old and then examine the relationship between Age and Testosterone.
nh %>%
  filter(Gender == "male") %>% 
  filter(Age > 65 & Age < 80) %>% 
  ggplot(aes(x = Age, y = Testosterone)) +
  geom_point()

#   E. Does the relationship you saw in D differ if the man is physically active (PhysActive == "Yes")? Use colored loess lines to see the effect of physical activity.
nh %>%
  filter(Gender == "male") %>% 
  filter(Age > 65 & Age < 80) %>% 
  ggplot(aes(x = Age, y = Testosterone)) +
  geom_point() + 
  geom_smooth(lwd = 2, aes(color = PhysActive))
  

# Visualizations for discrete X ---------
# Plot BMI by Smoking Status
# blank canvas, note categories on X
nh %>% 
  ggplot(aes(x = SmokingStatus, y = BMI))

# try with geom point
nh %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_point()

# no variability in X values --> overplotting: many points on top of each other so can't see data
# so add some random variability to x-axis using geom_jitter
nh %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_jitter()

# remove NA category and add transparency; use !is.na() in filter to remove NA or missing values
nh %>% 
  filter(!is.na(SmokingStatus)) %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_jitter(alpha = 0.25)

# plot boxplot
nh %>% 
  filter(!is.na(SmokingStatus)) %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_boxplot()

# plot jitter and boxplot
nh %>% 
  filter(!is.na(SmokingStatus)) %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_jitter(alpha = 0.25) +
  geom_boxplot()

# improve the jitter/boxplot
nh %>% 
  filter(!is.na(SmokingStatus)) %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_jitter(alpha = 0.25) +
  geom_boxplot(alpha = 0.5, outlier.colour = NA)

# color boxplot by gender
nh %>% 
  filter(!is.na(SmokingStatus)) %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_boxplot(aes(color = Gender))

# fill boxplot by gender
nh %>% 
  filter(!is.na(SmokingStatus)) %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_boxplot(aes(fill = Gender))

# **EXERCISE 3** ----------
# ** YOUR TURN **
#   A. Create boxplots showing height for Adults of different Races
nh %>% 
  filter(Age >= 18) %>% 
  ggplot(aes(x = Race, y = Height)) +
  geom_boxplot()

#   B. Add jittered data under boxplots in A.
nh %>% 
  filter(Age >= 18) %>% 
  ggplot(aes(x = Race, y = Height)) +
  geom_jitter(alpha = 0.25) +
  geom_boxplot(alpha = 0.5, outlier.colour = NA) 
 
#   C. Fill boxplots in A by Gender
nh %>% 
  filter(Age >= 18) %>% 
  ggplot(aes(x = Race, y = Height)) +
  geom_boxplot(aes(fill = Gender))

# Plotting univariate continuous data -------

#canvas for height
nh %>% 
  ggplot(aes(Height))

# save canvas as p then add histogram
p <- nh %>% 
  ggplot(aes(Height))
p
p + geom_histogram()

# change bin size
p + geom_histogram(bins = 80)
p + geom_histogram(bins = 10)
p + geom_histogram(bins = 100)

# smoothed density curve
p + geom_density()

# histogram colored by Race
p + geom_histogram(aes(color = Race))

# histogram filled by Race
p + geom_histogram(aes(fill = Race))

# get help on histogram function
?geom_histogram

# change position
p + geom_histogram(aes(fill = Race), position = "identity", bins = 85)
#these histograms are blocking each other; identity position layers histograms by depth

# add transparency
p + geom_histogram(aes(fill = Race), position = "identity", bins = 85, alpha = 1/3)

# try with density curves colored by Race
p + geom_density(aes(color = Race))

# change fill color and add transparency
p + geom_density(aes(color = Race, fill = Race, alpha = 1/8))

# Faceting ----------- 
  #makes miniature plots of that variable

# overlapping histograms filled by Race
p + geom_histogram(aes(fill = Race), position = "identity", bins = 85)

# facet histograms by race
p + geom_histogram(aes(fill = Race)) +
  facet_wrap(~Race)

# facet density plots by Race
p + geom_density(aes(color = Race)) +
  facet_wrap(~Race)

# Choosing colors and themes ----------

# boxplot of BMI by Smoking status without missing Smoking Status
nh %>% 
  filter(!is.na(SmokingStatus)) %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_boxplot()

# filled by Diabetes
nh %>% 
  filter(!is.na(SmokingStatus)) %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_boxplot(aes(fill = Diabetes))

# see all color options; viridis package has popular color scheme
colors()

#change colors manually
nh %>% 
  filter(!is.na(SmokingStatus)) %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_boxplot(aes(fill = Diabetes)) +
  scale_fill_manual(values = c("cornflowerblue", "salmon"))

#change theme
nh %>% 
  filter(!is.na(SmokingStatus)) %>% 
  ggplot(aes(x = SmokingStatus, y = BMI)) +
  geom_boxplot(aes(fill = Diabetes)) +
  scale_fill_manual(values = c("cornflowerblue", "salmon")) +
  theme_bw() #takes out gray background; classic has zero lines; minimal without axis lines
#ggthemes package has more theme options 

# ** EXERCISE 4 ** ----------
# ** YOUR TURN **
# Practice creating the plots pictured

#   A. 
#   No = not physically active, Yes = physically active
nh %>% 
  filter(!is.na(PhysActive) & Gender == "male") %>% 
  filter(Age > 65 & Age < 80) %>% 
  ggplot(aes(x = Age, y = Testosterone)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~PhysActive)

#   B. 
#   Custom colors are "salmon" and "seagreen"
nh %>% 
  ggplot(aes(x = RelationshipStatus, y = AlcoholYear)) +
  geom_boxplot(aes(fill = Gender)) +
  scale_fill_manual(values = c("salmon", "seagreen"))

#   C. 
nh %>% 
  filter(Age < 20) %>% 
  ggplot(aes(x = Age, y = Height)) +
  geom_smooth(aes(color = Gender)) +
  scale_fill_manual(values = c("salmon", "seagreen")) +
  facet_wrap(~Race)
  
  
  
  

