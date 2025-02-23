European Airbnb Data Analysis
📊 Overview
Comprehensive analysis of European Airbnb bookings using SQL, examining pricing patterns, guest satisfaction, and booking characteristics across different cities.
🎯 Features

City-wise booking analysis
Revenue analysis
Price outlier detection
Guest satisfaction metrics
Room type comparisons
Weekday vs weekend patterns
Location-based insights
Statistical correlations

📁 Repository Structure
Copy├── sql/
│   ├── queries/
│   │   ├── 01_basic_statistics.sql
│   │   ├── 02_price_analysis.sql
│   │   ├── 03_satisfaction_analysis.sql
│   │   ├── 04_location_analysis.sql
│   │   └── 05_correlation_studies.sql
│   └── schema/
│       └── create_tables.sql
├── data/
│   └── data_dictionary.md
├── docs/
│   ├── analysis_requirements.md
│   └── methodology.md
├── results/
│   └── findings.md
├── LICENSE
└── README.md
📝 Query Categories
Basic Statistics

Record counts
Unique cities
Booking distributions
Revenue calculations

Price Analysis

Statistical measures (min, max, avg)
Outlier detection
Price variations by room type
Weekend vs weekday pricing

Satisfaction Analysis

Average satisfaction scores
City-wise ratings
Correlation with other factors
Cleanliness impact

Location Analysis

Distance metrics
City center proximity effects
Metro accessibility impact

🚀 Getting Started
Prerequisites

PostgreSQL 12+ installed
Basic SQL knowledge
Access to the Airbnb dataset

Setup Instructions

Clone the repository:

bashCopygit clone https://github.com/yourusername/european-airbnb-analysis.git

Create database and tables:

bashCopypsql -U your_username -d your_database -f sql/schema/create_tables.sql

Run the analysis queries:

bashCopypsql -U your_username -d your_database -f sql/queries/01_basic_statistics.sql
📊 Dataset Structure
Key Columns

City: Location of the property
Price: Booking price
Day: Weekday/Weekend
Room_Type: Type of accommodation
Guest_Satisfaction: Rating score
Cleanliness_Rating: Cleanliness score
Metro_Distance_KM: Distance to metro
City_Center_KM: Distance to city center

🤝 Contributing

Fork the repository
Create your feature branch (git checkout -b feature/AmazingFeature)
Commit your changes (git commit -m 'Add some AmazingFeature')
Push to the branch (git push origin feature/AmazingFeature)
Open a Pull Request

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
🔍 Data Analysis Requirements
Detailed analysis requirements can be found in docs/analysis_requirements.md.
📊 Key Findings
Analysis results and insights can be found in results/findings.md.