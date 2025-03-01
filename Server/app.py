import os
import json
import pickle
from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
import requests
from flask_cors import CORS
import google.generativeai as genai

# Load environment variables for sensitive data
# from dotenv import load_dotenv
# load_dotenv()

# Replace with your actual Gemini API key from environment variables
GEMINI_API_KEY = "GEMINI_API_KEY"
# if not GEMINI_API_KEY:
    # raise ValueError("No Gemini API key found. Please set the GEMINI_API_KEY environment variable.")

genai.configure(api_key=GEMINI_API_KEY)

# Initialize Flask app
app = Flask(__name__)

# Load the machine learning model (random_forest_model.pkl)
try:
    model = pickle.load(open('random_forest_model.pkl', 'rb'))
except Exception as e:
    print(f"Error loading the model: {e}")
    model = None

# Create a directory to store the received data
DATA_DIR = 'data'
if not os.path.exists(DATA_DIR):
    os.makedirs(DATA_DIR)

@app.route('/trial', methods=['GET'])
def nun():
    return "it's working"

# Define a route to handle incoming prediction requests
@app.route('/predict', methods=['POST'])
def predict():
    print("Received request with data:", request.get_json())
    try:
        # Get the raw JSON data from the POST request
        data = request.get_json()
        
        # Print the received data for debugging
        print("Received data:", data)

        # Extract the array of values (assuming the data is a list in JSON format)
        input_data = data.get('input')

        # Ensure the input is in the correct format (list/array)
        if not isinstance(input_data, list) or len(input_data) != 6:
            return jsonify({"error": "Invalid input data. Expecting a list of 6 numerical values."}), 400

        # Convert input to a numpy array and reshape it for the model
        input_array = np.array(input_data).reshape(1, -1)

        # Use the loaded model to make a prediction
        if model is None:
            return jsonify({"error": "Model not loaded. Please check the server logs."}), 500

        prediction = model.predict(input_array)

        # Return the prediction as a JSON response
        return jsonify({"prediction": prediction[0]})

    except Exception as e:
        # If something goes wrong, return an error message
        return jsonify({"error": str(e)}), 500

# Define a route to handle incoming raw data
@app.route('/raw-data', methods=['POST'])
def handle_raw_data():
    try:
        # Get the raw data from the POST request
        raw_data = request.get_json()
        print("Received raw data:", raw_data)

        # Ensure the raw data is in a list format
        if not isinstance(raw_data, list):
            return jsonify({"error": "Invalid raw data format. Expecting a list."}), 400

        # Prepare a list to hold the processed data
        processed_data = []

        # Process each entry in the raw data
        for entry in raw_data:
            # Check for the required fields
            if 'startTime' in entry and 'endTime' in entry and 'type' in entry:
                # Check for extra keys beyond type, startTime, and endTime
                extra_keys = set(entry.keys()) - {'type', 'startTime', 'endTime'}

                # Only include entries that have extra values
                if extra_keys:
                    # Extract the required fields
                    type_value = entry['type']
                    start_time = entry['startTime']
                    end_time = entry['endTime']

                    # Prepare the base entry with the last extra value as 'value'
                    base_entry = {
                        'type': type_value,
                        'startTime': start_time,
                        'endTime': end_time,
                        'value': entry[list(extra_keys)[-1]]  # Use the last additional value as 'value'
                    }

                    # Append the base entry to the processed data
                    processed_data.append(base_entry)

        # Convert processed data to a DataFrame
        df = pd.DataFrame(processed_data)

        # Generate a filename based on the current timestamp
        timestamp = pd.Timestamp.now().strftime('%Y%m%d_%H%M%S')
        filename = os.path.join(DATA_DIR, f"raw_data_{timestamp}.csv")

        # Save the DataFrame to CSV, ensuring no duplicate columns
        df.to_csv(filename, index=False)
        print(f"Filtered raw data saved to {filename}")

        # Optionally save as JSON
        json_filename = os.path.join(DATA_DIR, f"raw_data_{timestamp}.json")
        df.to_json(json_filename, orient='records', lines=True)
        print(f"Filtered raw data saved to {json_filename}")

        # Extract the latest heart rate value
        heart_rate_data = df[df['type'] == 'HeartRate']

        if not heart_rate_data.empty:
            # Get the latest entry for HeartRate
            latest_heart_rate_entry = heart_rate_data.iloc[-1]
            beats_per_minute = latest_heart_rate_entry['value'][0]['beatsPerMinute']

            # Prepare input for the model
            # Assuming static values: [75, heartRate, 5.5, 0.8, 3, 1]
            model_input = [75, beats_per_minute, 5.5, 0.8, 3, 1]

            # Make prediction
            input_array = np.array(model_input).reshape(1, -1)
            prediction = model.predict(input_array)

            # Convert prediction to a standard Python type (int or float)
            prediction_value = int(prediction[0])  # Assuming your model outputs a single value

            return jsonify({"message": "Raw data processed and saved successfully.", "prediction": prediction_value, "heartrate": beats_per_minute}), 200

        else:
            return jsonify({"message": "No heart rate data found."}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500
 
@app.route('/chat', methods=['POST'])
def chat():
    try:
        # Parse incoming request data
        data = request.get_json()
        user_message = data.get('message')

        # Check if the user message exists
        if not user_message:
            return jsonify({"error": "No message provided."}), 400

        # Define the template for chatbot context
        template_message = (
            "You are an intelligent chatbot integrated into a stress-level detection and "
            "recommendation app. Your role is to help users understand their stress levels, "
            "provide tips to manage stress, and answer questions about stress-related topics. "
            "Please ensure your responses are concise, empathetic, and actionable. "
            "Keep in mind that the app's purpose is to assist users in managing their stress."
        )

        # Create a generative model instance
        model = genai.GenerativeModel(model_name="gemini-1.5-flash")

        # Generate a response using the Gemini API
        response = model.generate_content(f"{template_message}\n\nUser: {user_message}")
        
        # Return the response text
        return jsonify({"reply": response.text})

    except Exception as e:
        # Log the error message for debugging
        print(f"Error occurred: {str(e)}")
        return jsonify({"error": str(e)}), 500


# Check if the script is executed directly
if __name__ == '__main__':
    CORS(app)  # Enable CORS for all routes
    # Start the Flask app and make it listen on all network interfaces (0.0.0.0)
    app.run(debug=False, host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))