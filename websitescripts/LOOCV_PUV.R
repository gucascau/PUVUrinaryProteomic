# ---- Libraries ----
library(shiny)
library(ggplot2)
library(dplyr)
library(pROC)
library(boot) # for cv.glm

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
  Age = c(7.3,15.3,7.6,7.6,5.8,4.7,11.9,5.9,9.8,3.4,2.8,10.4,5.9,11.6,6.2,6.4,6.4,13.3,4.8,
          16.1,7.2,14.7,7.4,7.9,6.1,5.1,11.5,6.3,10.1,2.5,2,10.6,6.3,10.9,6.4,7.1,6.5,13.1,
          5.9,1.8),
  Group = c(rep("control",20), rep("case",20))
)

data <- data %>%
  mutate(GroupBin = ifelse(Group == "case", 1, 0))

# ---- Train/Test split ----
set.seed(123)
train_idx <- sample(seq_len(nrow(data)), size = 0.8 * nrow(data))
train_data <- data[train_idx, ]
test_data  <- data[-train_idx, ]

# ---- Logistic regression model on training set ----
model <- glm(GroupBin ~ uClusterin_Cr + uEGF_Cr + uAPOA4_Cr + Age,
             data = train_data, family = binomial)

# ---- LOOCV on training set ----
loocv <- cv.glm(train_data, model, K = nrow(train_data))
cat("LOOCV estimated prediction error (MSE):", loocv$delta[1], "\n")

# ---- Predict on test set ----
test_probs <- predict(model, newdata = test_data, type = "response")
roc_test <- roc(test_data$GroupBin, test_probs)
cat("Test set AUC:", auc(roc_test), "\n")

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
        tabPanel("Posterior Urethral Valves Prediction",
                 h4("Predicted Probability of PUV Case:"),
                 verbatimTextOutput("prediction"),
                 plotOutput("riskPlot")
        ),
        tabPanel("Model Performance",
                 h4("ROC Curve (Test Set)"),
                 plotOutput("rocCurve")
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
      paste0(round(prob*100, 1), "% probability of being a PUV case")
    })
    
    output$riskPlot <- renderPlot({
      ggplot(data.frame(prob=prob), aes(x="", y=prob)) +
        geom_bar(stat="identity", fill=ifelse(prob>0.5,"red","green")) +
        coord_flip() + ylim(0,1) +
        labs(title="Risk Prediction", y="Probability", x="") +
        theme_minimal()
    })
  })
  
  output$rocCurve <- renderPlot({
    plot(roc_test, col="blue", lwd=2, main=paste0("ROC Curve for Test Set (AUC=", round(auc(roc_test),3), ")"))
  })
}

shinyApp(ui=ui, server=server)
