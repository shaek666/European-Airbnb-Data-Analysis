# European Airbnb Data Analysis

## 📊 Overview  
Comprehensive analysis of European Airbnb bookings using SQL, examining pricing patterns, guest satisfaction, and booking characteristics across different cities.  

## 🎯 Features  
- City-wise booking analysis  
- Revenue analysis  
- Price outlier detection  
- Guest satisfaction metrics  
- Room type comparisons  
- Weekday vs weekend patterns  
- Location-based insights  
- Statistical correlations  

## 📝 Query Categories  
### Basic Statistics  
- Record counts  
- Unique cities  
- Booking distributions  
- Revenue calculations  

### Price Analysis  
- Statistical measures (min, max, avg)  
- Outlier detection  
- Price variations by room type  
- Weekend vs weekday pricing  

### Satisfaction Analysis  
- Average satisfaction scores  
- City-wise ratings  
- Correlation with other factors  
- Cleanliness impact  

### Location Analysis  
- Distance metrics  
- City center proximity effects  
- Metro accessibility impact  

## 🚀 Getting Started  
### Prerequisites  
- MySQL installed  
- Basic SQL knowledge  
- Access to the Airbnb dataset  

### Setup Instructions  
1. **Clone the repository**:  
   ```bash  
   git clone https://github.com/yourusername/european-airbnb-analysis.git
   
2. **Create database and tables**:
    ```bash  
    psql -U your_username -d your_database -f sql/schema/create_tables.sql 

3.  **Run the analysis queries**:
    ```bash
    psql -U your_username -d your_database -f sql/queries/01_basic_statistics.sql

### 📊 Dataset Structure
    Key Columns
    City: Location of the property

    Price: Booking price

    Day: Weekday/Weekend

    Room_Type: Type of accommodation

    Guest_Satisfaction: Rating score

    Cleanliness_Rating: Cleanliness score

    Metro_Distance_KM: Distance to metro

    City_Center_KM: Distance to city center

### 🤝 Contributing
    1. Fork the repository.
    2. Create your feature branch:
        
        git checkout -b feature/AmazingFeature
    3. Commit your changes:
       
       git commit -m 'Add some AmazingFeature
    4. Push to the branch:
       
       git push origin feature/AmazingFeature

### 📄 License
    This project is licensed under the MIT License - see the LICENSE file for details.

### 🔍 Data Analysis Requirements
    Detailed analysis requirements can be found in analysis_requirements.md.