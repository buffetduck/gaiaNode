#!/bin/bash

# Function to handle the API request
send_request() {
    local message="$1"
    local api_key="$2"
    local api_url="$3"

    while true; do
        # Prepare the JSON payload
        json_data=$(cat <<EOF
{
    "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "$message"}
    ]
}
EOF
        )

        # Send the request using curl and capture both the response and status code
        response=$(curl -s -w "\n%{http_code}" -X POST "$api_url" \
            -H "Authorization: Bearer $api_key" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -d "$json_data")

        # Extract the HTTP status code from the response
        http_status=$(echo "$response" | tail -n 1)
        body=$(echo "$response" | head -n -1)

        if [[ "$http_status" -eq 200 ]]; then
            # Check if the response is valid JSON
            echo "$body" | jq . > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                # Print the question and response content
                echo "✅ [SUCCESS] API: $api_url | Message: '$message'"

                # Extract the response message from the JSON
                response_message=$(echo "$body" | jq -r '.choices[0].message.content')
                
                # Print both the question and the response
                echo "Question: $message"
                echo "Response: $response_message"
                break  # Exit loop if request was successful
            else
                echo "⚠️ [ERROR] Invalid JSON response! API: $api_url"
                echo "Response Text: $body"
            fi
        else
            echo "⚠️ [ERROR] API: $api_url | Status: $http_status | Retrying in 2s..."
            sleep 2
        fi
    done
}

# Define a list of predefined messages
user_messages=(
         "Explain the water cycle and its main stages."
        "Describe the process of photosynthesis and why it is important for plants."
        "How does a lunar eclipse occur, and what are its different types?"
        "What are the three main types of rock, and how do they form?"
        "Describe the life cycle of a butterfly from egg to adult."
        "How does the human digestive system work?"
        "Explain how airplanes are able to fly using the principles of aerodynamics."
        "What are the major causes and effects of global warming?"
        "Describe the process of how rain is formed in the atmosphere."
        "What are the main functions of the skeletal system in the human body?"
        "How does the greenhouse effect contribute to climate change?"
        "Explain how a volcano erupts and what happens during an eruption."
        "What is the difference between renewable and nonrenewable energy sources?"
        "Describe how a rainbow is formed and why it displays different colors."
        "What are the main differences between plant and animal cells?"
        "Explain how earthquakes occur and how they are measured."
        "Describe the difference between a solar and a lunar eclipse."
        "How does the water in a river eventually reach the ocean?"
        "What are the primary reasons for deforestation, and what impact does it have?"
        "Explain the differences between solids, liquids, and gases."
        "Describe how the food chain works and its different levels."
        "How do magnets work, and what are their main properties?"
        "Explain how sound travels and why it needs a medium."
        "What are the main layers of Earth's atmosphere, and what are their characteristics?"
        "Describe the causes and effects of acid rain."
        "How does the circulatory system transport blood throughout the body?"
        "Explain why the sky appears blue during the day and red during sunset."
        "What are the key differences between a democracy and a dictatorship?"
        "Describe how tides are influenced by the moon and the sun."
        "How do bees help with pollination, and why is it important for agriculture?"
        "What are the main characteristics of mammals?"
        "Explain how ocean currents work and their effect on global climate."
        "What is the difference between a virus and bacteria, and how do they affect health?"
        "How do plants absorb water and nutrients from the soil?"
        "Describe the process of making paper from trees."
        "Explain how the human brain processes information and controls the body."
        "What are the major causes of air pollution, and what can be done to reduce it?"
        "How do fish breathe underwater, and what adaptations help them survive?"
        "Describe the life cycle of a star from birth to death."
        "How does a refrigerator keep food cold?"
        "Explain the process of making glass from raw materials."
        "What are the advantages and disadvantages of nuclear energy?"
        "How does a computer store and process information?"
        "Describe how fingerprints are unique and how they are used in forensic science."
        "How do submarines dive and resurface?"
        "What are the main differences between a comet, an asteroid, and a meteor?"
        "Explain how photos and videos are displayed on a screen."
        "How does the immune system protect the body from diseases?"
        "Describe how a camera captures an image."
        "How do electric cars work, and what makes them different from gasoline-powered cars?"
        "Explain the importance of the ozone layer and what is being done to protect it."
        "How does a compass work, and why does it always point north?"
        "What are the primary ingredients in soap, and how does it remove dirt?"
        "Describe how a microwave oven heats food."
        "How does the stock market work, and why do stock prices change?"
        "Explain how earthquakes can cause tsunamis."
        "How do vaccines work to prevent diseases?"
        "Describe the process of making cheese from milk."
        "How does a parachute slow down a person’s fall?"
        "Explain the concept of artificial intelligence and how it is used today."
        "How do airplanes generate lift to stay in the air?"
        "What are the different types of renewable energy, and how do they work?"
        "Describe the main differences between herbivores, carnivores, and omnivores."
        "How do clouds form, and why do they look different from each other?"
        "Explain how a magnet attracts or repels objects."
        "What are the main functions of the liver in the human body?"
        "How does a hot air balloon rise and descend?"
        "Describe the structure of DNA and its role in genetics."
        "How do touchscreens on smartphones detect a person’s touch?"
        "Explain how a roller coaster works using the laws of physics."
        "How do solar panels generate electricity from sunlight?"
        "Describe how bats use echolocation to navigate and find food."
        "What is the difference between artificial and natural satellites?"
        "Explain how musical instruments produce sound."
        "How do airplanes communicate with air traffic control?"
        "Describe how the banking system works and why banks are important."
        "How does the body heal a wound after an injury?"
        "Explain how submarines stay underwater for long periods of time."
        "How does a thermometer measure temperature?"
        "Describe the differences between freshwater and saltwater ecosystems."
        "What are the different types of bridges, and how are they built?"
        "Explain how a wind turbine generates electricity."
        "How do ants communicate with each other?"
        "Describe the process of making chocolate from cocoa beans."
        "How does night vision technology work?"
        "What are the main causes of lightning, and how does it form?"
        "Explain how people breathe and why oxygen is important for survival."
        "How do dolphins communicate with each other?"
        "Describe how a bicycle stays balanced when in motion."
        "How does the internet work, and how is data transmitted between computers?"
        "What are the basic steps in solving a Rubik’s cube?"
        "Explain the difference between an electric and an acoustic guitar."
        "How does a battery store and release energy?"
        "Describe how a radio picks up and plays music."
        "How do car airbags work to keep passengers safe?"
        "Explain how a GPS system determines your location."
        "What are the main components of a rocket, and how do they function?"
        "How do spiders spin their webs, and what are they used for?"
        "Describe how rainforests help regulate Earth's climate."
        "How do chameleons change color, and why do they do it?"
        "Explain how elevators work using pulleys and counterweights."
        "How do printers transfer ink onto paper?"
)

# Ask the user to input API Key and Domain URL
echo -n "Enter your API Key: "
read api_key
echo -n "Enter the Domain URL: "
read api_url

# Exit if the API Key or URL is empty
if [ -z "$api_key" ] || [ -z "$api_url" ]; then
    echo "Error: Both API Key and Domain URL are required!"
    exit 1
fi

# Set number of threads to 1 (default)
num_threads=1
echo "✅ Using 1 thread..."

# Function to run the single thread
start_thread() {
    while true; do
        # Pick a random message from the predefined list
        random_message="${user_messages[$RANDOM % ${#user_messages[@]}]}"
        send_request "$random_message" "$api_key" "$api_url"
    done
}

# Start the single thread
start_thread &

# Wait for the thread to finish (this will run indefinitely)
wait

# Graceful exit handling (SIGINT, SIGTERM)
trap "echo -e '\n🛑 Process terminated. Exiting gracefully...'; exit 0" SIGINT SIGTERM
