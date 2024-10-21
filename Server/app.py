import os
import json
import pickle
from flask import Flask, request, jsonify
import pandas as pd

# Initialize Flask app
app = Flask(__name__)

# Load the machine learning model (random_forest_model.pkl)
model = pickle.load(open('random_forest_model.pkl', 'rb'))

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

        return jsonify({"message": "Raw data processed and saved successfully."}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Check if the script is executed directly
if __name__ == '__main__':
    # Start the Flask app and make it listen on all network interfaces (0.0.0.0)
    app.run(debug=True, host='0.0.0.0', port=5000)
