

##########################################################
#  title: "Design the website for the obstructive uropathy"
# author: "Xin Wang"
# date: "2025-08-08"
# email: xin.wang@nationwidechildrens.org
# output: html_document
# Description:

##########################################################

####### Install R packages automatically #########
# Here we used the 
#source("install_R_packages.R")
library(shiny)
library(ggplot2)
library(dplyr)
library(pROC)


# ---- Load & prepare data ----
data <- data.frame(
  Sample = c("30 (NURAG)", "35 (NURAG)", "NURAG78", "C170", "C3", "NURAG77", "NURAG75", "C8", 
             "57 (NURAG)", "17 (NURAG)", "AAPU 19", "C150", "C179", "20 (NURAG)", "C178", "NURAG76", 
             "C157", "NURAG44", "32 (NURAG)", "NURAG45", "2 (NURAG)", "7 (NURAG)", "37 (NURAG)", 
             "40 (NURAG)", "41 (NURAG)", "NURAG48", "NURAG49", "NURAG51", "NURAG62", "NURAG63", 
             "NURAG64", "NURAG73", "NURAG86", "NURAG88", "NURAG89", "NURAG90", "NURAG91", "NURAG94", 
             "UO118", "58 (NURAG)"),
  uClusterin_Cr = c(121.364,82.685,200.546,325.135,108.197,390.897,132.655,189.927,114.485,
                    457.213,274.225,249.293,434.871,87.834,277.06,48.271,364.39,166.348,
                    389.446,131.315,178.35,200.552,23.939,217.994,111.469,164.51,149.17,
                    399.119,114.413,57.907,97.322,93.152,96.336,29.425,50.379,56.714,72.468,
                    33.173,210.968,502.292),
  uEGF_Cr = c(46464.853,22837.848,42027.258,55791.244,80700.781,110468.001,62231.213,20360.925,
              47163.069,65382.75,118727.056,48319.711,112453.979,36044.961,63002.541,5720.671,
              103865.832,57021.707,69859.164,38011.433,7642.765,5235.332,28530.055,63730.535,
              10444.334,53121.961,20112.749,11605.791,9608.434,25614.924,11408.199,12733.607,
              18290.14,11705.26,21749.189,22602.613,23936.659,17669.449,37666.155,17774.704),
  uAPOA4_Cr = c(3.728,1.287,5.87,12.22,3.137,2.525,5.144,22.111,2.551,3.687,10.277,16.802,
                4.261,5.667,3.538,3.686,13.045,2.799,3.495,3.352,14.706,266.378,31.765,10.583,
                7.861,5.752,24.973,76.624,43.484,14.089,46.55,165.567,11.141,11.552,24.115,
                6.894,31.425,3.835,10.02,369.187),
  uB2M_Cr = c(0.649,0.425,1.43,0.602,0.833,0.37,0.951,0.835,0.029,0.766,0.917,1.333,0.135,0.524,
              0.318,0.74,2.657,0.629,0.758,1.351,3.451,1.96,1.552,0.121,0.097,1.06,1.834,18.37,
              1.437,0.343,3.272,3.317,0.208,0.158,NA,NA,3.91,0.051,0.767,4.816),
  Age = c(7.3,15.3,7.6,7.6,5.8,4.7,11.9,5.9,9.8,3.4,2.8,10.4,5.9,11.6,6.2,6.4,6.4,13.3,4.8,
          16.1,7.2,14.7,7.4,7.9,6.1,5.1,11.5,6.3,10.1,2.5,2,10.6,6.3,10.9,6.4,7.1,6.5,13.1,
          5.9,1.8),
  GroupBin = c(rep(0,20), rep(1,20)),
  Group = c(rep("control",20), rep("case",20))
)

data <- data %>%
  dplyr::filter(Age != "no value" & uClusterin_Cr != "no value" &
           uEGF_Cr != "no value" & uAPOA4_Cr != "no value")

data$uClusterin_Cr <- as.numeric(data$uClusterin_Cr)
data$uEGF_Cr <- as.numeric(data$uEGF_Cr)
data$uAPOA4_Cr <- as.numeric(data$uAPOA4_Cr)
data$Age <- as.numeric(data$Age)
data$GroupBin <- ifelse(data$Group == "case", 1, 0)

# ---- Logistic regression model ----
model <- glm(GroupBin ~ uClusterin_Cr + uEGF_Cr + uAPOA4_Cr + Age,
             data = data, family = binomial)

# ROC curve
pred_probs <- predict(model, type = "response")
roc_obj <- roc(data$GroupBin, pred_probs)
auc_value <- auc(roc_obj)
print(auc_value)
coords(roc_obj, "best", ret = c("threshold", "sensitivity", "specificity"), best.method = "youden")
# 
# # # ---- Train/Test Split ----
# set.seed(123)  # for reproducibility
# train_idx <- sample(seq_len(nrow(data)), size = 0.8 * nrow(data))
# train_data <- data[train_idx, ]
# test_data  <- data[-train_idx, ]
# 
# # ---- Logistic regression model (fit only on training data) ----
# model <- glm(GroupBin ~ uClusterin_Cr + uEGF_Cr + uAPOA4_Cr + Age,
#              data = train_data, family = binomial)
# 
# # ---- ROC curve (use test data for evaluation) ----
# test_probs <- predict(model, newdata = test_data, type = "response")
# roc_obj <- roc(test_data$GroupBin, test_probs)

#If you want to try k-fold cross-validation in R, here’s a simple example with cvAUC:
#install.packages("cvTools")
# library(cvAUC)
# library(cvTools)
# 
# set.seed(123)
# 
# library(cvAUC)
# library(cvTools)
# 
# set.seed(123)
# 
# # Prepare predictors and outcome
# X <- as.matrix(data[, c("uClusterin_Cr", "uEGF_Cr", "uAPOA4_Cr", "Age")])
# y <- data$GroupBin
# 
# # Create 5-fold CV splits
# folds <- cvFolds(n = nrow(X), K = 5)
# 
# # Store out-of-fold predictions
# preds <- rep(NA, nrow(X))
# 
# for (k in 1:5) {
#   train_idx <- folds$subsets[folds$which != k]
#   test_idx  <- folds$subsets[folds$which == k]
#   
#   # Logistic regression on training fold
#   model <- glm(y[train_idx] ~ X[train_idx, ], family = binomial)
#   
#   # Predict on held-out fold
#   preds[test_idx] <- predict(model,
#                              newdata = data.frame(X = X[test_idx, ]),
#                              type = "response")
# }
# 
# # Ensure labels are a factor with levels 0 and 1
# y <- factor(ifelse(data$Group == "case", 1, 0), levels = c(0,1))
# 
# # Compute cross-validated AUC
# cv_auc <- cvAUC(preds, y, folds$which)
# 
# # Mean AUC
# print(cv_auc$cvAUC)
# 
# # Confidence intervals
# ci <- ci.cvAUC(preds, y, folds$which)
# print(ci)


# ---- SHINY APP ----
ui <- fluidPage(
  titlePanel("PUV Patient Prediction"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Input Patient Biomarkers"),
      numericInput("uClusterin", "Clusterin (uClusterin/uCreatinine):", value = 50),
      numericInput("uEGF", "EGF (uEGF/uCreatinine):", value = 12000),
      numericInput("uAPOA4", "APOA4 (uAPOA4/uCreatinine):", value = 5),
      numericInput("Age", "Age (years):", value = 6),
      actionButton("predictBtn", "Predict")
    ),
    
    mainPanel(
      tabsetPanel(
        # Combined PUV background + Prediction
        tabPanel("Posterior Urethral Valves Prediction",
                 h3("Posterior Urethral Valves (PUV)"),
                 p("PUV is a serious congenital condition that occurs only in boys, where abnormal 
                    flaps of tissue form in the urethra (the tube that carries urine out of the body). 
                    These extra flaps partially or completely block the flow of urine from the bladder."),
                 p("Because of this obstruction:"),
                 tags$ul(
                   tags$li("The bladder has to work harder, often becoming thickened and dysfunctional."),
                   tags$li("The kidneys may experience back pressure, leading to swelling (hydronephrosis), 
                           scarring, and in severe cases, chronic kidney disease (CKD) or end-stage kidney disease (ESKD)."),
                   tags$li("The urinary tract is more prone to infections, which can further worsen kidney damage.")
                 ),
                 p("PUV is usually diagnosed in infancy or early childhood, sometimes even before birth 
                    through prenatal ultrasound. Treatment typically involves a surgical procedure 
                    (valve ablation) to remove the obstructing tissue, but long-term monitoring is essential 
                    because many boys remain at risk of bladder dysfunction and progressive kidney damage."),
                 p("Traditional monitoring relies on imaging and kidney function tests, but these may not 
                    detect early damage. Urinary biomarkers such as Clusterin, EGF, and APOA4 offer a promising 
                    way to predict which patients are most at risk, allowing earlier intervention and closer follow-up."),
                 br(),
                 #h4("Educational Figure:"),
                 tags$img(src = "PUV.jpg", 
                          width = "50%", height = "auto"),
                 br(), br(),
                 h4("Predicted Probability of Renal Risk in PUV:"),
                 verbatimTextOutput("prediction"),
                 plotOutput("riskPlot"),
                 br(),
                 
        ),
        
        # Biomarker comparisons
        tabPanel("Model Details",
                 h4("Model Performance"),
                 h3("Predicted probabilities from this model were used to generate a multi-biomarker ROC curve:"),
                 plotOutput("rocCurve"),
                 h3("Biomarker Levels in Controls vs PUV Patients"),
                 plotOutput("boxplotClusterin"),
                 plotOutput("boxplotEGF"),
                 plotOutput("boxplotAPOA4")
        )
      )
    )
  )
)

server <- function(input, output) {
  
  observeEvent(input$predictBtn, {
    new_sample <- data.frame(
      uClusterin_Cr = input$uClusterin,
      uEGF_Cr = input$uEGF,
      uAPOA4_Cr = input$uAPOA4,
      Age = input$Age
    )
    
    prob <- predict(model, newdata = new_sample, type = "response")
    output$prediction <- renderText({
      paste0(round(prob * 100, 1), "% probability of being a PUV case")
    })
    
    output$riskPlot <- renderPlot({
      ggplot(data.frame(prob = prob), aes(x = "", y = prob)) +
        geom_bar(stat = "identity", fill = ifelse(prob > 0.5, "red", "green")) +
        coord_flip() +
        ylim(0, 1) +
        labs(title = "Risk Prediction", y = "Probability", x = "") +
        theme_minimal()
    })
  })
  
  # ROC curve
  output$rocCurve <- renderPlot({
    plot(roc_obj, col = "blue", lwd = 2, main = "ROC Curve for Model")
    legend("bottomright", legend = paste0("AUC=", round(auc(roc_obj), 3)),
           col = "blue", lwd = 2)
  })
  
  # Biomarker boxplots
  output$boxplotClusterin <- renderPlot({
    ggplot(data, aes(x = Group, y = uClusterin_Cr, fill = Group)) +
      geom_boxplot() +
      labs(title = "Clusterin levels", y = "uClusterin_Cr") +
      theme_minimal()
  })
  
  output$boxplotEGF <- renderPlot({
    ggplot(data, aes(x = Group, y = uEGF_Cr, fill = Group)) +
      geom_boxplot() +
      labs(title = "EGF levels", y = "uEGF_Cr") +
      theme_minimal()
  })
  
  output$boxplotAPOA4 <- renderPlot({
    ggplot(data, aes(x = Group, y = uAPOA4_Cr, fill = Group)) +
      geom_boxplot() +
      labs(title = "APOA4 levels", y = "uAPOA4_Cr") +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)
