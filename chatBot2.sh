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
           "How do fireflies produce light?"  
"Explain the role of chlorophyll in plants."  
"How do fish breathe underwater?"  
"Describe how a seed turns into a tree."  
"Why does metal feel colder than wood at the same temperature?"  
"Explain the difference between high tide and low tide."  
"How do birds stay warm in the winter?"  
"Describe how a GPS calculates your location."  
"Why do airplanes leave white trails in the sky?"  
"Explain why some people are left-handed."  
"How do solar panels generate electricity?"  
"Describe how a vending machine works."  
"Why does salt help preserve food?"  
"How do mirrors reflect light?"  
"Explain the difference between a debit card and a credit card."  
"Why do camels have humps?"  
"How do whales hold their breath for so long?"  
"Describe how an hourglass measures time."  
"Why do stars twinkle at night?"  
"How do submarines navigate underwater?"  
"Explain how a thermostat controls temperature."  
"How do bees make honey?"  
"Describe how a zipper works."  
"Why does the Moon have craters?"  
"How do plants 'breathe' through their leaves?"  
"Explain why soap creates bubbles."  
"How does a compass always point north?"  
"Describe the purpose of airbags in a car."  
"Why do onions make you cry?"  
"How do glow-in-the-dark objects work?"  
"Explain why popcorn pops."  
"How do airplanes take off and land?"  
"Describe how a touch screen detects your fingers."  
"Why do flamingos stand on one leg?"  
"How do electric cars charge their batteries?"  
"Explain how a speaker produces sound."  
"Why do helium balloons float in the air?"  
"How do ice skates glide on ice?"  
"Describe how a vacuum cleaner works."  
"Why do some insects walk on water?"  
"How does a smoke detector sense smoke?"  
"Explain how a magnet attracts metal."  
"Why does yawning seem contagious?"  
"How do self-driving cars detect obstacles?"  
"Describe how a battery stores energy."  
"Why does sugar dissolve faster in hot water?"  
"How does a 3D movie work?"  
"Explain how electric eels produce electricity."  
"Why do birds sing?"  
"How do boomerangs return when thrown?"  
"Describe how a sundial tells time."  
"Why do bubbles always form spheres?"  
"How does a roller skate move?"  
"Explain why glass is transparent."  
"Why do some animals hibernate?"  
"How do drones stay stable in the air?"  
"Describe how a matchstick produces fire."  
"Why do our fingers wrinkle in water?"  
"How do rainbows form after rain?"  
"Explain how a cuckoo clock works."  
"Why do people blush?"  
"How does Wi-Fi transmit data?"  
"Describe how a candle burns."  
"Why do chameleons change color?"  
"How do animals see in the dark?"  
"Explain how a gyroscope maintains balance."  
"Why do zebras have stripes?"  
"How do vending machines know which coin is inserted?"  
"Describe how an escalator moves."  
"Why do cats purr?"  
"How does an Etch-a-Sketch erase drawings?"  
"Explain why some people get car sick."  
"How do wind chimes produce sound?"  
"Describe how a lava lamp works."  
"Why do magnets have north and south poles?"  
"How does a fire extinguisher put out flames?"  
"Explain why wool keeps you warm."  
"Why do turtles retract their heads into their shells?"  
"How do airplanes fly upside down?"  
"Describe how a frisbee stays in the air."  
"Why do some people talk in their sleep?"  
"How does a cuckoo clock keep time?"  
"Explain why shadows change size during the day."  
"How do birds fly without flapping their wings?"  
"Describe how glow sticks produce light."  
"Why do hot air balloons rise?"  
"How do vending machines prevent theft?"  
"Explain how a Polaroid camera works."  
"Why do fire trucks have sirens?"  
"How do car brakes stop a vehicle?"  
"Describe why some rocks are magnetic."  
"Why do some fish glow in the dark?"  
"How does a submarine control its depth?"  
"Explain why some leaves change color in autumn."  
"Why do microwave ovens heat food evenly?"  
"How do icebergs float in the ocean?"  
"Describe how windmills generate power."  
"Why do turtles live so long?"  
"How does a jukebox select a song?"  
"Explain how a barometer measures air pressure."  
"Why do different animals have different types of teeth?"  
"How do water slides make you go fast?"  
"Describe how a metal detector finds hidden objects."  
"Why do clocks make ticking sounds?"  
"How does a hologram create a 3D image?"
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
