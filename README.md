# Flight Ticket Price Prediction in Indonesia using Tree-Based Models

This repository contains the code and resources for predicting flight ticket prices on Indonesian airlines, specifically for the Jakarta-Surabaya and Jakarta-Manado routes, using tree-based machine learning models.

## Abstract

The Indonesian aviation industry generates a massive amount of data daily, including departure and arrival times, number of transits, and flight days[cite: 261, 262]. This project leverages such publicly available data to predict flight ticket prices. Three machine learning methods — Regression Tree, Bagging Regression Tree, and Random Forest — are employed for price prediction on the Jakarta-Surabaya and Jakarta-Manado routes[cite: 263]. Parameter tuning is performed for each model to achieve optimal performance[cite: 264]. Model evaluation is conducted by comparing Mean Absolute Error (MAE), Mean Absolute Percentage Error (MAPE), Root Mean Squared Error (RMSE), and Coefficient of Determination (R²)[cite: 266]. The results indicate that the Random Forest model achieves the highest accuracy for both routes[cite: 267].

## Background

The abundance of data, often referred to as big data, presents challenges for traditional processing methods, making machine learning (ML) a valuable tool for extracting insights and informing decision-making[cite: 271, 272, 273]. Tree-based models are a category of supervised learning algorithms that discover data structures by partitioning data into subsets using conditional statements[cite: 278, 279]. Examples include Regression Tree, Bagging Regression Tree, and Random Forest[cite: 280]. Unlike classical regression techniques that assume predefined relationships, Regression Tree does not make such assumptions, producing a tree diagram with branches determined by splitting rules and terminal nodes representing the average of response variables[cite: 281, 282, 283].

The Indonesian aviation industry generates substantial daily data[cite: 285]. Given Indonesia's vast archipelago, air transportation is crucial for mobility[cite: 286, 287]. Airlines aim to maximize revenue through revenue management, considering factors like demand and inventory levels when setting ticket prices[cite: 288, 289, 290]. However, this data is not publicly accessible, making it difficult for passengers to predict ticket prices[cite: 291]. This research addresses this by using publicly available flight data, such as arrival times, departure times, number of transits, and flight days, as predictive factors[cite: 292, 293]. The chosen tree-based models — Regression Tree, Bagging Regression Tree, and Random Forest — are compared for accuracy to identify the best model[cite: 294, 295]. The Jakarta-Surabaya and Jakarta-Manado domestic routes, with 20-30 daily flights, are used for model development[cite: 296, 297].

## Methods

### Data Collection

Flight data for this study was collected from tiket.com, an Indonesian flight booking website, spanning from June 9, 2022, to August 31, 2022[cite: 401, 402]. The routes observed are Jakarta-Surabaya (CGK-SUB) and Jakarta-Manado (CGK-MDC)[cite: 402]. Data was collected daily using the Web Scraper browser extension[cite: 403]. Missing values resulting from the scraping process were excluded from the analysis[cite: 405].

The dependent variable is 'price' (flight ticket price)[cite: 406]. The independent variables include:
* 'airline'
* 'departure'
* 'arrival'
* 'transit'
* 'day_of_week'
* 'holiday'
* 'days_left_until_departure'
* 'duration'
* 'scrape_day'
* 'scrape_holiday' [cite: 407]

### Data Analysis

Simple data analysis involved visualizing flight ticket prices against each predictor variable using line graphs generated from pivot tables[cite: 409, 410].

Data statistics after cleaning:
* **Jakarta-Surabaya Route**: 101,397 clean data points (out of 103,286 total, with 1,889 missing values)[cite: 434].
    * **Airline**: Nam Air had the highest average ticket price, while Super Air Jet had the lowest[cite: 439].
    * **Departure/Arrival Times**: No single peak price time for all airlines due to variations[cite: 440, 441].
    * **Number of Transits**: Flights with one transit were more expensive than direct flights[cite: 442].
    * **Day of Flight**: Prices tended to be higher on Fridays[cite: 443].
    * **Holiday**: Prices tended to be higher on holidays[cite: 443].
    * **Days Left Until Departure**: Prices increased closer to the departure date for all airlines[cite: 444].
    * **Flight Duration**: For most airlines, longer durations correlated with higher average prices[cite: 445].
    * **Scrape Day (Purchase Day)**: Prices tended to be cheaper when purchased on Thursdays[cite: 447].
    * **Scrape Holiday (Purchase Holiday)**: Prices tended to be more expensive when purchased on holidays[cite: 448].
* **Jakarta-Manado Route**: 54,497 clean data points (out of 63,146 total, with 8,649 missing values)[cite: 435].
    * **Airline**: Batik Air had the highest average ticket price, while Citilink had the lowest[cite: 450].
    * **Departure Time**: No single peak price time for all airlines[cite: 451].
    * **Arrival Time**: Prices tended to be higher for flights arriving between 13:00-15:59[cite: 452].
    * **Number of Transits**: Higher number of transits correlated with higher ticket prices[cite: 453].
    * **Day of Flight**: Prices tended to be higher on Saturdays[cite: 454].
    * **Holiday**: Prices tended to be higher on non-holidays[cite: 455].
    * **Days Left Until Departure**: Prices increased closer to the departure date for all airlines[cite: 456].
    * **Flight Duration**: For most airlines, longer durations correlated with higher average prices[cite: 457].
    * **Scrape Day (Purchase Day)**: Prices tended to be cheaper when purchased on Thursdays[cite: 458].
    * **Scrape Holiday (Purchase Holiday)**: Prices tended to be more expensive when purchased on holidays[cite: 459].

### Data Splitting

The collected data was divided into an 80% training set and a 20% test set, with random selection[cite: 412]. The models were trained on the training data and evaluated on the test data[cite: 413].

### Prediction Model Development

Three prediction models — Regression Tree, Bagging Regression Tree, and Random Forest — were built using the training data[cite: 414]. The `rpart` package was used for Regression Tree, and the `caret` package for Bagging Regression Tree and Random Forest in R[cite: 415]. Optimal model parameters were determined using k-fold cross-validation[cite: 418].

### Prediction and Evaluation

The optimal Regression Tree, Bagging Regression Tree, and Random Forest models were used to predict flight ticket prices for the 20% test data[cite: 419]. Each model produced an estimated ticket price for each flight[cite: 421].

Model performance was evaluated by calculating the error between actual and predicted prices using MAE, RMSE, and MAPE, and by assessing goodness-of-fit using the coefficient of determination (R²)[cite: 424, 425]. The best model was determined by the lowest MAE, RMSE, and MAPE values, and the highest R²[cite: 426, 427].

## Results and Discussion

### Model Performance for Jakarta-Surabaya Route

| Model                 | MAE         | MAPE   | RMSE        | R²      |
| :-------------------- | :---------- | :----- | :---------- | :------ |
| Regression Tree       | 129,764.2   | 12.04% | 162,198.0   | 64.99%  |
| Bagging Regression Tree | 130,626.7   | 12.36% | 160,892.8   | 65.56%  |
| Random Forest         | 120,257.0   | 11.23% | 150,536.2   | 69.87%  |

The Random Forest model had the lowest MAE, MAPE, and RMSE, and the highest R², making it the best model for the Jakarta-Surabaya route[cite: 475, 476]. While Regression Tree and Bagging Regression Tree were not significantly different, Regression Tree showed better MAE and MAPE, whereas Bagging Regression Tree performed better in terms of RMSE and R²[cite: 477]. This suggests that Regression Tree tended to produce larger errors compared to Bagging Regression Tree, as RMSE penalizes larger errors more heavily[cite: 478].

For the Regression Tree model for Jakarta-Surabaya, the optimal parameters were `minsplit=20` and `maxdepth=14`[cite: 460]. It utilized 'airline', 'duration', 'transit', and 'days_left_until_departure' as predictors[cite: 461]. The initial split was based on 'airline', indicating its importance in reducing SSE[cite: 462]. The optimal Bagging Regression Tree model had `nbagg=23`[cite: 468]. 'duration' was the most impactful predictor on SSE, followed by 'days_left_until_departure' and 'arrival'[cite: 470, 471]. The optimal Random Forest model had `mtry=18`, `ntree=1000`, and `maxnodes=50`[cite: 472].

### Model Performance for Jakarta-Manado Route

| Model                 | MAE         | MAPE   | RMSE        | R²      |
| :-------------------- | :---------- | :----- | :---------- | :------ |
| Regression Tree       | 248,163.6   | 8.14%  | 322,838.7   | 81.01%  |
| Bagging Regression Tree | 247,941.0   | 8.13%  | 322,254.0   | 81.08%  |
| Random Forest         | 209,333.0   | 6.85%  | 279,537.7   | 86.04%  |

Similar to the Jakarta-Surabaya route, the Random Forest model achieved the lowest MAE, MAPE, and RMSE, and the highest R², making it the best model for the Jakarta-Manado route[cite: 494, 495]. Regression Tree and Bagging Regression Tree did not differ significantly, with Regression Tree performing slightly better across all metrics[cite: 496].

For the Regression Tree model for Jakarta-Manado, the optimal parameters were `minsplit=17` and `maxdepth=13`[cite: 479]. It used 'transit', 'duration', 'arrival', 'days_left_until_departure', 'airline', and 'departure' as predictors[cite: 480]. The initial split was based on 'transit'[cite: 481]. The optimal Bagging Regression Tree model had `nbagg=25`[cite: 487]. 'duration' was the most impactful predictor on SSE, followed by 'departure' and 'arrival'[cite: 489, 490]. The optimal Random Forest model had `mtry=11`, `ntree=1000`, and `maxnodes=50`[cite: 491].

## Web Application

A web application named "Prediksi Harga Tiket Pesawat" (Flight Ticket Price Prediction) was developed using R Shiny[cite: 497]. The application features a navigation bar to switch between "Jakarta-Surabaya" and "Jakarta-Manado" pages[cite: 498]. Each page includes a sidebar for inputting parameters like airline, departure/arrival times, transit, etc., and a main panel displaying the application status and predicted ticket prices from all three models[cite: 499, 500, 501, 502].

## Conclusion

This research successfully predicted flight ticket prices for Indonesian airlines on the Jakarta-Surabaya and Jakarta-Manado routes using Regression Tree, Bagging Regression Tree, and Random Forest models[cite: 504]. Model evaluation was based on MAE, MAPE, RMSE, and R²[cite: 505]. The prediction results for both routes were sufficiently accurate, with MAPE values below 20%[cite: 507]. The Random Forest model consistently demonstrated the lowest prediction error, making it the best predictive model for both routes[cite: 507, 508].
