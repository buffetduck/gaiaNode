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
           "Explain why the sky appears blue during the day."  
"Describe the life cycle of a butterfly."  
"How does photosynthesis work in plants?"  
"What are the main causes of global warming?"  
"Explain the difference between a solar and lunar eclipse."  
"How does a refrigerator keep food cold?"  
"Describe the water cycle and its main stages."  
"What are the benefits of exercise for the human body?"  
"How does a car engine work?"  
"Explain why seasons change on Earth."  
"What are the basic functions of the human brain?"  
"Describe the process of making chocolate from cacao beans."  
"How do airplanes stay in the air?"  
"Explain the difference between renewable and nonrenewable energy sources."  
"What are the main functions of the heart?"  
"Describe how a volcano erupts."  
"Why do we need to drink water every day?"  
"How does the internet work?"  
"What happens during digestion in the human body?"  
"Explain how a rainbow forms in the sky."  
"Describe how sound travels through different mediums."  
"What are the key differences between mammals and reptiles?"  
"How do bees help with pollination?"  
"Why do we see different phases of the moon?"  
"Describe the basic principles of gravity."  
"What are the main types of clouds and how do they form?"  
"Explain why ocean tides occur."  
"How does a plant grow from a seed?"  
"Describe the structure and function of DNA."  
"What causes earthquakes and how do they affect the Earth?"  
"Explain how vaccines help protect against diseases."  
"How does an electric circuit work?"  
"Describe the different layers of Earth's atmosphere."  
"What are the main differences between bacteria and viruses?"  
"How does the immune system protect the body?"  
"Explain how magnets work."  
"Describe how a camera captures an image."  
"What are the key differences between a comet and an asteroid?"  
"How do whales communicate underwater?"  
"Explain the process of making paper from trees."  
"How does the brain process emotions?"  
"Describe how a computer processes information."  
"What are the main differences between plant and animal cells?"  
"Explain why metal conducts electricity better than wood."  
"How do birds navigate when migrating?"  
"Describe the greenhouse effect and its impact on climate."  
"How do submarines move underwater?"  
"Explain how echolocation works in bats and dolphins."  
"Describe the process of making glass from sand."  
"How does a GPS system determine location?"  
"Why do humans need sleep, and what happens when they don’t get enough?"  
"Explain how fingerprints are unique to each person."  
"How does the stock market work?"  
"Describe the process of making cheese from milk."  
"What happens when lightning strikes?"  
"How do animals adapt to survive in extreme environments?"  
"Explain how the human eye sees different colors."  
"Describe how bridges are designed to support heavy loads."  
"How does an air conditioner cool a room?"  
"What causes the Northern Lights?"  
"Explain how a parachute slows a person's fall."  
"Describe how plants adapt to survive in the desert."  
"How does a smartphone send and receive signals?"  
"Why do chameleons change color?"  
"Explain the process of cloning in animals."  
"How do wind turbines generate electricity?"  
"Describe how submarines control their depth in water."  
"How does caffeine affect the human body?"  
"What causes a tsunami, and how does it impact coastal areas?"  
"Explain how astronauts prepare for space missions."  
"How does the process of fermentation work in making bread?"  
"Describe the steps involved in treating water for drinking."  
"How does a roller coaster stay on its tracks?"  
"What happens inside the sun to produce energy?"  
"Explain the concept of artificial intelligence and its applications."  
"How do ants communicate with each other?"  
"Describe the formation of a coral reef."  
"What are the different types of blood cells and their functions?"  
"Explain how a microwave heats food."  
"How does an electric car work compared to a gasoline car?"  
"Why do icebergs float in water?"  
"Describe how a lock and key mechanism works."  
"How do satellites stay in orbit around the Earth?"  
"Explain why oil and water do not mix."  
"Describe the process of photosynthesis in simple terms."  
"How do sharks detect movement in the water?"  
"Why do our muscles get sore after exercise?"  
"Explain the function of the ozone layer in the atmosphere."  
"How do 3D printers create objects?"  
"Describe how a hot air balloon rises into the sky."  
"What are the key differences between fresh and saltwater ecosystems?"  
"Explain why people get goosebumps."  
"How does the nervous system send messages in the body?"  
"Describe the process of growing rice in a paddy field."  
"How do lighthouses help ships navigate safely?"  
"Explain why soap helps remove dirt and grease."  
"How do astronauts experience weightlessness in space?"  
"Describe the key differences between a violin and a guitar."  
"How does the human brain remember things?"  
"Explain why airplanes fly at high altitudes."
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
