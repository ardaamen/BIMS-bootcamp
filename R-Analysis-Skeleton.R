# This script is for the Data Analysis in R section of the Practical Computing Skills for Biomedical Researchers boot camp

# load tidyverse library ---------
library(tidyverse)

### Download data and skeleton script from GitHub into project ----

# Read in downloaded data using readr package
nh <- read_csv("nhanes.csv")

# Show the first few lines of the data and the dimensions
head(nh)
dim(nh)

# Optionally bring up data in a viewer window.
View(nh)

# Create adults only dataset
nha <- nh %>% 
  filter(Age >= 18)
nha

# remove the original nh object
rm(nh)

# investigate Race (categorical variable)
class(nha$Race) #character vector: strings
levels(nha$Race) #the values a variable can take on; applies to a factor but not character vector

#create factor variables from all character variables: factor variable: grouped character; e.g. Gender, Race, etc
nha <- nha %>% 
  mutate_if(is.character, as.factor) #creates new variables conditionally
#saving change to original dataset so is retained
levels(nha$Race)

### Descriptive Statistics -------------

# measures of the center
mean(nha$BMI, na.rm = TRUE)
median(nha$BMI, na.rm = TRUE)

# histogram to see distribution
nha %>% 
  ggplot(aes(BMI)) +
  geom_histogram()

#measures of spread
sd(nha$BMI, na.rm = TRUE)

  #interquartile range: ideal for skewed distributions; Q3 - Q1
quantile(nha$BMI, na.rm = TRUE)

quantile(nha$BMI, na.rm = TRUE, probs = c(.25, .75))

  #range
range(nha$BMI, na.rm = TRUE)

# summary of dataframe; info on every variable/column
  #frequency of each condition for discrete variables
  #data stats for numerical variables
summary(nha)

#descriptive stats for discrete variables
table(nha$Race) #counts for each group/category
table(nha$Gender, nha$Race) #cross-tabulation of race by gender

### ** EXERCISE 1 ** --------------
#   ** YOUR TURN **

#A. Calculate the median Income in the NHA dataset
median(nha$Income, na.rm = TRUE)

#B. Find the variance of Weight
var(nha$Weight, na.rm = TRUE)
#or
sc(nha$Weight, na.rm = TRUE)^2

#C. What is the range of Pulse?
range(nha$Pulse, na.rm = TRUE)

#D. Create a density plot showing BMI, colored and faceted by Education level
nha %>% 
  ggplot(aes(BMI)) +
  geom_density(aes(color = Education)) +
  facet_wrap(aes(Education))

### T-tests ---------
#Assumptions:
  #Random Sampling
  #Independent Samples (violated in paired t-test)
    #e.g. Male/Female
  #Normality (need to assess by plot)
  #Equal variance (need to assess: think, plot)
#Choose appropriate test for comparison (different math)

  ##Looking at difference in height between males and females
# Exploratory data analysis -- density plot of height filled by sex
nha %>% 
  ggplot(aes(Height)) +
  geom_density(aes(fill = Gender), alpha = 0.5)
#assess variance: equal spread to two data sets? Yes, run equal variance t-test

#normality is best assessed using qq plots for each sex
  #qq plot: graph what would be expected if have normal distribution on x-axis versus what you do have on the y-axis (normal if straight line)
nha %>% 
  ggplot(aes(sample = Height)) +
  geom_qq() +
  facet_wrap(aes(Gender))
  
# equal variance, independent samples t-test: determined test to run from above analysis
?t.test #defaults to two-sided, paired, unequal variance
        #Height ~ Gender: height is explained by gender
          #for directionality, negative indicates females shorter than males
t.test(Height ~ Gender, data = nha, var.equal = TRUE)
      
# if we didn't have normality met, run wilcox.test (non-parametric t alternative)
wilcox.test(Height ~ Gender, data = nha)

### ** EXERCISE 2 ** ----------
#   ** YOUR TURN **
# Still using the adults (`nha`) dataset, use a test of 2 means to assess whether single or married/cohabitating people (using the RelationshipStatus variable) drink more alcohol (AlcoholYear). (Please feel free to ask for help)

#A. First, create plot to explore the distribution of the variables and the relationship between these two variables.
nha %>% 
  filter(!is.na(RelationshipStatus)) %>% 
  ggplot(aes(AlcoholYear)) +
  geom_density(aes(color = RelationshipStatus))

#B. Next, consider test assumptions to decide what analysis to run.
nha %>% 
  filter(!is.na(RelationshipStatus)) %>% 
  ggplot(aes(sample = AlcoholYear)) +
  geom_qq() +
  facet_wrap(aes(RelationshipStatus))

#independent samples; equal variance; non-normal distribution -- run wilcox test 
  #(Wilcoxon-Mann-Whitney U)

#C. Run the analysis. Is the association between relationship status and alcohol consumption statistically significant? If so, which group drinks more often?
wilcox.test(AlcoholYear ~ RelationshipStatus, data = nha)
  #appears that committed people drink more, but how much more?
nha %>% 
  group_by(RelationshipStatus) %>% 
  summarize(medAlc = median(AlcoholYear, na.rm = TRUE))
    #same median for all so where is the difference coming from?
nha %>% 
  group_by(RelationshipStatus) %>% 
summarize(medAlc = median(AlcoholYear, na.rm = TRUE), Q1Alc = quantile(AlcoholYear, probs = 0.25, na.rm = TRUE), Q3Alc = quantile(AlcoholYear, probs = 0.75, na.rm = TRUE))
    #picking up on differences in upper tail

### ANOVA and LM ----------
  # ANOVA: diff in 2 or more groups; linear model: effect of predictor variable on response
    #Mathematically are the same: t-test just a specific case of ANOVA and LM

# t-test with equal variance for BMI explained by relationship status -- Matches ANOVA
t.test(BMI ~ RelationshipStatus, data = nha, var.equal = TRUE)

# Same question run in a linear model framework
fit <- lm(BMI ~ RelationshipStatus, data = nha)
fit
summary(fit) #p-value matches from t-test calculation

# same question run as an ANOVA
anova(fit)

### ANOVA with 3 groups ----------

# levels of smoking status
levels(nha$SmokingStatus)

# linear model for the relationship between smoking status and BMI
fit <- lm(BMI ~ SmokingStatus, data = nha)
fit
anova(fit) #shows BMI differs by smoking status; what's different about it?
summary(fit) 
#Current smokers is reference category; increases BMI when switch from Current to Former or Never smokers; doesn't show comparison of Former to Never smokers

#change reference category to Never
nha$SmokingStatus <- factor(nha$SmokingStatus, levels = c("Never", "Former", "Current"))
  #overwrite original SmokingStatus category

# re-create the fit and ANOVA summary
fit <- lm(BMI ~ SmokingStatus, data = nha)
anova(fit)
summary(fit)

# check out Tukey's multiple comparisons; gets around need to change reference category to get all comparisons
TukeyHSD(aov(fit))

# plot results
plot(TukeyHSD(aov(fit)))

# plot results without NA bc ANOVA automatically removed those
nha %>% 
  filter(!is.na(SmokingStatus)) %>% 
  ggplot(aes(SmokingStatus, BMI)) +
  geom_boxplot()

### Linear model with 2 continuous variables -----------
  #Assumptions: most important is normality; should also check equal variance across levels of x

## Create LM fit object for the relationship between height and weight.
fit <- lm(Weight ~ Height, data = nha) #intercept is weight as height=0
summary(fit)

#plot these results
nha %>% 
  ggplot(aes(Height, Weight)) +
  geom_point() +
  geom_smooth(method = "lm")

# check assumptions of LM; plot function gives diagnostics
plot(fit)

### Multiple regression --------
  #What happens as you add variables to your line equation?

#t-test for Testosterone ~ PhysActive; appears that those who are physically active have higher testosterone
t.test(Testosterone ~ PhysActive, data = nha, var.equal = TRUE)

#lm for Testosterone ~ PhysActive; add other parameters to test if something missing from model
fit <- lm(Testosterone ~ PhysActive, data = nha)
summary(fit)

#lm for Testosterone ~ PhysActive + Age
summary(lm(Testosterone ~ PhysActive + Age, data = nha))
  #intercept represents not physically active at age 0
  #controlling for physical activity, age has significant effect on testosterone

#lm for Testosterone ~ PhysActive + Age + Gender
summary(lm(Testosterone ~ PhysActive + Age + Gender, data = nha))
  #intercept represents not physically active age 0 and female
  #overall: gender most important factor in model

### ** EXERCISE 3 ** ----------
#   ** YOUR TURN **
  
#The `Work` variable is coded "Looking" (n=159), "NotWorking" (n=1317), and "Working" (n=2230).

#A. Fit a linear model of `Income` against `Work`. Assign this to an object called `fit`. What does the `fit` object tell you when you display it directly? Those who are NotWorking have lower income than those who are Working
fit <- lm(Income ~ Work, data = nha)  
fit

#B. Run an `anova()` to get the ANOVA table. Is the model significant? Yes, work has a significant impact on income
anova(fit)
  
#C. Run a Tukey test to get the pairwise contrasts. (Hint: `TukeyHSD()` on `aov()` on the fit). What do you conclude? No diff between those NotWorking and those Looking but very significant between Working and either Looking or NotWorking
TukeyHSD(aov(fit))

#D. Instead of thinking of this as ANOVA, think of it as a linear model. After you've thought about it, get some `summary()` statistics on the fit. Do these results jibe with the ANOVA model? 
  #Yes, Looking is used as reference so 
summary(fit)

### DISCRETE VARIABLE ANALYSES -------
### Contingency tables ------
#cross tabulation of Gender and Diabetes

# Add marginal totals

# Get the proportional table

# proportional table over the first (row) margin only.

#chi square for diabetes and gender

# fisher's exact test for diabetes and gender

# relationship between race and health insurance

# plot for categorical data

### Logistic regression --------

#Look at levels of Race. The default ordering is alphabetical

# Let's relevel that where the group with the highest rate of insurance is "baseline"

#mutate to relevel Race with White as reference category

#logistic regression of insurance ~ race

#logistic regression of Insured with lots of predictors

### ** EXERCISE 4 ** -------
#   ** YOUR TURN **

#1. What's the relationship between diabetes and participating in rigorous physical activity or sports?

#A. Create a contingency table with Diabetes status in rows and physical activity status in columns.

#B. Display that table with margins.

#C. Show the proportions of diabetics and nondiabetics, separately, who are physically active or not.
#    - Is this relationship significant?
#    - Create a mosaic plot to visualize the relationship

#2. Model the same association in a logistic regression framework to assess the risk of diabetes using physical activity as a predictor.
#<!-- - First, make Diabetes a factor variable if you haven't already (`nha$Diabetes <- factor(nha$Diabetes)`). -->

#A. Fit a model with just physical activity as a predictor, and display a model summary.

#B. Add gender to the model, and show a summary.

#C. Continue adding weight and age to the model. What happens to the gender association?

#D. Continue and add income to the model. What happens to the original association with physical activity?