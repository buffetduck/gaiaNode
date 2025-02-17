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
            "Describe the process of photosynthesis and its importance to plants."
            "How does gravity affect objects on Earth?"
            "List three causes of climate change and their effects on the environment."
            "Explain the difference between renewable and nonrenewable energy sources."
            "What are the main functions of the human heart?"
            "Describe how a rainbow forms after it rains."
            "How do airplanes stay in the air despite their heavy weight?"
            "Explain why the moon has different phases throughout the month."
            "What are the key differences between mammals and reptiles?"
            "Describe the water cycle and its stages."
            "How does the food chain work in an ecosystem?"
            "Why do some animals hibernate during the winter?"
            "How do bees contribute to plant reproduction?"
            "What are the main layers of the Earth, and what do they consist of?"
            "Explain the difference between a democracy and a dictatorship."
            "What are three common causes of earthquakes?"
            "How does a compass work, and what is its purpose?"
            "Describe the process of digestion in the human body."
            "Why do humans need sleep, and what happens when they don’t get enough?"
            "What are the main differences between viruses and bacteria?"
            "How do mirrors reflect light, allowing us to see our reflection?"
            "Explain why metal conducts electricity better than plastic."
            "What are the causes and effects of ocean pollution?"
            "How do vaccinations help protect people from diseases?"
            "Describe how a volcano erupts and what causes it."
            "Why do leaves change color in the fall?"
            "What are the benefits of exercise for the human body?"
            "How do plants adapt to survive in desert environments?"
            "Explain how solar panels generate electricity from sunlight."
            "What causes lightning and thunder during a storm?"
            "Why do humans sweat, and how does it help regulate body temperature?"
            "Describe the role of decomposers in an ecosystem."
            "How do submarines dive and resurface in the ocean?"
            "Explain the process of making chocolate from cocoa beans."
            "What are the key factors that influence weather patterns?"
            "How does the immune system protect the body from infections?"
            "Why do we experience different seasons throughout the year?"
            "Describe the structure and function of DNA."
            "What is the greenhouse effect, and how does it impact the planet?"
            "How do musical instruments produce different sounds?"
            "Why do some birds migrate while others do not?"
            "What are the steps involved in treating and purifying drinking water?"
            "Explain how the internet works and how data travels between devices."
            "How do car engines convert fuel into movement?"
            "Describe the process of making paper from trees."
            "How do astronauts train to prepare for space travel?"
            "What causes tsunamis, and what damage can they cause?"
            "Why do fish have gills instead of lungs?"
            "How do optical illusions trick the human brain?"
            "What are the effects of deforestation on the environment?"
            "Describe how a camera captures and processes images."
            "Why do metals expand when heated and contract when cooled?"
            "How do wind turbines generate electricity?"
            "Explain the importance of bees in agriculture and food production."
            "Why do people experience jet lag after long flights?"
            "How does the stock market work?"
            "Describe the role of the kidneys in filtering waste from the body."
            "What are the dangers of plastic pollution in the ocean?"
            "How do vaccines train the immune system to fight infections?"
            "Why do magnets attract certain materials but not others?"
            "Explain how GPS systems determine your location."
            "How does caffeine affect the human body?"
            "Why do earthquakes occur along fault lines?"
            "Describe how a microwave heats food."
            "How do fireflies produce light?"
            "What causes ocean tides to rise and fall?"
            "How does an electric circuit work?"
            "Explain how coral reefs support marine life."
            "Why does metal feel colder than wood at the same temperature?"
            "Describe the process of making glass from sand."
            "What are the causes and effects of acid rain?"
            "How do airbags protect passengers during car accidents?"
            "Explain how the body regulates its temperature in hot and cold conditions."
            "Why do bubbles always take a spherical shape?"
            "Describe the formation of fossils over time."
            "How does an airplane’s black box help in accident investigations?"
            "What are the effects of prolonged exposure to space on the human body?"
            "How do batteries store and release energy?"
            "Why do flamingos stand on one leg?"
            "Describe how ants communicate with each other."
            "How do chameleons change color, and why do they do it?"
            "Why do helium balloons float while air-filled balloons do not?"
            "Explain how fingerprints are unique to every person."
            "What are the effects of smoking on the lungs?"
            "How does Wi-Fi allow devices to connect to the internet?"
            "Why does food spoil if left out for too long?"
            "Describe the differences between a comet, an asteroid, and a meteor."
            "How do sharks detect movement in the water?"
            "Why do humans have different blood types?"
            "Explain how an escalator works."
            "How do submarines navigate underwater without GPS?"
            "Why do birds have hollow bones?"
            "Describe the steps involved in making cheese."
            "How does a rocket launch into space?"
            "Why do soap bubbles display different colors?"
            "Explain why boiling water can kill bacteria."
            "How do wind patterns affect global weather conditions?"
            "Why do astronauts experience weightlessness in space?"
            "Describe how plants remove carbon dioxide from the air."
            "How does the brain process and store memories?"
            "Why do ice cubes float in water?"
            "Explain how eyeglasses help correct vision problems."
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
