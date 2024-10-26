Weather App Instructions for Use and Testing
Project Overview
This Flutter weather app allows users to view weather information based on the city they input. Users can select different cities, view weather details, and switch between supported languages.

Setup Instructions
1. System Requirements
Operating System: Windows, macOS, or Linux
Flutter Version: 3.0.0 or higher
Dart SDK: Bundled with Flutter
Additional Dependencies:
http: For making API calls
flutter_localizations: For localization support
flutter_svg: For handling SVG images
cached_network_image: For caching images

2. Install Flutter

3. Clone the Repository
Open your terminal or command prompt and run the following command to clone the project repository:

git clone https://github.com/trietnguyen0902/Midterm_flutter.git

4. Navigate to Project Directory

cd ./Midterm_flutter


5. Install Dependencies
Run the following command to get all the necessary dependencies:

flutter pub get

6. Run the Application
To run the application, use the following command:

flutter run


Testing Specific Features
1. Change City
Input the name of a city in the text field and press "Enter" or click the button to fetch the weather data.
2. Switch Language
Use the dropdown menu to switch between English, French, and Spanish.
3. View Weather Details
After entering a valid city, the app will display the temperature, weather description, humidity, pressure, and current time.
4. Remove City from History
When viewing the list of previously entered cities, click the delete icon next to a city name to remove it from the list.
Additional Notes
Ensure device has internet access to fetch weather data from the API.
